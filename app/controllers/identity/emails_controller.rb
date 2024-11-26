class Identity::EmailsController < ApplicationController
  include SessionManagement
  before_action :set_user

  def edit
    goto_edit_email
  end

  def update
    if !@user.authenticate(params[:current_password])
      flash.now[:alert] = "The password you entered is incorrect."
      goto_edit_email
    elsif @user.update(email: params[:email])
      redirect_to_root
    else
      goto_edit_email
    end
  end

  private
    def set_user
      @user = Current.user
    end

    def redirect_to_root
      if @user.email_previously_changed?
        resend_email_verification
        flash[:notice] = "Your email has been changed. Please sign back in"
        destroy_all_sessions_for(@user, redirect: true)
      else
        flash.now[:notice] = "Your email hasn't changed."
        render turbo_stream: [
          turbo_stream.replace("messages", partial: "layouts/messages"),
          turbo_stream.replace("main_content", partial: "identity/emails/edit")
        ]
      end
    end

    def resend_email_verification
      UserMailer.with(user: @user).email_verification.deliver_later
    end

    def goto_edit_email
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace("current-subpage", partial: "layouts/current_subpage", locals: { subpage_name: "Change Email" }),
        turbo_stream.replace("main_content", partial: "identity/emails/edit")
      ]
    end
end
