-- ======================================
-- ENTREGABLE SEMANA 3
-- BIBLIOTECA PUBLICA - BIBLIOTECH
-- Nombre: [PAUL SEBASTIAN MELO]
-- Fecha: [10-07-2026]
-- =====================================
/*
DROP DATABASE IF EXISTS bibliotech_library;
CREATE DATABASE bibliotech_library;
*/

USE bibliotech_library;

SELECT DATABASE ();

/*** FASE 1 - DISEÑAR ERD ***/

/** PASO 1 - ENTIDADES **/
/*
Entidad	    ¿Qué representa?	        Atributos clave
categories	Géneros de libros	        id, name, description
authors	    Personas que escriben	    id, name, country, birth_date
books	    El catálogo	                id, isbn, title, category_id, year_publication, price, stock
users	    Quien pide prestado	        id, email, name, membership_type
loans	    Acto de prestar un libro	id, user_id, book_id, date, fine 
*/

/** PASO 2 - RELACIONES **/
/*
Relación	            Tipo	               Cómo se implementa
Libros ↔ Autores	    N:M	                   Tabla pivote book_authors (un libro puede tener varios autores y un autor varios libros)
Libros → Categoría	    N:1                    FK category_id en books
                        (1:N desde categoría) 
Usuarios → Préstamos	1:N	                   FK user_id en loans
Libros → Préstamos	    1:N	                   FK book_id en loans
*/
-- "¿Dónde va la FK? Relación 1:N, la FK va siempre del lado "muchos". 
-- Muchos préstamos pertenecen a un usuario → la FK user_id vive en loans.




/** Eliminamos la tabla productos/ventas - si existe **/
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS ventas;

/** Creamos las tablas productos **/
CREATE TABLE productos (
    id                  INT AUTO_INCREMENT PRIMARY KEY,      /** ID del producto - Llave primaria **/
    codigo_producto     VARCHAR(20) UNIQUE NOT NULL,
    nombre              VARCHAR(150) NOT NULL,               /** Nombre del producto **/
    descripcion         TEXT,
    precio              DECIMAL (10,2),                      /** Precio del producto **/
    costo               DECIMAL(10,2) NOT NULL,
    stock               INT DEFAULT 0,                       /** Inventario del producto **/
    stock_minimo        INT DEFAULT 5,
    proveedor           VARCHAR(100),
    categoria           VARCHAR(50),                         /** Categoría del producto **/
    activo              BOOLEAN DEFAULT TRUE,                /** Producto disponible para la venta **/
    fecha_creacion      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  /** Fecha creacion del producto en BD **/
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
						ON UPDATE CURRENT_TIMESTAMP
);

