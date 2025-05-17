class InKind < ApplicationRecord
  has_many :contributions, as: :agreement

  monetize :value_cents, numericality: { greater_than: 0 }

  enum :type_of, { househld_effects: 0, personal_effects: 1, securities: 2 }
  enum status: { pending: 0, reviewed: 1, acknowledged: 2 }

  validates :transaction_at, presence: { message: "must have date of transaction" }
  validates :type_of, presence: true
  before_save :set_status_at_timestamp

  private

  def set_status_at_timestamp
    if will_save_change_to_status?
      if reviewed? || acknowledged?
        self.status_at = Time.current
      else
        self.status_at = nil
      end
    end
  end
end
