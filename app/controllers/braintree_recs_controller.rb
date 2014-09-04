class BraintreeRecsController < ApplicationController
  def disb_rec
    @braintree_rec = BraintreeRec.find(params[:id])
  end
  def upload_braintree
    @braintree_rec = BraintreeRec.new
  end
  def create
    file = params[:braintree_rec][:transactions]
    @braintree_rec = BraintreeRec.create(rec_date: params[:braintree_rec][:rec_date])
    @braintree_rec.import_csv(file.path)
    @braintree_rec.group_transactions
    redirect_to disb_rec_path(@braintree_rec)
  end
  private
  def braintree_rec_params
    params.require(:braintree_rec).permit(:rec_date,:transactions)
  end
  
end