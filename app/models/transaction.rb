class Transaction < ApplicationRecord
    belongs_to :product, foreign_key: :productid
    belongs_to :owner, class_name: "User", foreign_key: :ownerid
end

