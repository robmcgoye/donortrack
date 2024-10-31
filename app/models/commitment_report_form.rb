class CommitmentReportForm
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Translation
  extend ActiveModel::Naming

  attr_accessor :format, :state, :sort

  # enum :format, { summary: 0, detailed: 1 }
  # enum :state, { open: 0, closed: 1 }
  # enum :sort, { alpha: 0, date: 1 }
  

  def initialize(attributes = {})
    # @errors = ActiveModel::Errors.new(self)
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    # self.unpaid ||= 1
  end

  def persisted?
    false
  end

  # def filter(foundation)
    
  # end

end