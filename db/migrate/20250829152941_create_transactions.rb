class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.integer :ownerid
      t.integer :productid
      t.timestamp :date

      t.timestamps
    end
  end
end
