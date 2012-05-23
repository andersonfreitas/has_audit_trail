module HasAuditTrail
  module AuditTrailInclude
    def self.included(base)
      base.extend ClassMethods
    end

    VALID_OPTIONS = [:only, :audit_nested ]

    module ClassMethods
      def has_audit_trail(opts = {})
        return if self.included_modules.include?(HasAuditTrail::AuditTrailInclude::InstanceMethods)

        opts.assert_valid_keys HasAuditTrail::AuditTrailInclude::VALID_OPTIONS

        class_attribute :audited_columns, :instance_writer => false
        class_attribute :audited_associations, :instance_writer => false
        class_attribute :audited_collections, :instance_writer => false
        class_attribute :changed_collections, :instance_writer => false

        self.audited_columns = opts[:only] || self.attribute_names.collect { |str| str.to_sym }
        self.audited_columns -= opts[:except] if opts[:except]

        self.audited_associations = opts[:audit_nested] if opts[:audit_nested]

        # Descobrindo quais são as associations automaticamente
        self.audited_collections = []
        self.audited_columns.each do |attr|
          if self.respond_to? "after_add_for_#{attr}"
            self.audited_collections << attr
            self.audited_columns -= [attr]
          end
        end

        self.changed_collections = {}
        self.audited_collections.try(:each) do |attr|
          self.changed_collections[attr] = { :added => [], :removed => [] }

          self.send("after_add_for_#{attr}") << Proc.new { |owner, record| owner.changed_collections[attr.to_sym][:added] << record }
          self.send("after_remove_for_#{attr}") << Proc.new { |owner, record| owner.changed_collections[attr.to_sym][:removed] << record }
        end

        after_create :audit_create
        before_save :audit_save # before_update?
        before_destroy :audit_destroy

        include HasAuditTrail::AuditTrailInclude::InstanceMethods
      end
    end
    module InstanceMethods
      def write_audit(attrs)
        attrs.merge!(object: self.class.model_name, object_id: self.id)
        AuditTrail.create!(attrs)
      end

      def audit_create
        write_audit(action: :create)
      end

      def audit_destroy
        write_audit(action: :destroy)
      end

      def audit_save
        if changed?
          changes.each do |field, change|
            if self.audited_columns.include? field.to_sym
              write_audit(action: :update, old_value: change[0].to_yaml, new_value: change[1].to_yaml, property: field)
            end
          end
        end

        # direct associations
        audited_collections.try(:each) do |attr|
          unless new_record?
            if changed_collections[attr][:added].size > 0
              old = self.send(attr) - changed_collections[attr][:added]

              write_audit(action: :update, old_value: old.collect { |x| x.name }, new_value: self.send(attr).collect {|x|x.name}, property: attr)
              changed_collections[attr][:added] = []
            end
            if changed_collections[attr][:removed].size > 0
              old = self.send(attr) + changed_collections[attr][:removed]

              write_audit(action: :update, old_value: old.collect { |x| x.name }, new_value: self.send(attr).collect {|x|x.name}, property: attr)
              changed_collections[attr][:removed] = []
            end
          end
        end

        # accepts_nested_attributes_for
        audited_associations.try(:each) do |attr, procs|
          unless new_record?
            self.send(attr).each do |c|
              if c.changed?
                c.changes.each do |field, change|
                  if change[0].to_s != change[1].to_s
                    write_audit(action: :update, old_value: change[0].to_yaml, new_value: change[1].to_yaml, property: procs[:label].call(c))
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
