class Check < ApplicationRecord
  belongs_to :bank_account
  belongs_to :funding_source, optional: true
  has_many :reconciliation_items
  has_many :reconciliations, through: :reconciliation_items
  has_many :contributions, as: :agreement
  # has_one :contribution
  # , dependent: :destroy
  monetize :amount_cents, numericality: { greater_than: 0 }
  attribute :orginal_amount_cents
  attribute :orginal_bank_account_id
  monetize :orginal_amount_cents, allow_nil: true

  after_initialize :set_orginals
  after_create :update_bank_account_balance
  after_save :check_bank_account_balance
  before_destroy :remove_amount_from_account_balance

  enum :transaction_type, { debit: 0, credit: 1 }, default: :debit

  validates :check_number, uniqueness: { scope: :bank_account_id }, allow_nil: true
  validates :transaction_at, presence: { message: "must have date of transaction" }
  validates :cleared, inclusion: { in: [ true, false ] }

  validate :prevent_edits_when_cleared
  validate :require_funding_source_when_debit

  scope :open_transactions, -> () { where(cleared: false).order(:transaction_at) }
  scope :open_deposits, -> () { where(cleared: false).where(transaction_type: :credit).order(transaction_at: :desc) }

  private

    def require_funding_source_when_debit
      if transaction_type == "debit"
        if funding_source_id.nil?
          errors.add(:base, "must have a Funding Source.")
        end
      end
    end

    def prevent_edits_when_cleared
      if cleared?
        errors.add(:base, "Cannot make changes after it is cleared")
      end
    end

    def update_bank_account_balance
      bank_account.update_balance!(calculate_balance(bank_account.balance, credit?, amount, false))
    end

    def calculate_balance(current_balance, is_credit, transaction_amount, is_inverted)
      if !is_inverted
        current_balance + (is_credit ? transaction_amount : -transaction_amount)
      else
        current_balance + (is_credit ? -transaction_amount : transaction_amount)
      end
    end

    def check_bank_account_balance
      if orginal_bank_account_id != bank_account_id
        # add funds back to orginal account
        orginal_bank = BankAccount.find(orginal_bank_account_id)
        orginal_bank.update_balance!(calculate_balance(orginal_bank.balance, credit?, orginal_amount, true))
        # update balance on new bank account
        bank_account.update_balance!(calculate_balance(bank_account.balance, credit?, amount, false))
      else
        if orginal_amount != amount
          balance = calculate_balance(bank_account.balance, credit?, orginal_amount, true)
          bank_account.update_balance!(calculate_balance(balance, credit?, amount, false))
        end
      end
    end

    def set_orginals
      self.orginal_amount ||= amount
      self.orginal_bank_account_id ||= bank_account_id
    end

    def remove_amount_from_account_balance
      if !cleared?
        bank_account.update_balance!(calculate_balance(bank_account.balance, credit?, amount, true))
      else
        errors.add(:base, "Cannot delete this transaction because it has already been cleared!")
        throw(:abort)
      end
    end
end
