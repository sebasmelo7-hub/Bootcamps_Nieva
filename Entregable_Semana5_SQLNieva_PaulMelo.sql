-- ======================================
-- ENTREGABLE SEMANA 5
-- ANALYTICS TECHMART E-COMMERCE
-- FASE 0 - EDR dbdiagram.io
-- Nombre: [PAUL SEBASTIAN MELO]
-- Fecha: [03-09-2026]
-- =====================================
/*** FASE 0 - MONTAR SISTEMA ANALÍTICO ***/
-- e-commerce que vende electrónica, ropa, deportes, hogar y libros.
-- Dashboard ejecutivo con 14 reportes 
-- Cada reporte debe ser un solo SELECT que cualquiera pueda copiar/pegar para reproducir el dato.

/** PASO 1 - DISEÑAR ERD USANDO dbdiagram.io **/
/**
// ============================================
//  TechMart Analytics — ERD completo (5 tablas)
//  Usando dbdiagram.io
// ============================================

Table cateogires {
  id   int     [pk, increment]
  name varchar [unique, not null]
}

Table products {
  id          int     [pk, increment]
  name        varchar [not null]
  category_id int     [ref: > categories.id]  // products → categories (N:1)
  price       decimal [not null]
  cost        decimal [not null]
  stock       int
  added_date  date
}

Table customers {
  id            int     [pk, increment]
  name          varchar [not null]
  email         varchar [unique, not null]
  city          varchar                     // Ciudad
  country       varchar                     // País
  registered_at date
}

Table sales {
  id          int     [pk, increment]
  customer_id int     [ref: > customers.id]  // sales → customers (N:1)
  product_id  int     [ref: > products.id]   // sales → products (N:1)
  quantity    int     [not null]             // cantidad
  unit_price  decimal [not null]             // precio unitario
  discount    decimal                        // descuento
  sale_date   date    [not null]
}
**/
/* CONEXIONES EDR
-- (cada línea ref: > es una flecha)
Línea ref:	                                Flecha en el diagrama	    Relación
products.category_id > categories.id	    products → categories	    N:1 (many products, one category)
sales.product_id > products.id	            sales → products	        N:1 (many sales, one product)
sales.customer_id > customers.id	        sales → customers	        N:1 (many sales, one customer)
*/

/* DIAGRAMA EDR
┌──────────────┐        ┌────────────────────┐        ┌──────────────┐
│  CATEGORIES  │        │      PRODUCTS      │        │  CUSTOMERS   │
├──────────────┤        ├────────────────────┤        ├──────────────┤
│ 🔑 id        │<───────│ 🔗 category_id     │        │ 🔑 id        │
│    name      │  1:N   │ 🔑 id              │        │    name      │
└──────────────┘        │    price · cost    │        │    country   │
                        │    stock           │        │    city      │
                        └────────────────────┘        └──────────────┘
                              ^                              ^
                              │ 1:N                          │ 1:N
                              │ (product_id)                 │ (customer_id)
                              │                              │
                      ┌───────┴──────────────────────────────┴───────┐
                      │                    SALES                      │
                      │                 (fact table)                  │
                      ├───────────────────────────────────────────────┤
                      │ 🔑 id                                         │
                      │ 🔗 product_id        🔗 customer_id           │
                      │    quantity · unit_price · discount           │
                      │    sale_date                                  │
                      └───────────────────────────────────────────────┘
                      revenue = (quantity * unit_price)
*/


drop database if exists techmart_analytics;
create database techmart_analytics;

use techmart_analytics;

select database();
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
-- ======================================
-- ENTREGABLE SEMANA 5
-- ANALYTICS TECHMART E-COMMERCE
-- FASE 1 - TABLAS PRINCIPALES
-- Nombre: [PAUL SEBASTIAN MELO]
-- Fecha: [03-09-2026]
-- =====================================

/*** FASE 1 - TABLAS PRINCIPALES ***/
/*
1. categories   (depends on no one)
2. products     (depends on categories)
3. customers    (depends on no one)
4. sales        (depends on products and customers)  ← the fact table
*/

use techmart_analytics;

/** Eliminamos la tablas principales - si existe **/
drop table if exists categories;
drop table if exists products;
drop table if exists customers;
drop table if exists sales;

/** CREAR TABLAS **/
/** 1. Creamos la tabla categories **/
-- Atributos: id, name
create table categories (
    id   int auto_increment primary key,  /** ID de la categoria - Llave primaria **/
    name varchar(50) unique not null     /** Nombre de la categoria - Unico - No Nulo **/
);

