class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :uid, null: false, unique: true
      t.string :name, null: false
      t.string :nickname, null: false
      t.string :image, null: false
      t.integer :power
      t.text :profile
      t.string :friend_code
      t.timestamps
    end
  end
end
