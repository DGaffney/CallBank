class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :remaining_hits
      t.datetime :reset_time
      t.string :token
      t.string :token_secret

      t.timestamps
    end
  end
end