/** 2. Creamos la tabla products **/
-- Atributos: id, name, category_id, price, cost, stock, added_date
create table products (
    id           int auto_increment primary key, /** ID del producto - Llave primaria **/
    name         varchar(50) not null,           /** Nombre del producto - No Nulo **/
    category_id  int,                            /** ID categoria, FK tabla categories **/
    price        decimal(10,2),                        
    cost         decimal(10,2),                  
    stock        int default 0,
    added_date   date default (current_date),
    
    constraint fk_products_categories
		foreign key (category_id) references categories(id),
        
    constraint chk_price check (price > 0),
    constraint chk_cost  check (cost > 0),
    constraint chk_stock check (stock > 0)
);

/** 3. Creamos la tabla customers **/
-- Atributos: id, name, email, city, country, registered_at
create table customers (
    id            int auto_increment primary key,  /** ID del cliente - Llave primaria **/
    name          varchar(100) not null,           /** Nombre del cliente - No Nulo **/
    email         varchar(150)  unique not null,   /** Correo - Unico - No Nulo **/
    city          varchar(100),
    country       varchar(50),
    registered_at date default (current_date)
);

/** 4. Creamos la tabla sales **/
-- Atributos: id, customer_id, product_id, quantity, unit_prices, discount, sale_date
create table sales (
	id          int auto_increment primary key,    /** ID de la venta - Llave primaria **/
    customer_id int,                               /** ID cliente, FK tabla customers **/
    product_id  int,                               /** ID producto, FK tabla products **/
    quantity    int not null check (quantity > 0),
    unit_price  decimal(10,2) not null,
    discount    decimal(5,2),                      /** Descuento - % **/          
    sale_date   date not null,
    
    constraint fk_sales_customers
		foreign key (customer_id) references customers(id),
	constraint fk_sales_products
		foreign key (product_id)  references products(id),
	
    constraint chk_discount check (discount between 0 and 100)   
);
--------------------------------------------------------------------------------------------------
/** INSERTAR DATOS EN TABLAS **/
/** Insertamos departamentos en tabla categories **/
-- Atributos: id, name
-- 5 categories
insert into categories (name)
values
	('Electronics'), ('Clothing'), ('Sports'), ('Home'), ('Books');

/** Insertamos profesores en tabla products **/
-- Atributos: id, name, email, city, country, registered_at
-- 24 products
insert into products (name, category_id, price, cost, stock)
values
	('HP Laptop 15',          1,  799.99, 600.00,  25),
    ('Logitech Mouse',        1,   25.99,  15.00, 150),
    ('Mechanical Keyboard',   1,   89.99,  50.00,  80),
    ('LG 27" Monitor',        1,  299.99, 200.00,  30),
    ('HD Webcam',             1,   79.99,  45.00,  60),
    ('Sony Headphones',       1,  149.99,  90.00,  45),
    ('Nike T-Shirt',          2,   29.99,  12.00, 200),
    ('Levi Jeans',            2,   59.99,  30.00, 120),
    ('Adidas Sneakers',       2,   89.99,  45.00,  90),
    ('North Face Jacket',     2,  149.99,  80.00,  50),
    ('Nike Cap',              2,   19.99,   8.00, 180),
    ('Soccer Ball',           3,   24.99,  10.00, 100),
    ('Tennis Racket',         3,  119.99,  60.00,  35),
    ('Mountain Bike',         3,  499.99, 300.00,  15),
    ('20kg Weights',          3,   79.99,  40.00,  45),
    ('Yoga Mat',              3,   29.99,  12.00,  80),
    ('Oster Blender',         4,   59.99,  30.00,  70),
    ('Nespresso Coffee Maker',4,  199.99, 120.00,  40),
    ('Dyson Vacuum',          4,  399.99, 250.00,  20),
    ('LED Lamp',              4,   34.99,  15.00, 100),
    ('Clean Code',            5,   39.99,  20.00,  60),
    ('Design Patterns',       5,   49.99,  25.00,  45),
    ('The Pragmatic Programmer', 5, 44.99, 22.00,  50),
    ('Refactoring',           5,   42.99,  21.00,  55);

