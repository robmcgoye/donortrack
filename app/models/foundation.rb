class Foundation < ApplicationRecord
  
  has_many :bank_accounts, dependent: :destroy
  has_many :donors, dependent: :destroy
  has_many :funding_sources, dependent: :destroy
  has_many :organizations, dependent: :destroy
  has_many :organization_types, dependent: :destroy

  validates :short_name, presence: true, length: { maximum: 4 }
  validates :long_name, presence: true, uniqueness: true

  has_one_attached :image_logo
  has_one_attached :image_header

  def image_logo_as_thumbnail
    image_logo.variant(resize_to_limit: [25, 25]).processed
  end

  def resize_image_logo(width, height)
    image_logo.variant(resize_to_limit: [width, height]).processed
  end

  def resize_image_header(width, height)
    image_header.variant(resize_to_limit: [width, height]).processed
  end

end
