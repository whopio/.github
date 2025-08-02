class Admin::LedgerAccountsController < ApplicationController
  before_action :set_ledger_account, only: [:show, :edit, :update, :destroy]

  def show
  end

  def edit
  end

  def update
    validate_account_changes!
    
    if @ledger_account.update(ledger_account_params)
      redirect_to admin_ledger_account_path(@ledger_account), notice: 'Ledger account fee structure updated successfully.'
    else
      render :edit
    end
  end

  private

  def set_ledger_account
    @ledger_account = LedgerAccount.find(params[:id])
  end

  def ledger_account_params
    params.require(:ledger_account).permit(:take_rate, :above_cost_processing_fee, :buyer_fee)
  end

  def validate_account_changes!
    if @ledger_account.above_cost_processing_fee_changed? && @ledger_account.above_cost_processing_fee < 0.11 && !current_user.permission_to_change_pricing?
      raise ServiceError, "You do not have permission to set above cost processing fees below 0.11%. Only certain users can do this."
    end
    
    LedgerAccount::SENSITIVE_FEE_FIELDS.each do |field|
      if @ledger_account.send("#{field}_changed?") && !@ledger_account.send(field).nil? && !current_user_has_permission_to_change_sensitive_fee_fields?
        raise ServiceError, "Only the finance_manager role and certain other individuals are allowed to change #{field.humanize}"
      end
    end
  end

  def current_user_has_permission_to_change_sensitive_fee_fields?
    current_user.has_required_permission?(%w(finance_manager)) || current_user.admin? || current_user.email == "hunter@whop.com"
  end
end