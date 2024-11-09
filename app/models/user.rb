class User < ApplicationRecord
  rolify
  has_secure_password

  has_many :email_verification_tokens, dependent: :destroy
  has_many :password_reset_tokens, dependent: :destroy
  has_many :sessions, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 6 }

  validate :cannot_revoke_own_admin_privileges, on: :remove_admin_role
  # before_action :validate_cannot_revoke_own_admin_privileges, only: [ :remove_admin ]

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

  def add_admin_role
    add_role :admin
  end

  def remove_admin_role
    return false unless valid?(:remove_admin_role)
    Rails.logger.debug("====Remove_admin_role++++++++++++++++++=")
    remove_role :admin
    add_role(:user) if roles.blank?
    true
  end

  def get_roles
    roles.where(resource_type: nil).pluck(:name)
  end

  def admin?
    has_any_role? :admin
  end

  private

  def assign_default_role
    if User.count == 1
      add_role(:admin) if roles.blank?
    else
      add_role(:user) if roles.blank?
    end
  end

  def cannot_revoke_own_admin_privileges
    Rails.logger.debug("START-User#cannot_revoke_own_admin_privileges+++++++++++++++++++=")
    Rails.logger.debug(admin?)
    Rails.logger.debug(Current.user.id)
    Rails.logger.debug(id)
    if admin? && Current.user.id == id
      errors.add(:admin, "can't revoke your own admin privileges")
    end
    Rails.logger.debug("END-User#cannot_revoke_own_admin_privileges++++++++++++++++++=")
  end
end
