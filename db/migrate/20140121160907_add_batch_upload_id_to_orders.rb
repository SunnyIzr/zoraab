class AddBatchUploadIdToOrders < ActiveRecord::Migration
  def change
    add_reference :orders, :batch_upload, index: true
  end
end
