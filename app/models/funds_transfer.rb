class FundsTransfer < ApplicationRecord
  has_many :contributions, as: :agreement
  belongs_to :funding_source
  
  monetize :amount_cents, numericality: {greater_than: 0}

  validates :transaction_at, presence: { message: "must have date of transaction" }
  
end