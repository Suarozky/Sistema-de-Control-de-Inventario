class CreateInitialSchema < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :lastname, null: false
      t.integer :role, default: 0, null: false
      t.timestamps
    end
    
    create_table :brands do |t|
      t.string :name
      t.timestamps
    end
    
    create_table :models do |t|
      t.string :name
      t.timestamps
    end
    
    create_table :products do |t|
      t.string :model
      t.string :brand
      t.datetime :entry_date
      t.integer :ownerid
      t.timestamps
    end
    
    create_table :transactions do |t|
      t.integer :ownerid
      t.integer :productid
      t.datetime :date
      t.timestamps
    end
    
    # Índices únicos
    add_index :users, [:name, :lastname], unique: true
  end
end