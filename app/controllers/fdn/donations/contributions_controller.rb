class Fdn::Donations::ContributionsController < Fdn::BaseController
  before_action :set_contribution, only: %i[ show edit update destroy ]
  before_action :set_filter_params, only: %i[ cancel sort destroy]

  def index
    @pagy, @contributions = pagy(Contribution.none)
    render turbo_stream: [
      turbo_stream.replace("main_content", partial: "index"),
      turbo_stream.replace("current-subpage", partial: "layouts/current_subpage", locals: { subpage_name: "Contributions" })
    ]
  end

  def cancel
    if params[:id].to_i != -1
      set_contribution
      render turbo_stream: [
        params[:show].to_i ==  ContributionConstants::SHOW_OFF ?
        turbo_stream.replace(@contribution, partial: "contribution", locals: { contribution: @contribution, contribution_counter: params[:index].to_i, page: 1 }) : turbo_stream.replace(@contribution, partial: "show")
      ]
    else
      flash.now[:notice] = "New Contribution Wizard canceled."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace(Contribution.new, partial: "new_button")
      ]
    end
  end

  def sort
    @pagy, @contributions = pagy(ContributionsFilter.new.process_request(Contribution.organization_contributions(@foundation.organization_ids).open_contributions, @by, @dir))
    # @pagy, @contributions = pagy(ContributionsFilter.new.process_request(Contribution.organization_contributions(@foundation.organization_ids).open_contributions, @by, @dir))
    render turbo_stream: [
      turbo_stream.replace("contribution-list", partial: "contribution_list", locals: { contributions: @contributions })
    ]
  end

  def show_filter
    render turbo_stream: [
      turbo_stream.replace("contribution-filter", partial: "show_filter")
    ]
  end
  def new_next
    if !params[:organization_id].blank?
      @organization = @foundation.organizations.where(id: params[:organization_id].to_i).take

      if @organization.present? && (Contribution.get_agreement_options.include? params[:contribution_type])
        @contribution = @organization.contributions.new
        @contribution.agreement_type = params[:contribution_type]
        @contribution.build_agreement({})

      else
        flash.now[:alert] = "Organization selected was not found!!."
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Error with wizard no organization selected!"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    render turbo_stream: [
      turbo_stream.replace("contributions-main", partial: "show")
    ]
  end

  def new
    @errors = []
    unless @foundation.donors.exists?
      @errors << "You must create a donor before creating a contribution."
    end
    unless @foundation.funding_sources.exists?
      @errors << "You must create a funding source before creating a contribution."
    end
    unless @foundation.bank_accounts.exists?
      @errors << "You must create a bank account before creating a contribution."
    end
  end

  def edit
    @param_show = params[:show].to_i
    @param_index = params[:index].to_i
  end

  def create
    @contribution = Contribution.new(contribution_params)
    if @contribution.save
      @pagy, @contributions = pagy(Contribution.organization_contributions(@foundation.organization_ids).open_contributions.sort_date_up)
      # @pagy, @contributions = pagy(Contribution.organization_contributions(@foundation.organization_ids).open_contributions.sort_date_up)
      flash.now[:notice] = "Contribution was successfully created."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace(Contribution.new, partial: "new_button"),
        turbo_stream.replace("contribution-list", partial: "contribution_list", locals: { contributions: @contributions })
      ]
    else
      render :new_next, status: :unprocessable_entity
    end
  end

  def update
    if @contribution.update(contribution_params)
      flash.now[:notice] = "Contribution was successfully updated."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        params[:contribution][:show].to_i ==  ContributionConstants::SHOW_ON ?
        turbo_stream.replace(@contribution, partial: "show") : turbo_stream.replace(@contribution, partial: "contribution", locals: { contribution: @contribution, contribution_counter: params[:contribution][:index].to_i, page: 1 })
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @contribution.destroy
      @pagy, @contributions = pagy(Contribution.organization_contributions(@foundation.organization_ids).open_contributions.sort_date_up)
      @pagy, @contributions = pagy(ContributionsFilter.new.process_request(Contribution.organization_contributions(@foundation.organization_ids), @by, @dir))
      flash.now[:notice] = "Contribution was successfully destroyed."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        params[:show].to_i == ContributionConstants::SHOW_ON ?
        turbo_stream.replace("main_content", partial: "index") : turbo_stream.replace("contribution-list", partial: "contribution_list", locals: { contributions: @contributions })
      ]
    else
      flash.now[:notice] = "Contribution is already cleared cannot be deleted."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    end
  end

  private

    def set_filter_params
      params[:page].blank? ? @page = "1" : @page = params[:page]
      params[:by].blank? ? @by = ContributionConstants::COL_DATE : @by = params[:by].to_i
      params[:dir].blank? ? @dir = ContributionConstants::SORT_ASC : @dir = params[:dir].to_i
    end

    def set_contribution
      @contribution = Contribution.find(params[:id])
    end

    def contribution_params
      params.require(:contribution).permit(:donor_id, :agreement_type, :organization_id,
        agreement_attributes: [
            :id, :check_number, :transaction_at, :description, :amount, :bank_account_id, :funding_source_id, :value, :type_of
            ])
    end
end
