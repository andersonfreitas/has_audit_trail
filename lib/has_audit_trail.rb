require 'active_record'
require 'has_audit_trail/version'
require 'has_audit_trail/audit_trail'
require 'has_audit_trail/audit_trail_include'

ActiveRecord::Base.send :include, HasAuditTrail::AuditTrailInclude

#ActionController::Base.class_eval do
  #require_dependency 'has_audit_trail'
#end

if defined?(ActionController) and defined?(ActionController::Base)

  require 'has_audit_trail/audit_trail_sweeper'

  ActionController::Base.class_eval do
    cache_sweeper :audit_trail_sweeper
  end
end

