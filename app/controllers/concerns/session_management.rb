module SessionManagement
  extend ActiveSupport::Concern

  private

  def create_session_for(user)
    session_record = user.sessions.create!
    cookies.signed.permanent[:session_token] = { value: session_record.id, httponly: true }
  end

  def destroy_all_sessions_for(user, redirect: false)
    # Delete all user sessions
    user.sessions.delete_all
    cookies.delete(:session_token)
    redirect_to(sign_in_path) if redirect
  end
end
