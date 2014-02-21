class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.string :po_number
      t.string :vendor
      t.float :total
      t.float :shipping
      t.float :discount
      t.timestamps
    end
  end
end
