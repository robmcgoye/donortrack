class Fdn::Accounting::BankAccountsController < Fdn::BaseController
  before_action :set_bank_account, only: %i[ show edit update destroy ]

  def index
    @bank_accounts = @foundation.bank_accounts
    @primary_account = @bank_accounts.where(primary: true).take
    render turbo_stream: [
      turbo_stream.replace("main_content", partial: "index")
    ]
  end

  def show
    render turbo_stream: [
      turbo_stream.replace("bank_account_main", partial: "main", locals: { bank_account: @bank_account })
    ]
  end

  def new
    @bank_account = BankAccount.new
  end

  def cancel
    if params[:id].to_i != -1
      set_bank_account
      render turbo_stream: [
        turbo_stream.replace(@bank_account, partial: "bank_account", locals: { bank_account: @bank_account })
      ]
    else
      render turbo_stream: [
        turbo_stream.replace(BankAccount.new, partial: "new_button", locals: { bank_accounts: @foundation.bank_accounts })
      ]
    end
  end

  def edit
  end

  def create
    @bank_account = @foundation.bank_accounts.new(bank_account_params)
    if @bank_account.save
      flash.now[:notice] = "Bank account was successfully created."
      render turbo_stream: [
        turbo_stream.replace(BankAccount.new, partial: "new_button", locals: { bank_accounts: @foundation.bank_accounts }),
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @bank_account.update(bank_account_params)
      flash.now[:notice] = "Bank account was successfully updated."
      render turbo_stream: [
        turbo_stream.replace(BankAccount.new, partial: "new_button", locals: { bank_accounts: @foundation.bank_accounts }),
        turbo_stream.replace("bank_account_main", partial: "main", locals: { bank_account: @bank_account }),
        # turbo_stream.replace("bank_account_main", partial: "main", locals: { bank_account: @bank_account, checks: @bank_account.checks }),
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @bank_account.destroy
      flash.now[:notice] = "Bank account was successfully deleted."
      render turbo_stream: [
        turbo_stream.replace(BankAccount.new, partial: "new_button", locals: { bank_accounts: @foundation.bank_accounts }),
        turbo_stream.replace("bank_account_main", partial: "main_empty"),
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    else
      flash.now[:notice] = "Bank account cannot be deleted. Because it has transactions"
      render turbo_stream: [
        turbo_stream.replace("messages", partial: "layouts/messages")
      ]
    end
  end

  private

    def set_bank_account
      @bank_account = BankAccount.find(params[:id])
    end

    def bank_account_params
      params.require(:bank_account).permit(:full_name, :primary, :starting_balance)
    end
end
