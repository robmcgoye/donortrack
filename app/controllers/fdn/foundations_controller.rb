class Fdn::FoundationsController < ApplicationController
  before_action :set_foundation, only: %i[ edit update destroy settings dashboard remove_image_logo remove_image_header ]
  before_action :check_permissions, only: %i[ new create edit update destroy remove_image_logo remove_image_header ]

  def index
    @foundations = Foundation.all
  end

  def dashboard
    render turbo_stream: [
      turbo_stream.replace("sidebar-frame", partial: "layouts/sidebar", locals: { foundation: @foundation }),
      # turbo_stream.replace("sidebar-button", partial: "layouts/sidebar_button", locals: { name: @foundation.short_name }),
      turbo_stream.replace("main_content", partial: "dashboard")
    ]
  end

  def settings
    render turbo_stream: [
      turbo_stream.replace("main_content", partial: "fdn/settings/index")
    ]
  end

  def new
    @foundation = Foundation.new
  end

  def edit
  end

  def cancel
    target = request.headers["Turbo-Frame"]
    if target.start_with? "foundation_"
      partial = "fdn/settings/show_foundation"
      @foundation = Foundation.find(target[11, target.length].to_i)
    else
      partial = "create"
    end
    render turbo_stream: [
      turbo_stream.replace(target, partial: partial)
    ]
  end

  def create
    @foundation = Foundation.new(foundation_params)
      if @foundation.save
        flash.now[:notice] = "Foundation was successfully created."
        @foundations = Foundation.all
        render turbo_stream: [
          turbo_stream.replace("messages", partial: "layouts/messages"),
          turbo_stream.replace(Foundation.new, partial: "create"),
          turbo_stream.replace("foundations-nav-list", partial: "layouts/foundations_list", locals: { foundations: @foundations }),
          turbo_stream.replace("foundation_list", partial: "foundation_list")
        ]
      else
        render :new, status: :unprocessable_entity
      end
  end

  def update
    if @foundation.update(foundation_params)
      flash.now[:notice] = "Foundation was successfully updated."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace("sidebar-button", partial: "layouts/sidebar_button", locals: { name: @foundation.short_name }),
        turbo_stream.replace("foundations-nav-list", partial: "layouts/foundations_list", locals: { foundations: Foundation.all }),
        turbo_stream.replace(@foundation, partial: "fdn/settings/show_foundation")
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @foundation.destroy
    redirect_to root_url, notice: "Foundation was successfully destroyed."
  end

  def remove_image_logo
    @foundation.image_logo.purge
    @foundation.reload
    flash.now[:notice] = "Removed logo"
    render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace(@foundation, partial: "fdn/settings/show_foundation")
    ]
  end

  def remove_image_header
    @foundation.image_header.purge
    @foundation.reload
    flash.now[:notice] = "Removed header"
    render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace(@foundation, partial: "fdn/settings/show_foundation")
    ]
  end

  private
    def set_foundation
      if params[:foundation_id].present?
        @foundation = Foundation.find(params[:foundation_id])
      else
        @foundation = Foundation.find(params[:id])
      end
    end

    def check_permissions
      authorize :user, :crud_actions?
    end

    def foundation_params
      params.require(:foundation).permit(:short_name, :long_name, :image_logo, :image_header)
    end
end
