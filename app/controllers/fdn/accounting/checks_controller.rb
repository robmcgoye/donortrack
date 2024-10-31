class Fdn::Accounting::ChecksController < Fdn::BaseController
  before_action :set_bank_account, only: %i[ new index ]
  before_action :set_check, only: %i[ edit update destroy ]

  def index
    @checks = @bank_account.checks.open_deposits
  end

  def new
   @check = Check.new
  end

  def create
    @check = Check.new(check_params)
    @check.transaction_type = :credit
    if @check.save
      set_bank_account
      flash.now[:notice] = "Deposit was added."
      render turbo_stream: [
        turbo_stream.replace(@bank_account, partial: "fdn/accounting/bank_accounts/bank_account", locals: { bank_account: @bank_account }),
        turbo_stream.replace("bank-deposits", partial: "checks_list", locals: { checks: @bank_account.checks.open_deposits }),
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    else
      set_bank_account
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @check.update(check_params)
      flash.now[:notice] = "Deposit was successfully updated."
      render turbo_stream: [
        turbo_stream.replace(@bank_account, partial: "fdn/accounting/bank_accounts/bank_account", locals: { bank_account: @bank_account }),
        turbo_stream.replace("bank-deposits", partial: "checks_list", locals: { checks: @bank_account.checks.open_deposits }),
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if !@check.cleared
      @check.destroy
      flash.now[:notice] = "Deposit was successfully removed."
      render turbo_stream: [
        turbo_stream.replace(@bank_account, partial: "fdn/accounting/bank_accounts/bank_account", locals: { bank_account: @bank_account }),
        turbo_stream.replace("bank-deposits", partial: "checks_list", locals: { checks: @bank_account.checks.open_deposits }),
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    else
      flash.now[:notice] = "Deposit has already been cleared. Cannot remove."
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    end
  end

  private

  def set_check
    @check = Check.find(params[:id])
    @bank_account = @check.bank_account
    @foundation = @bank_account.foundation
  end

  def set_bank_account
    @bank_account = BankAccount.find(params[:bank_account_id])
  end

  def check_params
    params.require(:check).permit(:transaction_at, :description, :amount, :bank_account_id)
  end
end
