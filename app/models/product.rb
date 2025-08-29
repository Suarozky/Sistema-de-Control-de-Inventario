
class Product < ApplicationRecord
  belongs_to :owner, class_name: "User", foreign_key: "ownerid", optional: true
     has_many :transactions, foreign_key: :productid

   


end

