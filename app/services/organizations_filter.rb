class OrganizationsFilter
  def initialize
    @sort_by = { names: APP_CONSTANTS.organization.sort.name,
                  contacts: APP_CONSTANTS.organization.sort.contact,
                  types: APP_CONSTANTS.organization.sort.type
                }
    @sort_direction = { up: APP_CONSTANTS.organization.sort_direction.up,
                        down: APP_CONSTANTS.organization.sort_direction.down
                      }
  end

  def process_request(orgs, query, sort, dir)
    if query.present?
      orgs = orgs.filter_by_name(query)
    end
    if sort == @sort_by[:contacts]
      if dir == @sort_direction[:down]
        orgs.sort_contact_down
      else
        orgs.sort_contact_up
      end
    elsif sort == @sort_by[:types]
      if dir == @sort_direction[:down]
        orgs.sort_type_down
      else
        orgs.sort_type_up
      end
    else
      # default sort is by name
      if dir == @sort_direction[:down]
        orgs.sort_name_down
      else
        orgs.sort_name_up
      end
    end
  end
end
