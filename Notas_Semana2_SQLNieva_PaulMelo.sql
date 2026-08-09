-- ======================================
-- NOTAS SEMANA 2 - SQL
-- SISTEMA DE INVENTARIO - TECHSTORE
-- Nombre: [PAUL SEBASTIAN MELO]
-- Fecha: [26-07-2026]
-- ======================================

/* SET SQL_SAFE_UPDATES = 0;
--DELETE FROM productos WHERE nombre = 'Producto X';
SET SQL_SAFE_UPDATES = 1; */

USE inventario_tienda;

/*** CREAR TABLA ***/

/** Eliminamos la tabla productos - si existe **/
DROP TABLE IF EXISTS productos; 

/** Creamos la tabla productos **/
CREATE TABLE productos (
    id              INT AUTO_INCREMENT PRIMARY KEY,      /** ID del producto - Llave primaria **/
    nombre          VARCHAR(150) NOT NULL,               /** Nombre del producto **/
    descripcion     TEXT,
    precio          DECIMAL (10,2),                      /** Precio del producto **/
    stock           INT DEFAULT 0,                       /** Inventario del producto **/
    categoria       VARCHAR(50),                         /** Categoría del producto **/
    activo          BOOLEAN DEFAULT TRUE,                /** Producto disponible para la venta **/
    fecha_creacion  TIMESTAMP DEFAULT CURRENT_TIMESTAMP  /** Fecha creacion del producto en BD **/
);

DESCRIBE productos;

SHOW TABLES;
SELECT COUNT(*) 
FROM productos;

/*******************************************************************************************/
/*** INSERT INTO - INSERTAR DATOS EN TABLAS ***/

/** Insertamos los productos en la tabla productos **/
INSERT INTO productos (nombre, precio, stock, categoria)
VALUES 
	('Laptop HP', 799.99, 10, 'Electrónica'),
    ('Mouse Logitech', 25.99, 50, 'Electrónica');
    
INSERT INTO productos (nombre, precio, stock, categoria)
VALUES 
    ('Monitor LG 24"', 199.99, 8, 'Electrónica'),
    ('Silla Gamer', 249.99, 5, 'Muebles'),
    ('Escritorio', 349.99, 3, 'Muebles'),
    ('Audífonos Sony', 79.99, 20, 'Electrónica'),
    ('Webcam Logitech', 59.99, 12, 'Electrónica');

INSERT INTO productos (nombre, precio, descripcion, stock, categoria)
VALUES ('Producto sin descripción', 19.99, NULL, 0, 'Varios');

INSERT INTO productos (nombre, precio, stock, activo)
VALUES ('Producto con defaults', 15.99, DEFAULT, DEFAULT);

INSERT INTO productos (nombre, precio, stock, categoria)
VALUES 
    ('Cable HDMI', 10.00 * 1.5, 50, UPPER('electrónica')),
    ('Cable USB', ROUND(7.50, 2), 100, 'Electrónica');
    
INSERT INTO productos (nombre, precio)
VALUES ('Producto sin precio', 0.00);

SELECT * FROM productos
ORDER BY categoria,nombre;

SELECT COUNT(categoria) FROM productos
WHERE categoria = 'Electrónica';

insert into productos (nombre, precio, stock, categoria)
values
	('Bolígrafos (paquete 10)', 5.99, 50, 'Oficina'),
    ('Cuaderno A4', 3.50, 100, 'Oficina'),
    ('Grapadora', 8.99, 25, 'Oficina');
    
SELECT nombre, precio, stock, categoria, descripcion
FROM productos;

insert into productos (nombre, precio, stock, categoria, descripcion)
values
	('Laptop Dell XPS 13', 1299.99, 5, 'Electrónica', 
    'Laptop ultradelgada con procesador Intel i7, 16GB RAM, 512GB SSD');
    
INSERT INTO productos (nombre, precio, stock, categoria, descripcion, activo)
VALUES ('Producto en desarrollo', 0.00, 0, NULL, NULL, FALSE);

INSERT INTO productos (nombre, precio, stock, categoria)
VALUES 
    ('Cable HDMI 2m', 12.99, 40, 'Accesorios'),
    ('Hub USB 4 puertos', 18.99, 30, 'Accesorios'),
    ('Funda laptop 15"', 22.99, 20, 'Accesorios'),
    ('Mouse pad XL', 15.99, 50, 'Accesorios'),
    ('Soporte laptop', 35.99, 15, 'Accesorios'),
    ('Limpiador pantallas', 8.99, 60, 'Accesorios'),
    ('Cable USB-C 1m', 9.99, 45, 'Accesorios'),
    ('Adaptador HDMI-VGA', 14.99, 25, 'Accesorios'),
    ('Protector teclado', 7.99, 55, 'Accesorios'),
    ('Stand monitor', 45.99, 10, 'Accesorios');
    
