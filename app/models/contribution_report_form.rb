class ContributionReportForm
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Translation
  extend ActiveModel::Naming

  attr_accessor :funds, :starting_date, :ending_date, :donors, :types

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    self.funds = funds.reject(&:blank?)&.uniq unless funds.nil?
    self.donors = donors.reject(&:blank?)&.uniq unless donors.nil?
    self.types = types.reject(&:blank?)&.uniq unless types.nil?
  end

  def persisted?
    false
  end

end