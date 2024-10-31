class Reconciliation < ApplicationRecord
  belongs_to :bank_account
  has_many :reconciliation_items, dependent: :destroy
  has_many :checks, through: :reconciliation_items

  monetize :starting_balance_cents, numericality: true
  monetize :ending_balance_cents, numericality: true
  
  validates :started_at, :ended_at, presence: true
  validates :started_at, comparison: { less_than: :ended_at }
  validate :validate_date_range_uniqueness

  after_initialize :set_starting_values
  after_create :set_checks_cleared

  scope :bank_reconciliations, -> (bank_account_id) { where(bank_account_id: bank_account_id).order(started_at: :desc) }


  private

    def set_checks_cleared
      checks.update_all(cleared: true)
    end

    def set_starting_values
      if new_record? && bank_account_id.present?
        last_reconciliation =  Reconciliation.bank_reconciliations(bank_account_id).first
        if last_reconciliation.present?
          self.started_at = last_reconciliation.ended_at + 1.day
          self.starting_balance = last_reconciliation.ending_balance
        else
          bank_account = BankAccount.find(bank_account_id).checks.where(transaction_type: :credit).order(transaction_at: :asc).first
          if bank_account.present?
            self.started_at = bank_account.transaction_at
            self.starting_balance = 0
          end
        end
      end
    end

    def validate_date_range_uniqueness
      return unless started_at && ended_at  
      if Reconciliation.exists?(['(bank_account_id = ?) AND ((started_at <= ? AND ended_at >= ?) OR (started_at <= ? AND ended_at >= ?))',
              bank_account_id, started_at, started_at, ended_at, ended_at])
        errors.add(:base, 'Date range is already in use.')
      end
    end    
end