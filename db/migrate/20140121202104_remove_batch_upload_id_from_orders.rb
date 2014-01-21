class RemoveBatchUploadIdFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :batch_upload_id
  end
end