SELECT COUNT(*) AS total_accesorios 
FROM productos 
WHERE categoria = 'Accesorios';

/** Eliminamos la tabla productos_respaldo - si existe **/
DROP TABLE IF EXISTS productos_respaldo; 

/** Creamos la tabla productos_respaldo desde la tabla productos **/
CREATE TABLE productos_respaldo LIKE productos;

/** Definimos que datos llevaremos a la tabla productos_respaldo con WHERE **/
INSERT INTO productos_respaldo
SELECT * FROM productos
WHERE categoria = 'Electrónica';

SELECT COUNT(*) FROM productos_respaldo;

/*******************************************************************************************/
/*** UPDATE - MODIFICAR DATOS EN TABLAS ***/
/** UPDATE sin WHERE es CATASTRÓFICO **/

/** Con SELECT confirmas productos a modificar **/
SELECT id, nombre, precio, stock FROM productos LIMIT 5;

/** Con UPDATE se reliza la modificación del producto usando WHERE **/
UPDATE productos
SET precio = 749.99
WHERE id = 1;

UPDATE productos
SET stock = 20
WHERE id = 2;

SELECT nombre, precio, stock FROM productos WHERE id <= 2;

/** Con UPDATE puedes actualizar varias columnas a la vez - Recuerda usar WHERE **/
UPDATE productos
SET precio = 179.99,
    stock = 12,
    categoria = 'Monitores'
WHERE id = 3;

SELECT nombre, precio, stock, categoria
FROM productos
WHERE id = 3;

/** UPDATE con operaciones matemáticas - Incremeto de precios (10%) **/
-- 1. Ver precios actuales
SELECT nombre, precio, precio * 1.10 AS nuevo_precio
FROM productos
WHERE categoria = 'Electrónica';

-- 2. Aplicar aumento
UPDATE productos
SET precio = precio * 1.10
WHERE categoria = 'Electrónica';

-- 3. Verificar
SELECT nombre, precio FROM productos WHERE categoria = 'Electrónica';


/** UPDATE reducción de Stock **/
-- Cliente compró 3 unidades del producto 2
-- 1. Verificar stock actual
SELECT nombre, stock FROM productos WHERE id = 2; -- Output: stock = 20

-- 2. Reducir stock
UPDATE productos
SET stock = stock - 3
WHERE id = 2;

-- 3. Verificar nuevo stock
SELECT nombre, stock FROM productos WHERE id = 2; -- Output: stock = 17

/** UPDATE Descuento en productos con poco Stock **/
-- Aplicar 20% de descuento a productos &gt;$200 con stock &lt;10
-- 1. Ver qué productos afectará
SELECT nombre, precio, stock,
       precio * 0.8 AS precio_con_descuento
FROM productos
WHERE precio > 200 AND stock < 10;

-- 2. Aplicar descuento
UPDATE productos
SET precio = precio * 0.8
WHERE precio > 200 AND stock < 10;

SELECT nombre, precio, stock 
FROM productos
WHERE precio > 200 AND stock < 10;

/** UPDATE con CASE (condicional) **/
-- Ajustar precios: +10% si electrónica, +5% resto
UPDATE productos
SET precio = CASE
    WHEN categoria = 'Electrónica' THEN precio * 1.10
    WHEN categoria = 'Muebles' THEN precio * 1.05
    ELSE precio
END;

SELECT * 
FROM productos;

/** BUENAS PRACTICAS **/
/** Usa transacciones en producción **/
START TRANSACTION;

-- Actualizar
UPDATE productos SET precio = precio * 1.10 WHERE categoria = 'Electrónica';

-- Verificar
SELECT COUNT(*), AVG(precio) FROM productos WHERE categoria = 'Electrónica';

-- Si todo bien:
COMMIT;

-- Si algo mal:
-- ROLLBACK;

/** Backup antes de cambios masivos **/
# Backup antes de UPDATE masivo
-- mysqldump -u root -p inventario_tienda &gt; backup_antes_update.sql
# Ahora sí, ejecuta UPDATE
# Restaurar backup
-- mysql -u root -p inventario_tienda &lt; backup_antes_update.sql

/*******************************************************************************************/
/*** DELETE - ELIMINAR DATOS EN TABLAS ***/
/** ⚠️ ADVERTENCIA CRÍTICA - DELETE sin WHERE es IRREVERSIBLE **/

/** DELETE vs TRUNCATE vs DROP **/
/* DELETE: Elimina filas (con WHERE) */
-- DELETE FROM productos WHERE stock = 0;
/* TRUNCATE: Vacía tabla completa (no WHERE) */
-- TRUNCATE TABLE productos;
/* DROP: Elimina tabla completamente */
-- DROP TABLE productos;

