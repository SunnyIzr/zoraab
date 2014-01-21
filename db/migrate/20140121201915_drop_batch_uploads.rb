class DropBatchUploads < ActiveRecord::Migration
  def change
    drop_table :batch_uploads
  end
end
