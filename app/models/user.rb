class User < ApplicationRecord
  # Validación combinada: no permitir nombre + apellido iguales a otro usuario
  enum :role, { user: 0, admin: 1 }
  validates :name, uniqueness: { scope: :lastname, message: "y apellido ya existen" }
  has_many :products, foreign_key: "ownerid"
end