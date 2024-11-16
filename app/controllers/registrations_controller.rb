class RegistrationsController < ApplicationController
  include SessionManagement
  skip_before_action :authenticate
  before_action :redirect_if_user_exists, only: [ :new, :create ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      create_session_for(@user)
      send_email_verification(@user)
      redirect_to root_path, notice: "Welcome! You have signed up successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def redirect_if_user_exists
    if User.exists?
      redirect_to sign_in_path, alert: "Contact admin to create account."
    end
  end

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end

  def send_email_verification(user)
    UserMailer.with(user: user).email_verification.deliver_later
  end
end