/** DELETE con condiciones múltiples **/
/* Eliminar productos sin stock y descontinuados: */
-- 1. Ver cuántos afectará
SELECT COUNT(*) AS total
FROM productos
WHERE stock = 0 AND activo = FALSE;

-- 2. Ver los datos antes de eliminar
SELECT id, nombre, stock, activo
FROM productos
WHERE stock = 0 AND activo = FALSE;

-- 3. Eliminar
DELETE FROM productos
WHERE stock = 0 AND activo = FALSE;

-- 4. Verificar
SELECT COUNT(*) FROM productos;

/** DELETE IN **/
/* Eliminar productos específicos */
-- 1. Verificar
SELECT id, nombre FROM productos WHERE id IN (10, 20, 30);
-- 2. Eliminar
DELETE FROM productos
WHERE id IN (10, 20, 30);
-- 3. Verificar
SELECT COUNT(*) FROM productos;

/** DELETE con subconsulta **/
/* Eliminar productos que nunca se han vendido */
-- 1. Ver productos sin ventas
/*SELECT p.id, p.nombre
FROM productos AS p
LEFT JOIN ventas v ON p.id = v.producto_id
WHERE v.id IS NULL;

-- 2. Eliminar
DELETE FROM productos
WHERE id NOT IN (
    SELECT DISTINCT producto_id FROM ventas WHERE producto_id IS NOT NULL*/

/** DELETE - Soft Delete (marca como eliminado) **/
/* En producción, raramente se usa DELETE. Se prefiere "soft delete" */
/* Sentencia para añadir una columna a una tabla creada */
-- ALTER TABLE usuarios ADD COLUMN deleted_at TIMESTAMP NULL; 

-- "Eliminar" usuario (realmente solo marca)
/* UPDATE usuarios
SET deleted_at = NOW()
WHERE id = 123;

-- Consultas ignoran "eliminados"
SELECT * FROM usuarios WHERE deleted_at IS NULL; */
/*******************************************************************************************/
/*** VALORES NULL y DEFAULT ***/
/** NULL vs 0 vs Cadena vacía **/
-- Crear tabla demo

/** Eliminamos la tabla demo - si existe **/
DROP TABLE IF EXISTS demo;

CREATE TABLE demo (
    id INT PRIMARY KEY,
    numero INT,
    texto VARCHAR(50)
);

-- Insertar diferentes "vacíos"
INSERT INTO demo VALUES 
	(1, NULL, NULL),    -- NULL
    (2, 0, ''),         -- 0 y cadena vacía
    (3, NULL, ' ');     -- NULL y espacio

SELECT * FROM demo;

/* NULL en comparaciones */
-- Regla: NULL no se compara con =, usa IS NULL
-- Regla: Cualquier operación con NULL = NULL
SELECT * FROM productos WHERE precio IS NULL;

/* Encontrar valores NULL */
SELECT nombre, precio
FROM productos
WHERE descripcion IS NULL;

/* Encontrar valores NOT NULL */
SELECT nombre, descripcion
FROM productos
WHERE descripcion IS NOT NULL;

/* COALESCE - Reemplazar NULL
COALESCE retorna el primer valor no-NULL */

SELECT 
    nombre,
    precio,
    COALESCE(descripcion, 'Sin descripción') AS descripcion_final
FROM productos;

/* IFNULL - Alternativa simple
IFNULL: Solo 2 argumentos (más simple)
COALESCE: Acepta múltiples argumentos */
SELECT 
    nombre,
    IFNULL(descripcion, 'Sin descripción') AS descripcion_final
FROM productos;

/** EJERCICIOS **/
/** EJERCICIO 1 - TABLA EMPLEADOS **/
/* Eliminar tabla empleados, si existe */
DROP TABLE IF EXISTS empleados;

/* Crear tabla empleados */
CREATE TABLE empleados (
	id            INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR (100) NOT NULL,
    email         VARCHAR (150) NOT NULL,
    telefono      VARCHAR (30) NULL,
    departamento  VARCHAR (50) DEFAULT 'General',
    activo        BOOLEAN DEFAULT TRUE
    );

/** EJERCICIO 2 - Insertar con NULL y DEFAULT **/
INSERT INTO empleados (nombre, email, telefono, departamento, activo)
	VALUES 
		("Ana García", "ana@empresa.com", NULL, DEFAULT, DEFAULT),
        ("Carlos López", "carlos@empresa.com", NULL, "IT", DEFAULT),
        ("María Torres", "Sin telefono", NULL, DEFAULT, DEFAULT);

SELECT *
FROM empleados;

/** EJERCICIO 2 - Consultar NULL **/
/* Encuentra empleados sin teléfono */
SELECT *
FROM empleados
WHERE telefono IS NULL;