/** Insertamos estdiantes en tabla customers **/
-- Atributos: id, name, email, city, country, registered_at
-- 20 customers
insert into customers (name, email, city, country, registered_at)
values
	('Alice Garcia',     'alice@email.com',     'Madrid',         'Spain',     '2023-01-15'),
    ('Charles Lopez',    'charles@email.com',   'Barcelona',      'Spain',     '2023-02-20'),
    ('Mary Torres',      'mary@email.com',      'Mexico City',    'Mexico',    '2023-03-10'),
    ('John Perez',       'john@email.com',      'Buenos Aires',   'Argentina', '2023-04-05'),
    ('Lucy Martinez',    'lucy@email.com',      'Bogota',         'Colombia',  '2023-05-12'),
    ('Diego Fernandez',  'diego@email.com',     'Lima',           'Peru',      '2023-06-08'),
    ('Sophie Rodriguez', 'sophie@email.com',    'Santiago',       'Chile',     '2023-07-14'),
    ('Peter Sanchez',    'peter@email.com',     'Montevideo',     'Uruguay',   '2023-08-22'),
    ('Laura Ramirez',    'laura@email.com',     'Quito',          'Ecuador',   '2023-09-03'),
    ('Michael Angel',    'michael@email.com',   'Madrid',         'Spain',     '2023-10-17'),
    ('Carmen Diaz',      'carmen@email.com',    'Valencia',       'Spain',     '2023-11-09'),
    ('Robert Silva',     'robert@email.com',    'São Paulo',      'Brazil',    '2023-12-01'),
    ('Isabel Morales',   'isabel@email.com',    'Guadalajara',    'Mexico',    '2024-01-05'),
    ('Francis Ruiz',     'francis@email.com',   'Cordoba',        'Argentina', '2024-01-18'),
    ('Elena Castro',     'elena@email.com',     'Medellin',       'Colombia',  '2024-02-02'),
    ('Anthony Jimenez',  'anthony@email.com',   'Seville',        'Spain',     '2024-02-14'),
    ('Rose Vargas',      'rose@email.com',      'Monterrey',      'Mexico',    '2024-02-28'),
    ('Xavier Ortiz',     'xavier@email.com',    'Rosario',        'Argentina', '2024-03-12'),
    ('Patricia Herrera', 'patricia@email.com',  'Cali',           'Colombia',  '2024-03-25'),
    ('Manuel Navarro',   'manuel@email.com',    'Bilbao',         'Spain',     '2024-04-08');

/** Insertamos cursos en tabla sales **/
-- Atributos: id, customer_id, product_id, quantity, unit_prices, discount, sale_date
-- 45 sales (4 months, mix of discounts and categories)
insert into sales (customer_id, product_id, quantity, unit_price, discount, sale_date)
values
	-- January 2024
    (1,  1,  1, 799.99,  0, '2024-01-05'),  (2,  2, 2,  25.99,  5, '2024-01-06'),
    (3,  7,  3,  29.99,  0, '2024-01-08'),  (4, 12, 2,  24.99, 10, '2024-01-10'),
    (5,  3,  1,  89.99,  0, '2024-01-12'),  (6, 21, 2,  39.99,  5, '2024-01-15'),
    (7,  8,  1,  59.99,  0, '2024-01-18'),  (8,  4, 1, 299.99, 10, '2024-01-20'),
    (9, 14,  1, 499.99, 15, '2024-01-22'),  (10, 6, 1, 149.99,  5, '2024-01-25'),
    -- February
    (11, 9,  2,  89.99, 10, '2024-02-02'),  (12, 17, 1, 59.99,  0, '2024-02-05'),
    (13, 13, 1, 119.99,  5, '2024-02-08'),  (14, 10, 1, 149.99, 10, '2024-02-10'),
    (15, 18, 1, 199.99,  0, '2024-02-12'),  (16,  2, 5,  25.99, 15, '2024-02-15'),
    (17, 7,  4,  29.99,  5, '2024-02-18'),  (18, 22, 1,  49.99,  0, '2024-02-20'),
    (19, 15, 2,  79.99, 10, '2024-02-22'),  (20, 11, 3,  19.99,  5, '2024-02-25'),
    -- March
    (1, 19,  1, 399.99, 20, '2024-03-02'),  (3,  5, 2,  79.99, 10, '2024-03-05'),
    (5, 23,  1,  44.99,  0, '2024-03-08'),  (7, 16, 1,  29.99,  5, '2024-03-10'),
    (9, 20,  3,  34.99,  0, '2024-03-12'),  (2,  3, 1,  89.99, 10, '2024-03-15'),
    (4,  8,  2,  59.99,  5, '2024-03-18'),  (6, 12, 3,  24.99,  0, '2024-03-20'),
    (8,  1,  1, 799.99,  5, '2024-03-22'),  (10, 4, 1, 299.99, 15, '2024-03-25'),
    -- April
    (12, 6,  1, 149.99, 10, '2024-04-02'),  (14, 13, 1, 119.99,  5, '2024-04-05'),
    (16, 9,  1,  89.99,  0, '2024-04-08'),  (18, 17, 1,  59.99, 10, '2024-04-10'),
    (20, 21, 3,  39.99,  5, '2024-04-12'),  (1,   2, 10, 25.99, 20, '2024-04-15'),
    (3,  7,  5,  29.99, 10, '2024-04-18'),  (5,  14, 1, 499.99, 10, '2024-04-20'),
    (7, 10,  1, 149.99,  5, '2024-04-22'),  (9,  18, 1, 199.99, 15, '2024-04-25'),
    (11, 15, 3,  79.99, 10, '2024-04-26'),  (13, 22, 2,  49.99,  5, '2024-04-27'),
    (15, 11, 4,  19.99,  0, '2024-04-28'),  (17, 16, 2,  29.99,  5, '2024-04-29'),
    (19, 23, 1,  44.99,  0, '2024-04-30');

