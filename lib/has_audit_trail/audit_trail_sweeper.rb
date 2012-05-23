class AuditTrailSweeper < ActionController::Caching::Sweeper
  observe AuditTrail

  def before_create(audit_trail)
    audit_trail.user ||= current_user
    audit_trail.remote_address = controller.try(:request).try(:ip)
  end

  def current_user
    controller.send :current_user if controller.respond_to?(:current_user, true)
  end
end

