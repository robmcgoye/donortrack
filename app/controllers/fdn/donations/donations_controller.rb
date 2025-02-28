class Fdn::Donations::DonationsController < Fdn::BaseController
  def new_organization
    if @foundation.organization_types.present?
      @organization = Organization.new
      render turbo_stream: turbo_stream.replace("contribution_organization_choice", partial: "fdn/donations/new_organization")
    else
      render turbo_stream: turbo_stream.replace("contribution_organization_choice", partial: "fdn/donations/no_organization_type")
    end
  end

  def existing_organization
    render turbo_stream: turbo_stream.replace("contribution_organization_choice", partial: "fdn/donations/existing_organization", locals: { filter_url: foundation_donations_filter_organizations_path(@foundation) })
  end

  def filter_organizations
    params[:query].blank? ?  @organizations = Organization.none : @organizations = @foundation.organizations.filter_by_name(params[:query]).sort_name_up
    render turbo_stream: turbo_stream.replace("organizations-filter", partial: "fdn/donations/organizations_filter", locals: { organizations: @organizations })
  end

  def create_organization
    @organization = @foundation.organizations.new(organization_params)
    if @organization.save
      flash.now[:notice] = "Organization was successfully created."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace("contribution_organization_choice", partial: "fdn/donations/show_new_organization")
      ]
    else
      render turbo_stream: turbo_stream.replace("contribution_organization_choice", partial: "fdn/donations/new_organization"), status: :unprocessable_entity
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :tax_number, :contact, :address_1,
      :address_2, :city, :state, :zip, :country, :organization_type_id)
  end
end
