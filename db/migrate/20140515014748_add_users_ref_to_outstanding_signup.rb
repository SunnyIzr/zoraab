class AddUsersRefToOutstandingSignup < ActiveRecord::Migration
  def change
    add_column :outstanding_signups, :users_ref, :integer
  end
end
