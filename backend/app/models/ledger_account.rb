class LedgerAccount < ApplicationRecord
  SENSITIVE_FEE_FIELDS = %w[buyer_fee].freeze

  validates :take_rate, numericality: { greater_than_or_equal_to: 0, less_than: 1 }, allow_nil: true
  validates :above_cost_processing_fee, numericality: { greater_than_or_equal_to: 0.11, less_than: 1 }, allow_nil: true, if: :should_validate_above_cost_processing_fee?
  validates :buyer_fee, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 25 }, allow_nil: true

  private

  def should_validate_above_cost_processing_fee?
    true
  end
end