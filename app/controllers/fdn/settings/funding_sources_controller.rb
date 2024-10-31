class Fdn::Settings::FundingSourcesController < Fdn::BaseController
  before_action :set_funding_source, only: %i[ edit update destroy ]

  def index
    render turbo_stream: [
      turbo_stream.replace("main_content", partial: "index")
    ]
  end

  def new
    @funding_source = FundingSource.new
  end

  def edit
  end

  def create
    @funding_source = @foundation.funding_sources.new(funding_source_params)
    if @funding_source.save
      flash.now[:notice] = "Funding source was successfully created."
      render turbo_stream: [
        turbo_stream.prepend("funding_sources", @funding_source),
        turbo_stream.replace("form_funding_source",
          partial: "form",
          locals: { funding_source: FundingSource.new, form_url: foundation_settings_funding_sources_path(@foundation) }),
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @funding_source.update(funding_source_params)
      flash.now[:notice] = "Funding source was successfully updated."
      render turbo_stream: [
        turbo_stream.replace(@funding_source, @funding_source),
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @funding_source.destroy
      flash.now[:notice] = "Funding source was successfully deleted."
      render turbo_stream: [
        turbo_stream.remove(@funding_source),
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    else
      flash.now[:alert] = "Error this fund has contribution(s)."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    end
  end

  private

    def set_funding_source
      @funding_source = FundingSource.find(params[:id])
    end

    def funding_source_params
      params.require(:funding_source).permit(:code, :short_name, :full_name)
    end
end
