# db/seeds.rb

puts "🗑️ Limpiando base de datos..."
Transaction.delete_all
Product.delete_all
Model.delete_all
Brand.delete_all
User.delete_all

puts "👥 Creando usuarios..."
# Usuarios con roles
user1 = User.create!(name: "Juan", lastname: "Pérez", role: "admin")
user2 = User.create!(name: "María", lastname: "Gómez", role: "user")
user3 = User.create!(name: "Carlos", lastname: "Ruiz", role: "user")

puts "✅ Usuarios creados: #{User.count}"
puts "   - Admin: #{User.admin.count}"
puts "   - Users: #{User.user.count}"

puts "🏷️ Creando marcas..."
# Marcas
brand1 = Brand.create!(name: "Toyota")
brand2 = Brand.create!(name: "Honda")
brand3 = Brand.create!(name: "Ford")
brand4 = Brand.create!(name: "Chevrolet")

puts "✅ Marcas creadas: #{Brand.count}"

puts "🚗 Creando modelos..."
# Modelos
model1 = Model.create!(name: "Corolla")
model2 = Model.create!(name: "Civic")
model3 = Model.create!(name: "Hilux")
model4 = Model.create!(name: "Yaris")
model5 = Model.create!(name: "Fit")
model6 = Model.create!(name: "Focus")
model7 = Model.create!(name: "Cruze")

puts "✅ Modelos creados: #{Model.count}"

puts "📦 Creando productos..."
# Productos
product1 = Product.create!(
  model: model1.name, 
  brand: brand1.name, 
  entry_date: 1.week.ago, 
  ownerid: user1.id
)

product2 = Product.create!(
  model: model2.name, 
  brand: brand2.name, 
  entry_date: 3.days.ago, 
  ownerid: user2.id
)

product3 = Product.create!(
  model: model3.name, 
  brand: brand1.name, 
  entry_date: 2.days.ago, 
  ownerid: user3.id
)

product4 = Product.create!(
  model: model4.name, 
  brand: brand1.name, 
  entry_date: 1.day.ago, 
  ownerid: user1.id
)

product5 = Product.create!(
  model: model5.name, 
  brand: brand2.name, 
  entry_date: Time.current, 
  ownerid: user2.id
)

product6 = Product.create!(
  model: model6.name, 
  brand: brand3.name, 
  entry_date: 5.days.ago, 
  ownerid: user1.id
)

puts "✅ Productos creados: #{Product.count}"

puts "🔄 Creando transacciones..."
# Transacciones iniciales (cuando el producto fue asignado por primera vez)
Transaction.create!(
  ownerid: user1.id, 
  productid: product1.id, 
  date: 1.week.ago
)

Transaction.create!(
  ownerid: user2.id, 
  productid: product2.id, 
  date: 3.days.ago
)

Transaction.create!(
  ownerid: user3.id, 
  productid: product3.id, 
  date: 2.days.ago
)

Transaction.create!(
  ownerid: user1.id, 
  productid: product4.id, 
  date: 1.day.ago
)

Transaction.create!(
  ownerid: user2.id, 
  productid: product5.id, 
  date: Time.current
)

Transaction.create!(
  ownerid: user1.id, 
  productid: product6.id, 
  date: 5.days.ago
)

# Algunas transacciones de transferencia entre usuarios
Transaction.create!(
  ownerid: user2.id, 
  productid: product1.id, 
  date: 2.days.ago
)

Transaction.create!(
  ownerid: user3.id, 
  productid: product4.id, 
  date: 6.hours.ago
)

puts "✅ Transacciones creadas: #{Transaction.count}"

puts "\n📊 RESUMEN FINAL:"
puts "==================="
puts "👥 Usuarios: #{User.count} (#{User.admin.count} admin, #{User.user.count} users)"
puts "🏷️ Marcas: #{Brand.count}"
puts "🚗 Modelos: #{Model.count}"
puts "📦 Productos: #{Product.count}"
puts "🔄 Transacciones: #{Transaction.count}"

puts "\n🔐 CREDENCIALES DE ACCESO:"
puts "=========================="
puts "Admin: Juan Pérez (puede crear usuarios)"
puts "Users: María Gómez, Carlos Ruiz"

puts "\n🎉 ¡Seed completado exitosamente!"