class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include Pagy::Backend
  include Pundit::Authorization

  before_action :set_current_request_details
  before_action :authenticate

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def current_user
    Current.user
  end

  def goto_dashboard(foundation)
    render turbo_stream: [
      turbo_stream.replace("username", partial: "layouts/username"),
      turbo_stream.replace("messages", partial: "layouts/messages"),
      turbo_stream.replace("main_content", partial: "pages/dashboard", locals: { foundation: foundation })
    ]
  end

  private
    def user_not_authorized
      flash.now[:alert] = "You are not authorized to perform this action."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    end

    def authenticate
      if session_record = Session.find_by_id(cookies.signed[:session_token])
        Current.session = session_record
      else
        redirect_to sign_in_path
      end
    end

    def set_current_request_details
      Current.user_agent = request.user_agent
      Current.ip_address = request.ip
    end
end
