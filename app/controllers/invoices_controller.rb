class InvoicesController < ApplicationController

  def show
    @invoice = Invoice.find(params[:id])
  end

  def index
    @invoices = Invoice.paginate(:page => params[:page], :order => 'created_at DESC', :per_page => 30)
  end

  def new
    @invoice = Invoice.new
    3.times { @invoice.line_items.build }
  end
  
  def create
    p '*'*100
    p params
    skus = params[:skus]
    rates = params[:rates]
    qs = params[:qs]
    @invoice = Invoice.new(vendor: params[:invoice][:vendor],created_at: params[:invoice][:created_at])
    if @invoice.save
      @invoice.set_line_items(skus,rates,qs)
      redirect_to invoice_path(@invoice)
    else
      render text: 'fail!'
    end
    
    
    
  end
  
  private
  def invoice_params
    params.permit(:invoice).permit(:created_at,:vendor)
  end
end