show tables;
describe categories;
describe products;
describe customers;
describe sales;

/* Validamos la informacion */
select
  (select count(*) from categories) as num_categories,
  (select count(*) from products)   as num_products,
  (select count(*) from customers)  as num_customers,
  (select count(*) from sales)      as num_sales;
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
-- ======================================
-- ENTREGABLE SEMANA 5
-- ANALYTICS TECHMART E-COMMERCE
-- FASE 2 - INFORMES BÁSICOS
-- Nombre: [PAUL SEBASTIAN MELO]
-- Fecha: [03-09-2026]
-- =====================================

/*** FASE 2 - INFORMES BASICOS ***/

use techmart_analytics;

/** R1. PANEL DE CONTROL GENERAL **/
-- "Dame las cifras clave de toda la empresa en una sola fila."
select
	count(*)                    as total_sales,
    count(distinct customer_id) as unique_customer,
    count(distinct product_id)  as distinct_prod_sold,
    sum(quantity)               as unid_sold,
    format(sum(quantity * unit_price), 2)                  as total_sold,
    format(sum(quantity * unit_price * (discount/100)), 2) as total_discount,
    concat('$', format(sum(quantity * unit_price * (1 - discount/100)), 2)) as total_revenue,
    concat('$', format(avg(quantity * unit_price * (1 - discount/100)), 2)) as avg_revenue
from sales;

/** R2. INGRESOS POR CATEGORÍA **/
-- "¿Qué categoría es la que más se vende?"
-- on s.product_id  = p.id
-- on p.category_id = c.id
select 
	c.name          as category,
    count(s.id)     as num_sales,
    sum(s.quantity) as total_units,
    concat('$', format(sum(s.quantity * s.unit_price * (1 - s.discount/100)), 2)) as cat_revenue
from sales           s
left join products   p on s.product_id  = p.id
left join categories c on p.category_id = c.id
group by category
order by sum(s.quantity * s.unit_price * (1 - s.discount/100)) desc;
-- con LEFT JOIN podemos validar si tenemos categorias sin ventas.

/** R3. TOP 10 PRODUCTOS MÄS VENDIDOS **/
select 
	p.name          as product,
    sum(s.quantity) as units_sold,
    concat('$', format(sum(quantity * unit_price * (1 - discount/100)), 2)) as prod_revenue
from sales      s
join products   p on s.product_id  = p.id
group by product
order by units_sold desc, sum(quantity * unit_price * (1 - discount/100)) desc
limit 10;

select 
	p.name          as product,
    c.name          as category,
    sum(s.quantity) as units_sold,
    count(s.id)     as num_purchases,
    concat('$', format(sum(quantity * unit_price * (1 - discount/100)), 2)) as prod_revenue
from sales      s
join products   p on s.product_id  = p.id
join categories c on p.category_id = c.id
group by product, c.name
order by units_sold desc, sum(quantity * unit_price * (1 - discount/100)) desc
limit 10;

