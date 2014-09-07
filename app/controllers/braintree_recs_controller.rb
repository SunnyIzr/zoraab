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
  def mark_items_as_recd
    @braintree_rec = BraintreeRec.find(params[:id])
    items = params[:data]
    items.delete('on')
    items.each do |index|
      @braintree_rec.grouped_transactions[index.to_i][:recd] = true
    end
    @braintree_rec.save
    redirect_to disb_rec_path(@braintree_rec)
  end
  def trans_rec
    @braintree_rec = BraintreeRec.find(params[:id])
    if params[:bt_disb] && params[:bofa_disb]
      @braintree_rec.update_transactions(params[:bt_disb],params[:bofa_disb])
    end
    start_date = Date.parse('2014-2-15')
    end_date = Date.parse('2014-6-06')
    @bt_orders = @braintree_rec.grouped_transactions.map { |date| date[:orders] }.flatten
    @sub_orders = SubOrder.where(created_at: start_date..end_date,braintree_rec_id: nil).select{ |so| so.amt > 0 && so.trans_id != nil}.sort_by!{ |so| so.created_at}
    @zero_upfronts = UpfrontSubOrder.where(created_at: start_date..end_date,braintree_rec_id: nil).select{ |so| so.amt == 0}.sort_by{|so| so.created_at }
    @trans_ids = @bt_orders.map { |order| order[:trans_id] } + @sub_orders.map { |order| order.gateway_id }
    @trans_ids.flatten!
    @trans_ids = @trans_ids.uniq
    @matched_orders = []
    @missing_bt_orders = []
    @bt_orders.map{|order| order[:trans_id] }.each do |trans_id|
    if SubOrder.find_by(gateway_id: trans_id).present?
      @matched_orders << trans_id
    else
      @missing_bt_orders << trans_id
    end
    end
    @extra_sub_orders = []
    @sub_orders.each do |order|
      p order.gateway_id
      p @matched_orders.include?(order.gateway_id)
      unless @matched_orders.include?(order.gateway_id)
        @extra_sub_orders << order
      end
    end
  end
  
  def reconcile
    @braintree_rec = BraintreeRec.find(params[:id])
    reconciled_orders = params[:bt_trans]
    @braintree_rec.reconcile_orders(reconciled_orders)
    redirect_to upload_sub_orders_path
  end
    
  def upload
    @braintree_rec = BraintreeRec.find(params[:id])
    @orders = @braintree_rec.sub_orders.sort_by{ |order| order.order_number }
  end
  private
  def braintree_rec_params
    params.require(:braintree_rec).permit(:rec_date,:braintree_transactions,:bofa_transactions)
  end
  
end