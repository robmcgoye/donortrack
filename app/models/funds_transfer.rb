class FundsTransfer < ApplicationRecord
  has_many :contributions, as: :agreement
  belongs_to :funding_source

  enum status: { pending: 0, reviewed: 1, acknowledged: 2 }
  monetize :amount_cents, numericality: { greater_than: 0 }

  validates :transaction_at, presence: { message: "must have date of transaction" }
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
