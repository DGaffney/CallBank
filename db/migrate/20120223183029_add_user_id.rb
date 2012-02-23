class AddUserId < ActiveRecord::Migration
  def up
    add_column :users, :twitter_id, :integer
  end

  def down
    drop_column :users, :twitter_id
  end
end
