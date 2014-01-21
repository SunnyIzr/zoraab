class CreateBatchUploads < ActiveRecord::Migration
  def change
    create_table :batch_uploads do |t|
      t.timestamps
    end
  end
end