/** R4. TOP 10 PRINCPALES CLIENTES POR INGRESOS **/
select
	cu.name         as customer,
    cu.country      as country,
    sum(s.quantity) as units,
    count(s.id)     as num_purchases,
    concat('$', format(sum(quantity * unit_price * (1 - discount/100)), 2)) as spent
from sales      s
join customers cu on s.customer_id = cu.id
group by customer, country
order by sum(quantity * unit_price * (1 - discount/100)) desc, cu.name;

/** R5. INGRESOS MENSUALES **/
select
	year(sale_date)      as num_year,
    month(sale_date)     as num_month,
    monthname(sale_date) as name_month,
    count(*)             as num_sales,
    sum(quantity)        as units,
    concat('$', format(sum(quantity * unit_price * (1 - discount/100)), 2)) as revenue
from sales
group by num_year, num_month, name_month
order by num_year, num_month, sum(quantity * unit_price * (1 - discount/100)) desc;
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
-- ======================================
-- ENTREGABLE SEMANA 5
-- ANALYTICS TECHMART E-COMMERCE
-- FASE 3 - ANÁLISIS AVANZADOS
-- Nombre: [PAUL SEBASTIAN MELO]
-- Fecha: [07-09-2026]
-- =====================================

/*** FASE 3 - ANÁLISIS AVANZADOS ***/

use techmart_analytics;

/** R6. MARGEN DE BENEFICIO POR CATEGORÍA **/
-- margin = revenue − cost            // revenue = ingresos, profit = beneficio
select 
	c.name             as category,
    concat('$', format(sum(s.unit_price * s.quantity * (1 - s.discount/100)), 2)) as revenue,
    concat('$', format(sum(p.cost * s.quantity), 2))                              as cost,
    concat('$', format((sum(s.unit_price * s.quantity * (1 - s.discount/100)) - sum(p.cost * s.quantity)), 2)) as profit,
    concat(format(100 * ((sum(s.unit_price * s.quantity * (1 - s.discount/100)) - sum(p.cost * s.quantity))/(sum(s.unit_price * s.quantity * (1 - s.discount/100)))), 2), '%')      as margin_pct
from sales           s
left join products   p on s.product_id  = p.id
left join categories c on p.category_id = c.id
group by category
order by profit desc;

/** R7. CLIENTES E INGRESOS POR PAIS **/
-- revenue = ingresos
select cu.country, count(distinct cu.id) as num_customers, count(*) as num_sales,
	concat('$', format(sum(s.unit_price * s.quantity * (1 - discount/100)), 2)) as revenue,
    concat('$', format(avg(s.unit_price * s.quantity * (1 - discount/100)), 2)) as avg_cu
from customers cu
left join sales s on s.customer_id = cu.id
group by cu.country
order by sum(s.unit_price * s.quantity * (1 - discount/100)) desc;

/** R8. PRODUCTOS CON STOCK MENOR AL PROMEDIO **/
select p.name as product, p.stock,
    coalesce(sum(s.quantity),0) as unit_sold,    
	round((select avg(stock) from products), 0) as avg_stock
from products p
left join sales s on s.product_id = p.id
where p.stock < (select avg(stock) from products)
group by product, p.stock
order by p.stock;

/** R9. ANALISIS DE DESCUENTOS **/
-- Análisis ABC (CASE WHEN)
select
	case
		when discount = 0  then 'No discount'
        when discount < 10 then '1-9%'
        when discount < 20 then '10-19%'
		else '20%+'
	end           as discount_range,
    count(*)      as num_sales,
    sum(quantity) as units,
    concat('$', format(sum(unit_price * quantity), 2)) as gross_revenue,
    concat('$', format(sum(unit_price * quantity * discount/100), 2)) as discount,
    concat('$', format(sum(unit_price * quantity * (1 - discount/100)), 2)) as net_revenue
from sales
group by discount_range
order by min(discount);

/** R10. CLIENTES HABITUALES **/
-- purchases = compras
-- "repetir  = 2+ compras"
select cu.name as customer, cu.email, count(*) as num_purchases,
	concat('$', format(sum(unit_price * quantity * (1 - discount/100)), 2)) as spent
from sales     s
join customers cu on s.customer_id = cu.id
group by customer, cu.email
having count(*) >= 2
order by num_purchases desc, sum(unit_price * quantity * (1 - discount/100)) desc, cu.name;
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
-- ======================================
-- ENTREGABLE SEMANA 5
-- ANALYTICS TECHMART E-COMMERCE
-- FASE 4 - KPIs
-- Nombre: [PAUL SEBASTIAN MELO]
-- Fecha: [14-09-2026]
-- =====================================

