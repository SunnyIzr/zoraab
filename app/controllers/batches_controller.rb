class BatchesController < ApplicationController
  def show
    @batch = Batch.find(params[:id])
    @product_data = @batch.get_prod_data
    respond_to do |format|
      format.html
      format.csv { send_data @batch.to_csv }
    end
  end

  def index
    @batches = Batch.all
  end

  def new
    Batch.destroy_empty_batches
    @batch = Batch.create
    setup_batch = @batch.setup_new(params['subs'])
    @subs = setup_batch[:subs]
    @orders = setup_batch[:orders]
  end

end
