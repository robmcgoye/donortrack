class Fdn::OrganizationsController < Fdn::BaseController
  before_action :set_organization, only: %i[ show edit update destroy contributions commitments ]
  before_action :set_organization_filter_params, only: %i[ index sort show create destroy cancel update]

  def index
    render_main
  end

  def contributions
    render turbo_stream: turbo_stream.replace("organization-show-sub", partial: "contributions")
  end

  def commitments
    render turbo_stream: turbo_stream.replace("organization-show-sub", partial: "commitments")
  end

  def sort
    render_filter_results
  end

  def cancel
    if params[:id].to_i == -1
      render turbo_stream: [
        turbo_stream.replace(Organization.new, partial: "new_placeholder")
        # turbo_stream.replace(Organization.new, partial: "search", locals: {create: false})
      ]
    else
      set_organization
      render turbo_stream: [
        params[:show].to_i == 0 ?
        turbo_stream.replace(@organization, partial: "organization", locals: { organization: @organization, organization_counter: params[:index].to_i, page: params[:page] }) : turbo_stream.replace(@organization, partial: "show_details", locals: { organization: @organization, foundation: @foundation, page: @page, by: @by, dir: @dir, query: @query })
      ]
    end
  end

  def show
    render turbo_stream: [
      turbo_stream.replace("main_content", partial: "show", locals: { page: @page, by: @by, dir: @dir, query: @query })
    ]
  end

  def new
    if @foundation.organization_types.present?
      @organization = Organization.new
    else
      flash.now[:notice] = "Organization must have at least one organization type."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace(Organization.new, partial: "new_placeholder")
      ]
    end
  end

  def edit
  end

  def create
    @organization = @foundation.organizations.new(organization_params)
    if @organization.save
      flash.now[:notice] = "Organization was successfully created."
      render_filter_results(true)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @organization.update(organization_params)
      flash.now[:notice] = "Organization was successfully updated."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        params[:show].to_i == 0 ?
        turbo_stream.replace(@organization, partial: "organization", locals: { organization: @organization, page: params[:page] }) : turbo_stream.replace(@organization, partial: "show_details", locals: { organization: @organization, foundation: @foundation, page: @page, by: @by, dir: @dir, query: @query })
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @organization.destroy
      flash.now[:notice] = "Organization was successfully deleted."
      if params[:show] == 0
        render_filter_results
      else
        render_main
      end
    else
      flash.now[:notice] = "Organization has cleared contributions and cannot be deleted."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    end
  end

  private

    def render_main
      @pagy, @organizations = pagy(Organization.none)
      render turbo_stream: [
        turbo_stream.replace("main_content", partial: "index", locals: { page: @page, by: @by, dir: @dir, query: @query }),
        turbo_stream.replace("current-subpage", partial: "layouts/current_subpage", locals: { subpage_name: "Organizations" })
      ]
    end

    def render_filter_results(created_org = false)
      @pagy, @organizations = pagy(OrganizationsFilter.new.process_request(@foundation.organizations, @query, @by, @dir))
      if created_org
        render turbo_stream: [
          turbo_stream.replace("messages", partial: "layouts/messages"),
          turbo_stream.replace(Organization.new, partial: "new_placeholder"),
          turbo_stream.replace("organizations_list", partial: "organizations_list", locals: { organizations: @organizations })
        ]
      elsif flash.now[:notice].present?
        render turbo_stream: [
          turbo_stream.replace("messages", partial: "layouts/messages"),
          turbo_stream.replace("organizations_list", partial: "organizations_list", locals: { organizations: @organizations })
        ]
      else
        render turbo_stream: [
          turbo_stream.replace("organizations_list", partial: "organizations_list", locals: { organizations: @organizations })
        ]
      end
    end

    # def set_filter_params
    #   params[:page].blank? ? @page = "1" : @page = params[:page]
    #   params[:by].blank? ? @by = APP_CONSTANTS.organization.sort.name : @by = params[:by].to_i
    #   params[:dir].blank? ? @dir = APP_CONSTANTS.organization.sort_direction.up : @dir = params[:dir].to_i
    #   params[:query].blank? ? @query = "" : @query = params[:query]
    # end

    def set_organization
      @organization = Organization.find(params[:id])
    end

    def organization_params
      params.require(:organization).permit(:name, :tax_number, :contact, :address_1,
        :address_2, :city, :state, :zip, :country, :organization_type_id)
    end
end
