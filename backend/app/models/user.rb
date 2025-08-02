class User < ApplicationRecord
  def permission_to_change_pricing?
    has_required_permission?(%w(super_admin finance_manager)) || admin? || %w(ari@whop.com hunter@whop.com madeline@whop.com).include?(email)
  end

  def admin_can_modify_fees?
    admin?
  end

  def has_required_permission?(roles)
    roles.any? { |role| send("#{role}?") }
  end

  def admin?
    role == 'admin'
  end

  def super_admin?
    role == 'super_admin'
  end

  def finance_manager?
    role == 'finance_manager'
  end
end