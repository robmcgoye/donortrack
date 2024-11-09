class UsersController < ApplicationController
  before_action :set_user, only: %i[ edit update destroy update_admin processed_admin ] # show
  before_action :check_permissions
  before_action :ensure_turbo_frame_request, except: [ :index, :update_admin, :processed_admin ]

  def index
    if turbo_stream_request?
      load_users
      render_index_stream
    else
      render_external_request_error
    end
  end

  def new
    @user = User.new
  end

  def edit
  end

  def cancel
    if params[:id].to_i == -1
      render turbo_stream: [
        turbo_stream.replace(User.new, partial: "users/new")
      ]
    else
      set_user
      render turbo_stream: [
        turbo_stream.replace(@user, partial: "users/user", locals: { user: @user, index: params[:index].to_i })
      ]
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      set_flash_message(:notice, "User was successfully created.")
      load_users
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace(User.new, partial: "users/new"),
        turbo_stream.replace("user_list", partial: "users/user_list")
      ]
    else
        render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      set_flash_message(:notice, "User was successfully updated.")
      render_update(@user, params[:user][:index].to_i)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_admin
    return unless turbo_stream_request?
    updater = AdminRoleUpdater.new(@user, params[:admin])
    updater.update
    render json: { success: true, message: updater.message, response_type: updater.message_type, userid: @user.id }
  end

  def processed_admin
    return unless turbo_stream_request?
    set_flash_message(params[:response_type].to_sym, params[:message])
    render turbo_stream: [
      turbo_stream.replace("messages", partial: "layouts/messages"),
      turbo_stream.replace("admin_button_#{@user.id}", partial: "admin_button", locals: { user: @user }),
      turbo_stream.replace("user_edit_header_#{@user.id}", partial: "edit_header", locals: { user: @user })
    ]
  end

  def destroy
    if @user != Current.user
      @user.destroy
      set_flash_message(:notice, "User was successfully deleted.")
      load_users
    else
      set_flash_message(:alert, "Can't delete your account.")
    end
    render turbo_stream: [
      turbo_stream.replace("messages", partial: "layouts/messages"),
      turbo_stream.replace("user_list", partial: "users/user_list")
    ]
  end

  private

    def set_flash_message(type, message)
      flash.now[type] = message
    end

    def load_users
      @users = User.all
    end

    def render_index_stream
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace("main_content", partial: "users/index")
      ]
    end

    def render_external_request_error
      set_error_10
      render layout: "layouts/errors/application", template: "errors/10"
    end

    def turbo_stream_request?
      request.headers["Accept"].include?("text/vnd.turbo-stream.html")
    end

    def set_user
      @user = User.find(params[:id])
    end

    def set_error_10
      @request_action = request.env["REQUEST_URI"]
      @error_code = "10"
      @error_message = "This is an internal request that somehow was accessed externally."
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end

    def check_permissions
      authorize :user, :crud_actions?
    end

    def render_update(user, index)
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace(user, partial: "users/user", locals: { user: user, index: index })
      ]
    end
    def ensure_turbo_frame_request
      unless turbo_frame_request?
        set_error_10
        render layout: "errors/application", template: "errors/show"
      end
    end
end
