//home_work_4 NoSQL & MongoDB

//2. Создать базу данных

use home_work_4

/*3. Вставить 4 документа по товарам на сайте. Атрибуты:
* Название
* Категория (2 товара из одной категории, 2 товара из другой)
* Цена
* Количество товаров на складе*/

db.home_work_4.insertMany([{name: 'LineaMatic', category: 'Antriebe', price: 50000, quantity: 1},
    {name: 'ProMaticP3', category: 'Antriebe', price: 35000, quantity: 5}, 
    {name: 'Thermo65', category: 'Tuer', price: 165000, quantity: 1}, 
    {name: 'Thermo46', category: 'Tuer', price: 96000, quantity: 2}
])

//4. Рассчитать остаточную стоимость товаров в каждой категории (сумма цены, умноженной на остаток)

db.home_work_4.aggregate({$group: {_id: '$category', residual_value: {$sum: {$multiply: ['$price', '$quantity']}}}})

//5. Уменьшить количество товара на 1

db.home_work_4.updateMany({}, {$inc: {quantity: -1}})

db.home_work_4.find()

//6. Вывести top-2 самых дорогих товара

db.home_work_4.find().sort({price: -1}).limit(2)
