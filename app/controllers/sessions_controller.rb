class SessionsController < ApplicationController
  include SessionManagement
  skip_before_action :authenticate, only: %i[ new create ]
  before_action :validate_params, only: [ :create ]
  before_action :set_session, only: :destroy

  def index
    load_sessions
  end

  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      create_session_for(user)
      redirect_to root_path, notice: "Signed in successfully"
    else
      redirect_to sign_in_path, alert: "That email or password is incorrect"
    end
  rescue StandardError => e
    # Handle unexpected errors
    redirect_to sign_in_path alert: "An error occurred: #{e.message}"
  end

  def destroy
    this_session_id = @session.id
    begin
      @session.destroy
    rescue ActiveRecord::RecordNotFound
      # Handle session not found error
      flash.now[:alert] = "Session not found"
      load_sessions
    rescue StandardError => e
      # Handle unexpected errors
      flash.now[:alert] = "An error occurred: #{e.message}"
      load_sessions
    else
      # Handle successful destroy
      if this_session_id != cookies.signed[:session_token]
        flash.now[:notice] = "That session has been logged out."
        load_sessions
      else
        redirect_to sign_in_path, notice: "That session has been logged out"
      end
    end
  end

  private

    def load_sessions
      @sessions = Current.user.sessions.order(created_at: :desc)
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace("main_content", partial: "sessions/index")
      ]
    end

    def set_session
      @session = Current.user.sessions.find(params[:id])
    end

    def validate_params
      email = params[:email]
      password = params[:password]

      unless email =~ URI::MailTo::EMAIL_REGEXP
        redirect_to sign_in_path, alert: "Invalid email format"
      end

      unless password.present? && password.length >= 6
        redirect_to sign_in_path, alert: "Password must be at least 6 characters long"
      end
    end
end
