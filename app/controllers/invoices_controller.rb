class InvoicesController < ApplicationController

  def show
    @invoice = Invoice.find(params[:id])
    @shopify_skus = Shopify.all_products
  end

  def index
    @invoices = Invoice.paginate(:page => params[:page], :order => 'created_at DESC', :per_page => 30)
  end

  def new
    @invoice = Invoice.new
    3.times { @invoice.line_items.build }
  end
  
  def create
    skus = params[:skus]
    rates = params[:rates]
    qs = params[:qs]
    @invoice = Invoice.new(vendor: params[:invoice][:vendor],created_at: params[:invoice][:created_at], shipping:params[:invoice][:shipping], discount:params[:invoice][:discount])
    if @invoice.save
      @invoice.set_line_items(skus,rates,qs)
      @invoice.allocate_shipping
      @invoice.allocate_discount
      redirect_to invoice_path(@invoice)
    else
      render text: 'fail!'
    end
  end

  def check_product
    render json: Qb.product_exist?(params[:sku])
  end
  
  def check_all_products
    @invoice = Invoice.find(params[:id])
    render json: @invoice.items_not_in_qb
  end
  
  def save_to_qb
    @invoice = Invoice.find(params[:id])
    @invoice.save_to_qb
    redirect_to invoice_path(@invoice)
  end
  
  def vendors
    render json: Vendor.all
  end
   
  private
  def invoice_params
    params.permit(:invoice).permit(:created_at,:vendor,:shipping,:discount)
  end
end