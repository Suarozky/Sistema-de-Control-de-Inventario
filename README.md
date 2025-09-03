# 🚀 Proyecto Rails

## Pasos para ejecutar el proyecto

```bash
1.bundle install
2.bin/rails db:create db:migrate
3.bin/rails db:seed
4.bin/rails test
5.bin/rails s
```

```bash
1.usuario admin de ejemplo: name:Juan Apellido:Pérez
2.usuario user de ejemplo: name:Carlos Apellido:Ruiz
```



## desiciones de diseño decidi hacerlo basico como cualquier app de administracion con un side bar y datos a la derecha datos en cards horizontales y filtros arriba creo que es una buena convencion 
de estilo
![WhatsApp Image 2025-08-31 at 15 48 33_f3ce5759](https://github.com/user-attachments/assets/ebc23480-98f5-4013-ac6b-4d2a2cb3f5e8)

la base de datos consta de 5 tablas siendo users products brands models y transactions
![WhatsApp Image 2025-09-01 at 17 10 13_e90b7c20](https://github.com/user-attachments/assets/2b545787-f570-4ced-b5d7-a265f5203860)

## En temas de Api estos son las Acciones o Endpoints:
Endpoints creados:

  - Products: GET/POST /api/v1/products, GET/PATCH/PUT/DELETE /api/v1/products/:id
  - 
GET:
<img width="635" height="652" alt="image" src="https://github.com/user-attachments/assets/af0ee4e5-78a0-44dd-ab31-a16b292e84b5" />


POST:
<img width="643" height="827" alt="image" src="https://github.com/user-attachments/assets/9406225e-7bc7-4e4b-a77f-87290f1f40fb" />
 - Users: GET/POST /api/v1/users, GET/PATCH/PUT/DELETE /api/v1/users/:id

 - 
GET:
<img width="683" height="786" alt="image" src="https://github.com/user-attachments/assets/5ab7beaa-cb99-4bd6-a120-4861b1c144af" />


POST:
<img width="675" height="620" alt="image" src="https://github.com/user-attachments/assets/0c15c62b-5262-4717-acae-769971bb6e9f" />
  - Transactions: GET/POST /api/v1/transactions, GET/PATCH/PUT/DELETE /api/v1/transactions/:id

  - 
GET:
<img width="605" height="726" alt="image" src="https://github.com/user-attachments/assets/1fa2c43e-befd-4407-9030-a5425ebc1b59" />


POST:
<img width="634" height="790" alt="image" src="https://github.com/user-attachments/assets/436de24a-88b4-443f-8941-43c5b641ff29" />




