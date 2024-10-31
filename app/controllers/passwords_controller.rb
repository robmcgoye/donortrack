class PasswordsController < ApplicationController
  before_action :set_user

  def edit
    goto_edit_password
  end

  def update
    if !@user.authenticate(params[:current_password])
      flash.now[:alert] = "The current password you entered is incorrect."
      goto_edit_password
    elsif @user.update(user_params)
      flash.now[:notice] = "Your password has been changed."
      goto_dashboard
    else
      goto_edit_password
    end
  end

  private
    def set_user
      @user = Current.user
    end

    def user_params
      params.permit(:password, :password_confirmation)
    end

    def goto_edit_password
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace("main_content", partial: "passwords/edit")
      ]
    end
end