/*******************************************************************************************/
/*** TRANSACCIONES BASICAS ***/
/** Una transacción es un conjunto de operaciones SQL que se ejecutan como una unidad:
TODO se completa → COMMIT (guardar cambios)
ALGO falla → ROLLBACK (deshacer todo) **/
/* Ejemplo completo: Transferencia bancaria */
/* Eliminar tabla cuentas, si existe */
DROP TABLE IF EXISTS cuentas;

/* Crear tabla cuentas */
-- Setup: Tabla de cuentas
CREATE TABLE cuentas (
    id INT PRIMARY KEY,
    titular VARCHAR(100),
    saldo DECIMAL(10,2)
);
/* Insertar datos tabla cuentas */
INSERT INTO cuentas VALUES 
    (1, 'Ana García', 1000.00),
    (2, 'Carlos López', 500.00);
    
SELECT * FROM cuentas;

/* Transferir $200 de Ana a Carlos */
-- 1. Iniciar transacción
START TRANSACTION;

-- 2. Restar de cuenta origen
UPDATE cuentas 
SET saldo = saldo - 200
WHERE id = 1;

-- 3. Sumar a cuenta destino
UPDATE cuentas 
SET saldo = saldo + 200
WHERE id = 2;

-- 4. Verificar que todo está bien
SELECT * FROM cuentas WHERE id IN (1, 2);

-- 5. Si todo bien, guardar
COMMIT;

/* ROLLBACK - Deshacer cambios */
START TRANSACTION;

-- Intentar transferencia
UPDATE cuentas SET saldo = saldo - 200 WHERE id = 1;
UPDATE cuentas SET saldo = saldo + 200 WHERE id = 2;

-- Verificar
SELECT * FROM cuentas;

-- ❌ Algo no se ve bien, deshacer
ROLLBACK;

-- Verificar que TODO se revirtió
SELECT * FROM cuentas;
-- Output: Saldos originales (sin cambios)

/* ¿Cuándo usar transacciones?
1. Múltiples tablas relacionadas
2. Operaciones que deben ser atómicas
3. Cambios críticos que quieres verificar */

/* No necesitas transacciones para
1. Operación única simple
2. Solo SELECT */

/* Propiedades ACID
Las transacciones garantizan ACID
A - Atomicidad
Todo o nada. No puede quedar "a medias".
C - Consistencia
La base de datos siempre está en estado válido.
I - Aislamiento
Las transacciones no se ven entre sí hasta COMMIT.
D - Durabilidad
Después de COMMIT, los cambios son permanentes (incluso si hay crash). */

/** EJERCICIO 1 - Transacción básica
Insertamos los productos en la tabla productos **/
SELECT * FROM productos;

START TRANSACTION;

INSERT INTO productos (nombre, precio, stock)
VALUES 
	('Nuevo Producto', 8.37, DEFAULT);

SELECT * FROM productos;
    
UPDATE productos
SET stock = 50
WHERE id = LAST_INSERT_ID();

SELECT * FROM productos WHERE id = LAST_INSERT_ID();

COMMIT;
/*******************************************************************************************/

SELECT * 
FROM productos
WHERE stock = 0 AND categoria IS NULL;

START TRANSACTION;

UPDATE productos
SET categoria = 'Obsoletos'
WHERE stock = 0 AND categoria IS NULL;

SELECT * 
FROM productos
WHERE categoria = 'Obsoletos';

COMMIT;

/** Workflow seguro de 3 pasos **/
/* Paso 1: SELECT (Verificar) */
-- Ver qué registros cambiarás
SELECT * FROM productos WHERE categoria = 'Obsoletos';

/* Paso 2: UPDATE/DELETE (Ejecutar) */
UPDATE productos
SET activo = FALSE
WHERE categoria = 'Obsoletos';

/* SELECT (Confirmar) */
SELECT * FROM productos WHERE categoria = 'Obsoletos';

/** SAFE MODE **/
-- SELECT @@sql_safe_updates;
-- SET SQL_SAFE_UPDATES = 0;
-- SET SQL_SAFE_UPDATES = 1;  -- Reactivar INMEDIATAMENTE
-- SELECT @@sql_safe_updates;

/** Auditoría de cambios
Crear tabla de log: **/

/*
CREATE TABLE cambios_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tabla VARCHAR(50),
    registro_id INT,
    accion VARCHAR(20),
    valor_anterior TEXT,
    valor_nuevo TEXT,
    usuario VARCHAR(100),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
); */

/** Permisos de usuario
En producción, usuarios tienen permisos limitados **/

/* -- Usuario solo-lectura (reportes)
CREATE USER 'reportes'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT ON database.* TO 'reportes'@'localhost';

-- Usuario app (sin DELETE)
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT, INSERT, UPDATE ON database.* TO 'app_user'@'localhost';

-- Usuario admin (TODO)
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON database.* TO 'admin'@'localhost'; */