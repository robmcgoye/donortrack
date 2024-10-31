class ReconciliationItem < ApplicationRecord
  belongs_to :reconciliation 
  belongs_to :check

  after_save :clear_check
  before_destroy :unclear_check

  private

    def clear_check
      Check.find(self.check_id).update(cleared: true)
    end

    def unclear_check
      Check.find(self.check_id).update(cleared: false)
    end
end
