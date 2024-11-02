class CommitmentsFilter
  def initialize
    @sort_by = { start_date: APP_CONSTANTS.commitment.sort.start_date,
                  end_date: APP_CONSTANTS.commitment.sort.end_date,
                  payment: APP_CONSTANTS.commitment.sort.payment,
                  organization: APP_CONSTANTS.commitment.sort.organization
                }
    @sort_direction = { up: APP_CONSTANTS.commitment.sort_direction.up,
                        down: APP_CONSTANTS.commitment.sort_direction.down
                      }
  end

  def process_request(commitments, sort, dir)
    if sort == @sort_by[:end_date]
      if dir == @sort_direction[:down]
        commitments.sort_end_date_down
      else
        commitments.sort_end_date_up
      end
    elsif sort == @sort_by[:payment]
      if dir == @sort_direction[:down]
        commitments.sort_payment_down
      else
        commitments.sort_payment_down
      end
    elsif sort == @sort_by[:organization]
      if dir == @sort_direction[:down]
        commitments.sort_organization_down
      else
        commitments.sort_organization_up
      end
    else
      # default sort is by start_date
      if dir == @sort_direction[:down]
        commitments.sort_start_date_down
      else
        commitments.sort_start_date_up
      end
    end
  end
end
