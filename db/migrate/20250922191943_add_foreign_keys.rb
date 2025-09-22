class AddForeignKeys < ActiveRecord::Migration[8.0]
  def change
    # Add foreign key for products.ownerid -> users.id
    add_foreign_key :products, :users, column: :ownerid
    
    # Add foreign key for transactions.ownerid -> users.id
    add_foreign_key :transactions, :users, column: :ownerid
    
    # Add foreign key for transactions.productid -> products.id
    add_foreign_key :transactions, :products, column: :productid
    
    # Add indexes for better performance
    add_index :products, :ownerid
    add_index :transactions, :ownerid
    add_index :transactions, :productid
  end
end
