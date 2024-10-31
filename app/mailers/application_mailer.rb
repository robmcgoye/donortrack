require "digest/sha2"
class ApplicationMailer < ActionMailer::Base
  default "Message-ID"=>"#{Digest::SHA2.hexdigest(Time.now.to_i.to_s)}@#{Rails.application.credentials.smtp[:message_id_domain]}"
  default from: Rails.application.credentials.smtp[:default_from]
  layout "mailer"
end
