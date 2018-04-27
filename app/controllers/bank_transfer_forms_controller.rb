class BankTransferFormsController < FormsController
  def new
    super(BankTransferForm, "bank_transfer_form")
  end

  def create
    super(BankTransferForm, "bank_transfer_form")
  end
end
