class ContributionsFilter
  def process_request(contributions, sort, dir)
    if sort == ContributionConstants::COL_AMOUNT
      if dir == ContributionConstants::SORT_DES
        contributions.sort_amt_down
      else
        contributions.sort_amt_up
      end
    elsif sort == ContributionConstants::COL_TYPE
      if dir == ContributionConstants::SORT_DES
        contributions.sort_type_down
      else
        contributions.sort_type_up
      end
    elsif sort == ContributionConstants::COL_ORG
      if dir == ContributionConstants::SORT_DES
        contributions.sort_organization_down
      else
        contributions.sort_organization_up
      end
    elsif sort == ContributionConstants::COL_DONOR
      if dir == ContributionConstants::SORT_DES
        contributions.sort_donor_down
      else
        contributions.sort_donor_up
      end
    else
      # default sort is by date
      if dir == ContributionConstants::SORT_DES
        contributions.sort_date_down
      else
        contributions.sort_date_up
      end
    end
  end
end
