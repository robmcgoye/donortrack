# test/mailers/previews/user_mailer_preview.rb
class UserMailerPreview < ActionMailer::Preview
  def email_verification
    UserMailer.with(user: User.first).email_verification
    # UserMailer.email_verification()
  end

  def password_reset
    UserMailer.with(user: User.first).password_reset
  end
end
