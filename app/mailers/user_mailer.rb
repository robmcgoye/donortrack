class UserMailer < ApplicationMailer
  def password_reset
    @user = params[:user]
    @time_to_expire = 20.minutes
    @signed_id = @user.password_reset_tokens.create.signed_id(expires_in: @time_to_expire)

    mail to: @user.email, subject: "Reset your password"
  end

  def email_verification
    @user = @params[:user]
    @time_to_expire = 2.days
    @signed_id = @user.email_verification_tokens.create.signed_id(expires_in: @time_to_expire)

    mail to: @user.email, subject: "Verify Your Email Address"
  end
end
