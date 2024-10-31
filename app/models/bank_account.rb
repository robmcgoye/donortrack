class BankAccount < ApplicationRecord
  belongs_to :foundation
  has_many :reconciliations, dependent: :destroy
  has_many :checks
  
  monetize :starting_balance_cents, numericality: { greater_than: 0 }
  monetize :balance_cents

  validates :full_name, presence: true, uniqueness: { scope: :foundation_id }

  scope :foundation_accounts, -> (foundation_id) { where(foundation_id: foundation_id) }

  scope :primary_account, -> (foundation_id) { where(foundation_id: foundation_id).where(primary: true).take }
  
  before_save :update_primary_bank_account
  before_destroy :check_for_transactions

  after_create do
    Check.create!(
      transaction_at: Time.new,
      transaction_type: :credit,
      description: "Starting Balance",
      bank_account_id: id,
      amount: starting_balance
    )
  end

  def update_balance!(new_balance)
    update(balance: new_balance)
  end

  private 

  def check_for_transactions
    if checks.size > 0
      errors.add(:base, "Cannot delete this bank account because it has transactions!")
      throw(:abort)    
    end
  end

  def update_primary_bank_account
    if primary_changed? && primary
      BankAccount.foundation_accounts(foundation_id).update_all(primary: false) 
    end
  end

end
