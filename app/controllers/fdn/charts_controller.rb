class Fdn::ChartsController < Fdn::BaseController
  def top_donors
    render json: @foundation.donors.top_donors
  end

  def contribution_time_line
    render json: (Contribution.organization_contributions(@foundation.organization_ids)).graph_contributions
  end
end
