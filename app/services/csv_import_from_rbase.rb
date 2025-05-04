
class CsvImportFromRbase
  CSV_FILES = {
    donors: Rails.root.join("lib/seeds/donors.txt"),
    organization_types: Rails.root.join("lib/seeds/organization_types.txt"),
    funding_sources: Rails.root.join("lib/seeds/funding_sources.txt"),
    organizations: Rails.root.join("lib/seeds/organizations.txt")
  }.freeze
  IMPORT_ERROR_LOG = Logger.new("log/import_errors.log")


  def initialize(foundation_id) @foundation = Foundation.find(foundation_id) end

    def import_all
      @foundation.organizations.destroy_all
      @foundation.bank_accounts.each do |bank_account|
        Check.where(bank_account_id: bank_account.id).destroy_all
        Reconciliation.where(bank_account_id: bank_account.id).destroy_all
        bank_account.destroy
      end
      # @foundation.bank_accounts.destroy_all
      @foundation.donors.delete_all
      @foundation.organization_types.delete_all
      @foundation.funding_sources.delete_all
      CSV_FILES.each do |csv_name, file_path|
        import_file(csv_name, file_path)
      end
    end

    private

    def import_file(csv_name, file_path)
      case csv_name
      when :donors
        import_donors(file_path)
      when :organization_types
        import_organization_types(file_path)
      when :funding_sources
        import_funding_sources(file_path)
      when :organizations
        import_organizations(file_path)
      end
    end
    def import_donors(file_path)
      CSV.foreach(file_path, headers: true) do |row|
        donor = @foundation.donors.new
        donor.full_name = row["ReqByName"]
        donor.code = row["ReqBy"]
        if donor.valid?
          donor.save
        else
          IMPORT_ERROR_LOG.error "Validation error: #{donor.errors.full_messages.join(', ')}"
        end
      end
    end
    def import_organization_types(file_path)
      CSV.foreach(file_path, headers: true) do |row|
        organization_type = @foundation.organization_types.new
        organization_type.code = row["TypeX"]
        organization_type.description = row["TYPEORG"]
        if organization_type.valid?
          organization_type.save
        else
          IMPORT_ERROR_LOG.error "Validation error: #{organization_type.errors.full_messages.join(', ')}"
        end
      end
    end
    def import_funding_sources(file_path)
      CSV.foreach(file_path, headers: true) do |row|
        funding_source = @foundation.funding_sources.new
        funding_source.code = row["FDN_I_D_"]
        funding_source.short_name = row["FDNNAME"]
        funding_source.full_name = row["FDBIGNAM"]
        if funding_source.valid?
          funding_source.save
        else
          IMPORT_ERROR_LOG.error "Validation error: #{funding_source.errors.full_messages.join(', ')}"
        end
      end
    end
    def import_organizations(file_path)
      CSV.foreach(file_path, headers: true) do |row|
        organization = @foundation.organizations.new
        organization.name = row["organ_"]
        organization.address_1 = row["ADDRESS"]
        organization.address_2 = row["ADDRESS2"]
        organization.city = row["CITY"]
        organization.state = row["STATE"]
        organization.zip = row["ZIP"]
        organization.country = row["COUNTRY"]
        organization.contact = row["CONTACT1"]
        organization.tax_number = row["TAXID"]
        if row["TypeX"] == "CHU"
          code = "REL"
        else
          code = row["TypeX"]
        end
        organization_type = @foundation.organization_types.where("code ILIKE ?", code).first
        if organization_type.nil?
          IMPORT_ERROR_LOG.error "Organization type not found for code: #{code}"
        else
          organization.organization_type_id = organization_type.id
        end
        # organization.organization_type_id = @foundation.organization_types.find_by(code: row["TypeX"]).id
        # organization.funding_source_id = @foundation.funding_sources.find_by(code: row["FDN_I_D_"]).id
        if organization.valid?
          organization.save
        else
          IMPORT_ERROR_LOG.error "Validation error: #{organization.errors.full_messages.join(', ')}"
        end
      end
    end
end
