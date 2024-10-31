class Fdn::BaseController < ApplicationController
  before_action :set_foundation

  def set_organization_filter_params
    params[:page].blank? ? @page = "1" : @page = params[:page]
    params[:by].blank? ? @by = APP_CONSTANTS.organization.sort.name : @by = params[:by].to_i
    params[:dir].blank? ? @dir = APP_CONSTANTS.organization.sort_direction.up : @dir = params[:dir].to_i
    params[:query].blank? ? @query = "" : @query = params[:query]
  end

  private
  def set_foundation
    @foundation = Foundation.find(params[:foundation_id]) if params[:foundation_id].present?
  end
end
