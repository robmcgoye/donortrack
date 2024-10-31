class Fdn::Settings::DonorsController < Fdn::BaseController
  before_action :set_donor, only: %i[ edit update destroy ]

  def index
    render turbo_stream: [
      turbo_stream.replace("main_content", partial: "index")
    ]
  end

  def new
    @donor = Donor.new
  end

  def edit
  end

  def create
    @donor = @foundation.donors.new(donor_params)
    if @donor.save
      flash.now[:notice] = "Donor was successfully created."
      render turbo_stream: [
        turbo_stream.prepend("donors", @donor),
        turbo_stream.replace("form_donor",
          partial: "form",
          locals: { donor: Donor.new, form_url: foundation_settings_donors_path(@foundation) }),
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @donor.update(donor_params)
      flash.now[:notice] = "Donor was successfully updated."
      render turbo_stream: [
        turbo_stream.replace(@donor, @donor),
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @donor.destroy
      flash.now[:notice] = "Donor was successfully deleted."
      render turbo_stream: [
        turbo_stream.remove(@donor),
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    else
      flash.now[:alert] = "Error this donor has contributions and or commitments."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    end
  end

  private

    def set_donor
      @donor = Donor.find(params[:id])
    end

    def donor_params
      params.require(:donor).permit(:code, :full_name)
    end
end
