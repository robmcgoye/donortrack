class Contribution < ApplicationRecord
  belongs_to :organization
  # belongs_to :check
  # has_one :check
  # belongs_to :funding_source
  belongs_to :donor
  belongs_to :commitment, optional: true
  belongs_to :agreement, polymorphic: true
  belongs_to :check, -> { where(contributions: { agreement_type: "Check" }) }, foreign_key: "agreement_id", optional: true
  belongs_to :funds_transfer, -> { where(contributions: { agreement_type: "FundsTransfer" }) }, foreign_key: "agreement_id", optional: true
  belongs_to :in_kind, -> { where(contributions: { agreement_type: "InKind" }) }, foreign_key: "agreement_id", optional: true

  validate :prevent_edits_when_cleared
  validate :check_commitment_total

  after_save :check_if_commitment_completed
  before_destroy :validate_before_destroy
  after_destroy :remove_check

  accepts_nested_attributes_for :agreement

  def build_agreement(params)
    self.agreement = agreement_type.constantize.new(params)
  end

  AGREEMENT_OPTIONS = [ "Check", "FundsTransfer", "InKind" ]
  def self.get_agreement_options
    AGREEMENT_OPTIONS
  end
  # enum :contribution_type, { check: 0, funds_transfer: 1, in_kind: 2 }, default: :check

  scope :cleared_contributions, ->() { joins(:check).where("checks.cleared = true") }
  scope :open_contributions, ->() { joins(:check).where("checks.cleared = false") }
  scope :sort_check_num_up, -> { includes(:check).order("checks.check_number") }
  scope :sort_check_num_down, -> { includes(:check).order("checks.check_number desc") }

  scope :organization_contributions, ->(organization_ids) { where(organization_id: organization_ids) }

  scope :sort_date_up, -> { left_joins(:check, :funds_transfer, :in_kind).order(Arel.sql("COALESCE(checks.transaction_at, funds_transfers.transaction_at, in_kinds.transaction_at)")) }
  # left_joins(:check, :funds_transfer, :in_kind).order(Arel.sql("COALESCE(checks.transaction_at, funds_transfers.transaction_at, in_kinds.transaction_at)"))
  # scope :sort_date_up, -> { joins(:agreement).order("agreements.transaction_at") }
  scope :sort_date_down, -> { left_joins(:check, :funds_transfer, :in_kind).order(Arel.sql("COALESCE(checks.transaction_at, funds_transfers.transaction_at, in_kinds.transaction_at) DESC")) }
  scope :sort_amt_up, -> { left_joins(:check, :funds_transfer, :in_kind).order(Arel.sql("COALESCE(checks.amount_cents, funds_transfers.amount_cents, in_kinds.value_cents)")) }
  scope :sort_amt_down, -> { left_joins(:check, :funds_transfer, :in_kind).order(Arel.sql("COALESCE(checks.amount_cents, funds_transfers.amount_cents, in_kinds.value_cents) DESC")) }
  scope :sort_organization_up, -> { includes(:organization).order("organizations.name") }
  scope :sort_organization_down, -> { includes(:organization).order("organizations.name desc") }
  scope :sort_donor_up, -> { includes(:donor).order("donors.code") }
  scope :sort_donor_down, -> { includes(:donor).order("donors.code desc") }
  scope :sort_type_up, -> { order("contributions.agreement_type") }
  scope :sort_type_down, -> { order("contributions.agreement_type desc") }
  scope :transactions_during, ->(starting_at, ending_at) { joins(:check).where("checks.transaction_at >= ? and checks.transaction_at <= ?", starting_at, ending_at) }
  scope :funds, ->(fund_ids) { where(funding_source_id: fund_ids) }
  scope :donors, ->(donor_ids) { where(donor_id: donor_ids) }

  def self.graph_contributions
    # contributions = self.select("checks.amount_cents, organizations.name, checks.transaction_at")
    contributions = self.select("SUM(checks.amount_cents) AS total, checks.transaction_at")
          .joins(:check).joins(:organization)
          .where("checks.transaction_at >= ? AND checks.transaction_at <= ?", 3.month.ago, Time.current)
          .group("checks.transaction_at")
          .order("checks.transaction_at DESC")
    formated_contributions = contributions.pluck("checks.transaction_at as date", "SUM(checks.amount_cents) as total")
    # formated_contributions = contributions.pluck( "checks.transaction_at as date", "organizations.name as name", "checks.amount_cents as total")
    # formated_contributions.map! {|item| [ item[0], item[1], Money.from_cents(item[2]).format(symbol: nil) ]}
    formated_contributions.map! { |item| [ item[0], Money.from_cents(item[1]).format(symbol: nil) ] }
  end

  # def self.transactions_during(starting_at, ending_at)
  # end

  def formatted_amount
    if agreement_type == "InKind"
      agreement.value.format
    else
      agreement.amount.format
    end
  end

  private

    def check_if_commitment_completed
      if commitment_id.present? && commitment.amount_due == 0
        commitment.update(completed: true)
      end
    end

    def check_commitment_total
      if commitment_id.present?
        if new_record?
          due = commitment.amount_due
        else
          due = commitment.amount_due + agreement.orginal_amount_cents
        end
        if (due - agreement.amount_cents) < 0
          errors.add(:base, "Payment exceeds the commitment total")
        end
      end
    end

    def prevent_edits_when_cleared
      if agreement_type == "Check" && agreement.cleared?
        errors.add(:base, "Cannot make changes after it is cleared")
      end
    end

    def validate_before_destroy
      if agreement_type == "Check" && agreement.cleared?
        errors.add(:base, "Cannot delete this contribution because it has already been cleared!")
        throw(:abort)
      end
    end

    def remove_check
      if agreement_type == "Check"
        agreement.destroy
        if commitment_id.present? && commitment.completed && commitment.amount_due > 0
          commitment.update(completed: false)
        end
      end
    end
end
