

Transaction.delete_all
Product.delete_all
Model.delete_all
Brand.delete_all
User.delete_all

user1 = User.create!(name: "Juan", lastname: "Pérez")
user2 = User.create!(name: "María", lastname: "Gómez")
user3 = User.create!(name: "Carlos", lastname: "Ruiz")

brand1 = Brand.create!(name: "Toyota")
brand2 = Brand.create!(name: "Honda")

model1 = Model.create!(name: "Corolla")
model2 = Model.create!(name: "Civic")
model3 = Model.create!(name: "Hilux")

product1 = Product.create!(model: model1.name, brand: brand1.name, entry_date: Time.now, ownerid: user1.id)
product2 = Product.create!(model: model2.name, brand: brand2.name, entry_date: Time.now, ownerid: user2.id)
product3 = Product.create!(model: model3.name, brand: brand1.name, entry_date: Time.now, ownerid: user3.id)
product4 = Product.create!(model: "Yaris", brand: brand1.name, entry_date: Time.now, ownerid: user1.id)
product5 = Product.create!(model: "Fit", brand: brand2.name, entry_date: Time.now, ownerid: user2.id)

Transaction.create!(ownerid: user1.id, productid: product1.id, date: Time.now)
Transaction.create!(ownerid: user2.id, productid: product2.id, date: Time.now)

