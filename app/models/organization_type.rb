class OrganizationType < ApplicationRecord
  belongs_to :foundation
  has_many :organizations

  validates :description, presence: true
  validates :code , presence: :true, 
            length: { minimum: 2, maximum: 3 }, 
            uniqueness: { scope: :foundation_id } 
            
  before_destroy :validate_before_destroy

  scope :sort_code_up, -> { order(:code) }
  scope :sort_code_down, -> { order(code: :desc) }

  private
    
    def validate_before_destroy
      if Organization.where(organization_type_id: id).count > 0
        errors.add(:base, "Cannot delete this type because it is associated with an organization(s)")
        throw(:abort)
      end   
    end

end