/** Creamos las tablas ventas **/
CREATE TABLE ventas (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    producto_id  INT NOT NULL,
    cantidad     INT NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    total        DECIMAL(10,2) NOT NULL,
    fecha_venta  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SHOW TABLES;
DESCRIBE productos;
DESCRIBE ventas;

/*** FASE 2 - INSERTAR DATOS EN TABLAS productos - ventas ***/
/** Cargar el catálogo y las primeras ventas **/

/** Insertamos los productos en la tabla productos **/
INSERT INTO productos
    (codigo_producto, nombre, descripcion, categoria, precio, costo, stock, stock_minimo, proveedor, activo)
VALUES
    -- Laptops
    ('LAP001', 'Laptop HP Pavilion 15', 'Laptop Intel i5, 8GB RAM, 256GB SSD', 'Laptops', 799.99, 650.00, 12, 5, 'HP Inc', TRUE),
    ('LAP002', 'MacBook Air M2', 'Apple MacBook Air con chip M2, 8GB, 256GB', 'Laptops', 1299.99, 1050.00, 8, 3, 'Apple', TRUE),
    ('LAP003', 'Dell XPS 13', 'Ultrabook Dell XPS 13, i7, 16GB, 512GB SSD', 'Laptops', 1499.99, 1200.00, 5, 3, 'Dell', TRUE),
    ('LAP004', 'Lenovo ThinkPad', NULL, 'Laptops', 899.99, 720.00, 0, 5, 'Lenovo', FALSE),

    -- Periféricos
    ('PER001', 'Mouse Logitech MX Master 3', 'Mouse ergonómico inalámbrico', 'Perifericos', 99.99, 65.00, 35, 10, 'Logitech', TRUE),
    ('PER002', 'Teclado Mecánico Keychron K2', 'Teclado mecánico RGB, switches Gateron Brown', 'Perifericos', 89.99, 55.00, 20, 8, 'Keychron', TRUE),
    ('PER003', 'Webcam Logitech C920', 'Webcam Full HD 1080p', 'Perifericos', 79.99, 50.00, 15, 10, 'Logitech', TRUE),
    ('PER004', 'Hub USB-C 7 puertos', NULL, 'Perifericos', 45.99, 25.00, 50, 15, 'Anker', TRUE),
    ('PER005', 'Mouse Pad XL', 'Mouse pad gaming 90x40cm', 'Perifericos', 24.99, 10.00, 80, 20, 'SteelSeries', TRUE),
    ('PER006', 'Soporte Laptop Ajustable', 'Soporte ergonómico aluminio', 'Perifericos', 39.99, 20.00, 25, 10, 'Rain Design', TRUE),

    -- Audio
    ('AUD001', 'Audífonos Sony WH-1000XM5', 'Audífonos con cancelación de ruido', 'Audio', 399.99, 280.00, 10, 5, 'Sony', TRUE),
    ('AUD002', 'Audífonos Gaming HyperX', NULL, 'Audio', 79.99, 45.00, 30, 10, 'HyperX', TRUE),
    ('AUD003', 'Micrófono Blue Yeti', 'Micrófono USB profesional', 'Audio', 129.99, 85.00, 12, 6, 'Logitech', TRUE),
    ('AUD004', 'Parlantes Logitech Z623', 'Sistema 2.1, 200W', 'Audio', 149.99, 95.00, 8, 5, 'Logitech', TRUE),
    ('AUD005', 'Audífonos Bluetooth JBL', 'Audífonos inalámbricos portátiles', 'Audio', 49.99, 25.00, 2, 10, 'JBL', TRUE),

    -- Componentes
    ('COM001', 'SSD Samsung 1TB', 'SSD NVMe M.2 1TB', 'Componentes', 89.99, 60.00, 40, 15, 'Samsung', TRUE),
    ('COM002', 'RAM Corsair 16GB DDR4', '16GB (2x8GB) DDR4 3200MHz', 'Componentes', 79.99, 50.00, 25, 10, 'Corsair', TRUE),
    ('COM003', 'Monitor LG 27" 4K', 'Monitor IPS 27 pulgadas 4K', 'Componentes', 449.99, 320.00, 7, 5, 'LG', TRUE),
    ('COM004', 'Cable HDMI 2.1 - 2m', NULL, 'Componentes', 19.99, 8.00, 100, 30, 'Cable Matters', TRUE),
    ('COM005', 'Adaptador USB-C a HDMI', 'Adaptador 4K 60Hz', 'Componentes', 29.99, 15.00, 60, 20, 'Anker', TRUE);

/** Insertamos las ventas inciales en la tabla ventas **/
INSERT INTO ventas 
	(producto_id, cantidad, precio_venta, total) 
VALUES
	(1,  2,  799.99, 1599.98),
	(5,  5,   99.99,  499.95),
	(6,  3,   89.99,  269.97),
	(11, 1,  399.99,  399.99),
	(16, 4,   89.99,  359.96);

/* Validamos la información */
SELECT COUNT(*) FROM productos;  -- 20
SELECT COUNT(*) FROM ventas;     -- 5

SELECT categoria, COUNT(*) 
FROM productos 
GROUP BY categoria;

/*** FASE 3 - UPDATE ***/

/** 3.1. - Aumentar precios de Audio en 10% **/
/* SELECT → UPDATE → SELECT */
-- Paso 1 - Ver precios actuales y generar columna precio_nuevo
SELECT nombre, precio, categoria, precio*1.10 AS precio_nuevo
FROM productos
WHERE categoria = "Audio";

-- Paso 2 - Aplicar aumento de precio a los productos
/** SAFE MODE **/
SET SQL_SAFE_UPDATES = 0;

UPDATE productos
SET precio = precio * 1.10
WHERE categoria = "Audio";

SET SQL_SAFE_UPDATES = 1;  -- Reactivas SAFE MODE

-- Paso 3 - Verificar que el cambio de precios
SELECT nombre, precio, categoria
FROM productos 
WHERE categoria = "Audio";

/** 3.2. - Reducir stock por las ventas hechas en Fase 2 **/
/* START TRANSACTION → UPDATE → COMMIT/ROLLBACK */
-- Paso 1 — Se incia la transacción de cambios - borrador de cambios

START TRANSACTION;

UPDATE productos SET stock = stock - 2 WHERE id = 1;   -- venta 1: 2 unidades
UPDATE productos SET stock = stock - 5 WHERE id = 5;   -- venta 2: 5 unidades
UPDATE productos SET stock = stock - 3 WHERE id = 6;   -- venta 3: 3 unidades
UPDATE productos SET stock = stock - 1 WHERE id = 11;  -- venta 4: 1 unidad
UPDATE productos SET stock = stock - 4 WHERE id = 16;  -- venta 5: 4 unidades

-- Paso 2 — Revisamos los cambios realizados antes de aplicarlos en la tabla productos
SELECT id, nombre, stock 
FROM productos 
WHERE id IN (1, 5, 6, 11, 16);

-- Paso 3 — Confirmamos los cambios realizados y aplicamos en la tabla productos
COMMIT;
-- ROLLBACK;

/** 3.3. - Marcar como inactivos los productos con stock bajo **/
/* SELECT → UPDATE → SELECT */
-- Paso 1 — Verificamos productos con stock bajo
SELECT nombre, stock, stock_minimo, activo
FROM productos
WHERE stock < stock_minimo;

-- Paso 2 - Producto no disponible - activo = FALSE
/** SAFE MODE **/
SET SQL_SAFE_UPDATES = 0;

UPDATE productos
SET activo = FALSE
WHERE stock < stock_minimo;

SET SQL_SAFE_UPDATES = 1;  -- Reactivas SAFE MODE

-- Paso 3 - Verificar que el cambio producto no disponible - activo = FALSE
SELECT nombre, stock, stock_minimo, activo
FROM productos
WHERE activo = FALSE;

/* CHEQUEO FECHA DE ACTUALIZACION */
SELECT nombre, fecha_creacion, fecha_actualizacion 
FROM productos 
WHERE id IN (1, 5);
-- fecha_actualizacion debe ser HOY, fecha_creacion debe ser HOY también pero más temprano.

/*** FASE 4 - DELETE: soft vs hard ***/
/** 4.1. - Soft delete del Lenovo ThinkPad **/
/* SELECT → UPDATE → SELECT */
-- Paso 0. — Agregar la columna deleted_at (esto es DDL: cambia la ESTRUCTURA)
ALTER TABLE productos ADD COLUMN fecha_borrado TIMESTAMP NULL;

-- Paso 1. — Verificamos producto a borrar - id=4
SELECT id, nombre, fecha_borrado
FROM productos
WHERE id = 4;

-- Paso 2 - Borrar producto - id=4
UPDATE productos
SET fecha_borrado = CURRENT_TIMESTAMP
WHERE id = 4;

-- Paso 3 - Verificar que el producto borrado - fecha_borrado IS NOT NULL
SELECT id, nombre, fecha_borrado
FROM productos
WHERE fecha_borrado IS NOT NULL;

-- Paso 4 - Verificar productos activos - fecha_borrado IS NULL 
SELECT id, nombre
FROM productos
WHERE fecha_borrado IS NULL;

/** 4.2. -  Hard delete: ventas viejas **/
/* SELECT → UPDATE → SELECT */
-- Paso 1. — Verificamos productos a borrar
SELECT * 
FROM ventas 
WHERE fecha_venta < '2023-01-01';

SELECT COUNT(*)
FROM ventas;

-- Paso 2 - Se procede a borrar los productos - DELETE
/** SAFE MODE **/
SET SQL_SAFE_UPDATES = 0;

DELETE FROM ventas
WHERE fecha_venta < '2023-01-01';

SET SQL_SAFE_UPDATES = 1;  -- Reactivas SAFE MODE

-- Paso 3 - Verificar que los productos fueron borrados - DELETE
SELECT COUNT(*)
FROM ventas;

/*** FASE 5 - Una venta atómica de verdad ***/
/* START TRANSACTION → UPDATE → COMMIT/ROLLBACK */
-- Paso 1 — Se incia la transacción de cambios - venta completa
START TRANSACTION;

-- Paso 2 — Revisamos los cambios a realizar - stock
SELECT id, nombre, stock, precio
FROM productos 
WHERE id = 9 AND stock >= 3 AND fecha_borrado IS NULL;

-- Paso 3 — Se realizan los cambios - borrador de cambios - stock
UPDATE productos
SET stock = stock -3
WHERE id = 9;

-- Paso 4 — Revisamos los cambios a realizar - ventas
SELECT producto_id, cantidad, precio_venta, total
FROM ventas;

-- Paso 5 — Capturar el precio actual en la variable - @precio_actual
/* SELECT @precio_actual := precio FROM productos WHERE id = 9;
SELECT @var := ... guarda un valor en una variable de sesión que puedes usar 
en el siguiente statement. */
SELECT precio
INTO @precio_actual
FROM productos 
WHERE id = 9;

-- Paso 6 — Se realizan los cambios - insertar venta en tabla ventas
INSERT INTO ventas
	(producto_id, cantidad, precio_venta, total)
VALUES
	(9,3,@precio_actual,@precio_actual*3);

-- Paso 7 — Verificamos cambios realizados - stock
SELECT id, nombre, stock, precio
FROM productos 
WHERE id = 9;

-- Paso 7 — Verificamos cambios realizados - ventas
SELECT * 
FROM ventas 
WHERE id = LAST_INSERT_ID();

-- Paso 8 — Aplicamos los cambios realizados en las tablas productos / ventas
COMMIT;
-- ROLLBACK;

-- Paso 9 — Confirmamos cambios realizados en productivo en las tablas productos / ventas
SELECT id, nombre, stock, precio
FROM productos 
WHERE id = 9;

SELECT * 
FROM ventas
WHERE producto_id = 9;

/*** FASE 6 - BONUS ***/

/** Reporte 1 — Productos en alerta de stock bajo (con prioridad)  **/
SELECT nombre, stock, stock_minimo, activo, stock_minimo - stock AS unidades_faltantes
FROM productos
WHERE stock < stock_minimo AND fecha_borrado IS NULL
ORDER BY unidades_faltantes DESC;


/** Reporte 2 — Margen de ganancia top 10  **/
SELECT nombre, precio, costo, precio - costo AS margen_absoluto, 
		ROUND(((precio - costo)/precio)*100,2) AS margen_porcentual
FROM productos
WHERE fecha_borrado IS NULL
ORDER BY margen_absoluto DESC
LIMIT 10;

/** Reporte 3 — Revenue por categoría  **/
SELECT p.categoria, sum(v.total) AS Total, count(v.id) AS Num_ventas, sum(v.cantidad) AS Unidades
FROM ventas AS v
JOIN productos AS p  ON p.id = v.producto_id
GROUP BY p.categoria
ORDER BY Total DESC;