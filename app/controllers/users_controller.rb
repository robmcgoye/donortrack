class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]
  before_action :check_permissions

  def index
    @users = User.all
    render turbo_stream: [
      turbo_stream.replace("messages", partial: "layouts/messages"),
      turbo_stream.replace("main_content", partial: "users/index")
    ]
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
      flash.now[:notice] = "User was successfully created."
      @users = User.all
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
    if Current.user == @user && params[:user][:admin].to_i == 0
      flash.now[:alert] = "Can't remove admin rights from the currently logged on user."
      render_update(@user, params[:user][:index].to_i)
    else
      if @user.update(user_params)
        flash.now[:notice] = "User was successfully updated."
        render_update(@user, params[:user][:index].to_i)
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    if @user != Current.user
      @user.destroy
      flash.now[:notice] = "User was successfully deleted."
      @users = User.all
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace("user_list", partial: "users/user_list")
      ]
    else
      flash.now[:alert] = "Can't delete your account."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :admin)
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
end
