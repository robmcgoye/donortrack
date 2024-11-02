class Commitment < ApplicationRecord
  belongs_to :organization
  has_many :contributions
  # , dependent: :destroy
  monetize :amount_cents, numericality:  { greater_than: 0 }

  scope :organization_commitments, ->(organization_ids) { where(organization_id: organization_ids) }

  validates :code, :start_at, :end_at, presence: true
  validates :start_at, comparison: { less_than: :end_at }
  validates :number_payments, numericality: { greater_than: 0, only_integer: true }
  validate :commitment_total

  before_destroy :validate_before_destroy

  scope :not_completed, -> { where(completed: false) }
  scope :completed, -> { where(completed: true) }
  scope :sort_organization_up, -> { includes(:organization).order("organizations.name") }
  scope :sort_organization_down, -> { includes(:organization).order("organizations.name desc") }
  scope :sort_start_date_up, -> { order(:start_at) }
  scope :sort_start_date_down, -> { order(start_at: :desc) }
  scope :sort_end_date_up, -> { order(:end_at) }
  scope :sort_end_date_down, -> { order(end_at: :desc) }
  scope :sort_payment_up, -> { order(:amount_cents) }
  scope :sort_payment_down, -> { order(amount_cents: :desc) }

  def total_commitment
    amount_cents * number_payments
  end

  def payments
    contributions.includes(:check).sum("checks.amount_cents")
  end

  def amount_due
    total_commitment - payments
  end

  private

    def commitment_total
      if amount_cents.nil? || number_payments.nil?
      elsif total_commitment < payments
        errors.add(:base, "Existing payments exceed the commitment total")
      end
    end

    def validate_before_destroy
      if contributions.cleared_contributions.count > 0
        errors.add(:base, "Cannot delete this commitment because it has cleared contributions!")
        throw(:abort)
      else
        contributions.destroy_all
      end
    end
end
