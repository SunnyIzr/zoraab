class BraintreeRecsController < ApplicationController
  def disb_rec
    @braintree_rec = BraintreeRec.find(params[:id])
  end
  def upload_braintree
    @braintree_rec = BraintreeRec.new
  end
  def create
    @braintree_rec = BraintreeRec.create(rec_date: params[:braintree_rec][:rec_date])
    braintree_file = params[:braintree_rec][:braintree_transactions]
    @braintree_rec.import_braintree(braintree_file.path)
    @braintree_rec.group_transactions
    bofa_file = params[:braintree_rec][:bofa_transactions]
    @braintree_rec.import_bofa(bofa_file.path)
    redirect_to disb_rec_path(@braintree_rec)
  end
  private
  def braintree_rec_params
    params.require(:braintree_rec).permit(:rec_date,:braintree_transactions,:bofa_transactions)
  end
  
end