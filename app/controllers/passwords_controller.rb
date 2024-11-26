class PasswordsController < ApplicationController
  include SessionManagement
  before_action :set_user

  def edit
    goto_edit_password
  end

  def update
    if !@user.authenticate(params[:current_password])
      flash.now[:alert] = "The current password you entered is incorrect."
      goto_edit_password
    elsif @user.update(user_params)
      flash[:notice] = "Your password has been changed. Please sign back in."
      destroy_all_sessions_for(Current.user, redirect: true)
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
        turbo_stream.replace("current-subpage", partial: "layouts/current_subpage", locals: { subpage_name: "Change Password" }),
        turbo_stream.replace("main_content", partial: "passwords/edit")
      ]
    end
end
