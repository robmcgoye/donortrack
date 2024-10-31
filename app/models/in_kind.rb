class InKind < ApplicationRecord
  has_many :contributions, as: :agreement

  monetize :value_cents, numericality: {greater_than: 0}
  
  enum :type_of, { househld_effects: 0, personal_effects: 1, securities: 2 }

  validates :transaction_at, presence: { message: "must have date of transaction" }
  validates :type_of, presence: true

end