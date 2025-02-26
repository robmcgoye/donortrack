class Fdn::Donations::DonationsController < Fdn::BaseController
  def new_organization
    if @foundation.organization_types.present?
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
  end
end
