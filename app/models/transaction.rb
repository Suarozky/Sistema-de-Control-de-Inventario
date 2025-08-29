class Transaction < ApplicationRecord
    belongs_to :product, foreign_key: :productid
end

