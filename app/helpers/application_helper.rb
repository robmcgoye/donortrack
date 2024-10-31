module ApplicationHelper
  include Pagy::Frontend

  def get_select_options_for_organization_types(foundation, include_all = false)
    results = foundation.organization_types.sort_code_up.collect {
      |p| [ "#{p.code} - #{truncate(p.description, 9)}", p.id ]
    }
    results.unshift([ "ALL Types", 0 ]) if include_all
    # return results
  end

  def get_select_options_for_donors(foundation, include_all = false)
    results = foundation.donors.sort_full_name_up.collect {
      |p| [ p.full_name, p.id ]
    }
    results.unshift([ "ALL Donors", 0 ]) if include_all
    # return results
  end

  def get_select_options_for_funding_sources(foundation, include_all = false)
    results = FundingSource.where(foundation_id: foundation).sort_code_up.collect {
      |p| [ "#{p.code} - #{truncate(p.short_name, 8)}", p.id ]
    }
    results.unshift([ "ALL Funds", 0 ]) if include_all
    # return results
  end

  def truncate(string, max)
    string.length > max ? "#{string[0...max]}..." : string
  end

  def get_id(model)
    model.id.nil? ? -1 : model.id
  end
end
