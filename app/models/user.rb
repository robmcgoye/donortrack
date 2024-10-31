class User < ApplicationRecord
  rolify
  has_secure_password

  attr_accessor :admin

  has_many :email_verification_tokens, dependent: :destroy
  has_many :password_reset_tokens, dependent: :destroy
  has_many :sessions, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 6 }

  before_validation if: -> { email.present? } do
    self.email = email.downcase.strip
  end

  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  after_create :assign_default_role

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  after_save do |user|
    if User.count > 1
      if user.admin? != (user.has_any_role? :admin)
        if user.admin?
          user.add_role(:admin)
        else
          user.remove_role :admin
        end
        user.add_role(:user) if roles.blank?
      end
    end
  end

  after_find do |user|
    if user.has_any_role? :admin
      user.admin = 1
    else
      user.admin = 0
    end
    # user.admin = user.has_any_role? :admin
  end

  def get_roles
    roles.where(resource_type: nil).pluck(:name)
  end

  def admin?
    if self.admin.to_i == 1
      true
    else
      false
    end
  end

  private

  def assign_default_role
    if User.count == 1
      add_role(:admin) if roles.blank?
    else
      add_role(:user) if roles.blank?
    end
  end
end
