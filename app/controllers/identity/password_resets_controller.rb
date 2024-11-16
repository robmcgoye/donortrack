class Identity::PasswordResetsController < ApplicationController
  include SessionManagement
  skip_before_action :authenticate

  before_action :set_user, only: %i[ edit update ]

  def new
  end

  def edit
  end

  def create
    @user = User.find_by(email: params[:email])
    if @user.nil?
      redirect_to new_identity_password_reset_path, alert: "Contact admin to reset your password."
    elsif @user.verified ==  true
      send_password_reset_email
      redirect_to sign_in_path, notice: "Check your email for reset instructions"
    else
      flash.now[:alert] = "You can't reset your password until you verify your email"
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace("resend_verification_button", partial: "resend_verification_button", locals: { user: @user })
      ]
    end
  end

  def resend_email_verification
    @user = User.find(params[:id])
    if @user.nil?
      redirect_to new_identity_password_reset_path, alert: "Contact admin to reset your password."
    elsif @user.verified == true
      redirect_to new_identity_password_reset_path, alert: "User is already verified"
    else
      UserMailer.with(user: @user).email_verification.deliver_later
      redirect_to new_identity_password_reset_path, notice: "Verification email sent"
    end
  end

  def update
    if @user.update(user_params)
      revoke_tokens
      flash[:notice] = "Your password was reset successfully. Please sign in"
      destroy_all_sessions_for(@user, redirect: true)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user
      token = PasswordResetToken.find_signed!(params[:sid]); @user = token.user
    rescue StandardError
      redirect_to new_identity_password_reset_path, alert: "That password reset link is invalid"
    end

    def user_params
      params.permit(:password, :password_confirmation)
    end

    def send_password_reset_email
      UserMailer.with(user: @user).password_reset.deliver_later
    end

    def revoke_tokens
      @user.password_reset_tokens.delete_all
    end
end
