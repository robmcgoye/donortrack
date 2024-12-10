class Fdn::Donations::CommitmentsController < Fdn::BaseController
  # index, cancel, sort, new_contribution, new_next, show, new, edit, edit_contribution, create_contribution, create,
  # update, update_contribution, destroy, destroy_contribution

  before_action :set_commitment, except: %i[ index, cancel, sort, new_next, new, create ]
  before_action :set_contribution, only: [ :edit_contribution, :update_contribution, :destroy_contribution ]

  def index
    @pagy, @commitments = pagy(Commitment.none)
    render turbo_stream: [
      turbo_stream.replace("main_content", partial: "index"),
      turbo_stream.replace("current-subpage", partial: "layouts/current_subpage", locals: { subpage_name: "Contributions/Commitments" })
    ]
  end

  def cancel
    if params[:contribution].present?

      if params[:contribution].to_i  == -1
        render turbo_stream: [
          turbo_stream.replace(helpers.dom_id(Contribution.new, :commitment), partial: "new_contribution_placeholder")
        ]
      else
        @contribution = Contribution.find(params[:contribution])
        render turbo_stream: [
          turbo_stream.replace(helpers.dom_id(@contribution, :commitment), partial: "contribution", locals: { contribution: @contribution })
        ]
      end
    else
      if params[:id].to_i != -1
        # @commitment.reload
        render turbo_stream: [
          params[:show].to_i == 0 ? turbo_stream.replace(@commitment, partial: "commitment", locals: { commitment: @commitment }) : turbo_stream.replace(@commitment, partial: "show_commitment")
        ]
      else
        flash.now[:notice] = "New Commitment Wizard canceled."
        render turbo_stream: [
          turbo_stream.replace("messages", partial: "layouts/messages"),
          turbo_stream.replace(Commitment.new, partial: "new_placeholder")
        ]
      end
    end
  end

  def sort
    set_filter_params
    @pagy, @commitments = pagy(CommitmentsFilter.new.process_request(Commitment.organization_commitments(@foundation.organization_ids), @by, @dir))
    render turbo_stream: [
      turbo_stream.replace("commitment-list", partial: "commitment_list", locals: { commitments: @commitments })
    ]
  end

  def new_contribution
    @contribution = @commitment.contributions.new
    @contribution.organization = @commitment.organization
    @contribution.agreement_type = "Check"
    @contribution.build_agreement({})
  end

  def new_next
    if !params[:organization_id].blank?
      @organization = @foundation.organizations.where(id: params[:organization_id].to_i).take
      if @organization.present?
        @commitment = @organization.commitments.new
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
      turbo_stream.replace("commitments-main", partial: "show")
    ]
  end

  def new
    params[:query].blank? ?  @organizations = Organization.none : @organizations = @foundation.organizations.filter_by_name(params[:query]).sort_name_up
  end

  def edit
    @param_show = params[:show].to_i
  end

  def edit_contribution
  end

  def create_contribution
    @contribution = Contribution.new(contribution_params)
    if @contribution.save
      @commitment.reload
      flash.now[:notice] = "Payment was successfully applied to #{@contribution.commitment.code.truncate(10)}."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace("commitments-main", partial: "show"),
        turbo_stream.replace("commitment-payments", partial: "contributions_list", locals: { contributions: @commitment.contributions }),
        turbo_stream.replace(helpers.dom_id(Contribution.new, :commitment), partial: "new_contribution_placeholder")
      ]
    else
      render :new_contribution, status: :unprocessable_entity
    end
  end

  def create
    @commitment = Commitment.new(commitment_params)
    if @commitment.save
      @pagy, @commitments = pagy(Commitment.organization_commitments(@foundation.organization_ids))
      flash.now[:notice] = "Commitment was successfully created."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace(Commitment.new, partial: "new_placeholder"),
        turbo_stream.replace("commitment-list", partial: "commitment_list", locals: { commitments: @commitments })
      ]
    else
      render :new_next, status: :unprocessable_entity
    end
  end

  def update
    if @commitment.update(commitment_params)
      flash.now[:notice] = "Commitment was successfully updated."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        params[:commitment][:show] == "1" ?
        turbo_stream.replace(@commitment, partial: "show_commitment") : turbo_stream.replace(@commitment, partial: "commitment", locals: { commitment: @commitment })
      ]
    else
      @param_show = params[:commitment][:show].to_i
      render :edit, status: :unprocessable_entity
    end
  end

  def update_contribution
    if @contribution.update(contribution_params)
      # @commitment.reload
      flash.now[:notice] = "Contribution was successfully updated."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace(@commitment, partial: "show_commitment"),
        turbo_stream.replace(helpers.dom_id(@contribution, :commitment), partial: "contribution", locals: { contribution: @contribution })
      ]
    else
      render :edit_contribution, status: :unprocessable_entity
    end
  end

  def destroy
    if @commitment.destroy
      @pagy, @commitments = pagy(Commitment.organization_commitments(@foundation.organization_ids))
      flash.now[:notice] = "Commitment was successfully destroyed."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        params[:show].to_i == 1 ?
        turbo_stream.replace("main_content", partial: "index") : turbo_stream.replace("commitment-list", partial: "commitment_list", locals: { commitments: @commitments })
      ]
    else
      flash.now[:notice] = "Commitment cannot be destroyed since some payments have already been cleared."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    end
  end

  def destroy_contribution
    if @contribution.destroy
      @commitment.reload
      flash.now[:notice] = "Contribution was successfully destroyed."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages"),
        turbo_stream.replace("commitments-main", partial: "show"),
        turbo_stream.replace("commitment-payments", partial: "contributions_list", locals: { contributions: @commitment.contributions.reload })
      ]
    else
      flash.now[:alert] = "Contribution is already cleared cannot be deleted."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commitment
      if params[:commitment_id].present?
        @commitment = Commitment.find(params[:commitment_id])
      elsif params[:id].present? && params[:id].to_i != -1
        @commitment = Commitment.find(params[:id])
      end
    end

    def set_contribution
      @contribution = Contribution.find(params[:id])
    end

    def set_filter_params
      params[:page].blank? ? @page = "1" : @page = params[:page]
      params[:by].blank? ? @by = APP_CONSTANTS.commitment.sort.start_date : @by = params[:by].to_i
      params[:dir].blank? ? @dir = APP_CONSTANTS.commitment.sort_direction.up : @dir = params[:dir].to_i
    end

    # Only allow a list of trusted parameters through.
    def commitment_params
      params.require(:commitment).permit(:organization_id, :start_at, :end_at,
        :number_payments, :amount, :code)
    end

    def contribution_params
      params.require(:contribution).permit(:donor_id, :organization_id, :commitment_id, :agreement_type,
      agreement_attributes: [
            :id, :check_number, :transaction_at, :description, :amount, :bank_account_id, :funding_source_id
            ])
    end
end
