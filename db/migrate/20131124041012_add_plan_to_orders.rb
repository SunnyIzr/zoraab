class AddPlanToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :plan, :string
  end
end
