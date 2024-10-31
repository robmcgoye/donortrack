class SessionsController < ApplicationController
  skip_before_action :authenticate, only: %i[ new create ]
  before_action :set_session, only: :destroy

  def index
    load_sessions
  end

  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      @session = user.sessions.create!
      cookies.signed.permanent[:session_token] = { value: @session.id, httponly: true }

      redirect_to root_path, notice: "Signed in successfully"
    else
      redirect_to sign_in_path, alert: "That email or password is incorrect"
    end
  end

  def destroy
    this_session_id = @session.id
    @session.destroy
    if this_session_id != cookies.signed[:session_token]
      flash.now[:notice] = "That session has been logged out."
      load_sessions
    else
      redirect_to(sign_in_path, notice: "That session has been logged out")
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
end
