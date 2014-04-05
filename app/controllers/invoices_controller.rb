class InvoicesController < ApplicationController
  def show
    @invoice = Invoice.find(params[:id])
  end
  def index
    @invoices = Invoice.paginate(:page => params[:page], :order => 'created_at DESC', :per_page => 30)
  end
end