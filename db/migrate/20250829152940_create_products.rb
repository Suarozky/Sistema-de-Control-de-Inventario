class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :model
      t.string :brand
      t.timestamp :entry_date
      t.integer :ownerid

      t.timestamps
    end
  end
end
