class Product < ApplicationRecord
  belongs_to :owner, class_name: "User", foreign_key: "ownerid", optional: false
  has_many :transactions, foreign_key: :productid

  # Agregar validaciones
  validates :model, presence: true
  validates :brand, presence: true
  validates :entry_date, presence: true
end