/*** FASE 4 - KPIs ***/

use techmart_analytics;

/** R11. PORCENTAJE DE INGRESOS TOTALES POR CATEGORIA **/
-- revenue = ingresos
select
	c.name as category,
    concat('$', format(sum(s.unit_price * s.quantity * (1 - s.discount/100)), 2)) as revenue,
    concat(round(100 * sum(s.unit_price * s.quantity * (1 - s.discount/100))/(select sum(unit_price * quantity * (1 - discount/100))from sales), 2), '%') as pct_total_cat
from categories c
join products   p on p.category_id = c.id
join sales      s on s.product_id  = p.id
group by category
order by sum(s.unit_price * s.quantity * (1 - s.discount/100)) desc;

/** R12. TASA DE CONVERSION DE INVENTARIO **/
-- NULLIF(SUM(p.stock), 0): si una categoría tiene 0 existencias, dividir por cero genera un error. NULLIF lo convierte en NULL y la división devuelve NULL en lugar de fallar.
select
    c.name                       as category,
    sum(p.stock)                 as current_stock,
    coalesce(sum(s.quantity), 0) as units_sold,
    round(
        100.0 * coalesce(sum(s.quantity), 0) / nullif(sum(p.stock), 0),
        2
    ) as conversion_rate_pct
from categories c
join products   p on p.category_id = c.id
left join sales s on s.product_id  = p.id
group by c.id, c.name
order by conversion_rate_pct desc;

/** R13. CRECIMIENTO MENSUAL CON AUTO-UNION **/
-- Si algun periodo tiene 0 ingresos, dividir por cero genera un error. NULLIF lo convierte en NULL y la división devuelve NULL en lugar de fallar.

select
	current.period,
    concat('$', format(current.revenue, 2))  as revenue,
    concat('$', format(previous.revenue, 2)) as prev_month_revenue,
    round(100 * (current.revenue - previous.revenue) / nullif(previous.revenue, 0), 2) 
    as growth_pct
from (
	select
		date_format(sale_date, '%Y-%m') as period,
		sum(unit_price * quantity * (1 - discount/100)) as revenue
	from sales
    group by period
) as current
left join (
	select
		date_format(sale_date, '%Y-%m') as period,
		sum(unit_price * quantity * (1 - discount/100)) as revenue
    from sales
    group by period
) as previous on current.period = date_format(date_add(str_to_date(
	concat(previous.period, '-01'), '%Y-%m-%d'), interval 1 month), '%Y-%m')
order by current.period;

/** R14. RESUMEN EJECUTIVO **/
select
    'Executive Summary'           as report,
    count(distinct s.id)          as total_sales,
    count(distinct s.customer_id) as unique_customers,
    concat('$', format(sum(s.quantity * s.unit_price * (1 - s.discount/100)), 2)) AS revenue,
    concat('$', format(sum(s.quantity * p.cost), 2)) AS cost,
    concat('$', format(
        sum(s.quantity * s.unit_price * (1 - s.discount/100))
        - sum(s.quantity * p.cost), 2
    )) as profit,
    concat(round(
        100.0 *
        (sum(s.quantity * s.unit_price * (1 - s.discount/100))
         - sum(s.quantity * p.cost))
        / sum(s.quantity * s.unit_price * (1 - s.discount/100)),
        2
    ), '%') as margin_pct,
    concat('$', format(avg(s.quantity * s.unit_price * (1 - s.discount/100)), 2)) as avg_ticket
from sales s
join products p on s.product_id = p.id;
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
-- ======================================
-- ENTREGABLE SEMANA 5
-- ANALYTICS TECHMART E-COMMERCE
-- BONIFICACION
-- Nombre: [PAUL SEBASTIAN MELO]
-- Fecha: [15-09-2026]
-- =====================================

/*** BONIFICACION ***/
-- Inventa dos preguntas que te gustaría responder. Ejemplos:
-- "¿Qué día de la semana se vende más?" ( DAYNAME(sale_date))
-- "¿Cuál es el precio promedio de las entradas por categoría?"
-- "¿Productos que nunca se han vendido?" ( LEFT JOIN ... WHERE v.id IS NULL→ aquí Refactoringaparece el producto n.° 24 del que te avisó R1)