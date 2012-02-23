class AddUserAttributes < ActiveRecord::Migration
  def up
    add_column :users, :hourly_limit, :integer
  end

  def down
    drop_column :users, :hourly_limit, :integer
  end
end
