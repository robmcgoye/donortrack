class FundingSource < ApplicationRecord
  belongs_to :foundation
  has_many :contributions
  # , dependent: :destroy

  validates :full_name, presence: true
  validates :short_name , presence: :true, length: { minimum: 2, maximum: 12 } 
  validates :code , presence: :true, 
            length: { minimum: 2, maximum: 8 }, 
            uniqueness: { scope: :foundation_id } 
  
  before_destroy :validate_before_destroy

  scope :sort_code_up, -> { order("code") }

  private
    
    def validate_before_destroy
      if Contribution.where(funding_source_id: id).count > 0
        errors.add(:base, "Cannot delete this fund because it is associated with a contribution(s)")
        throw(:abort)
      end   
    end
end
