-- =====================================
-- Week 5: Agregaciones y Agrupamiento
-- =====================================

/*** 02. Funciones de Agregación - COUNT, SUM, AVG, MIN, MAX ***/

/*
Reglas fundamentales de GROUP BY
Regla 1: Toda columna en SELECT debe estar en GROUP BY o ser agregación
Regla 2: GROUP BY debe incluir TODAS las columnas no-agregadas
Regla 3: MySQL permite alias en GROUP BY y ORDER BY (es una extensión de MySQL)
Regla 4: MySQL permite alias en HAVING
*/

/* NOTAS
1. No puedes mezclar columnas individuales con agregaciones sin GROUP BY.
2. SUM/AVG solo funcionan con números.
3. No puedes usar agregaciones con WHERE. Usa HAVING en lugar de WHERE
4. WHERE filtra filas ANTES de agrupar
*/

/*
Las 5 funciones principales:
COUNT() - Contar filas o valores
SUM()   - Sumar valores numéricos
AVG()   - Promedio de valores numéricos
MIN()   - Valor mínimo
MAX()   - Valor máximo
*/

/*
NULL en agregaciones
Comportamiento:
COUNT(*)	    Cuenta filas con NULL
COUNT(columna)	Ignora NULL
SUM()	        Ignora NULL
AVG()	        Ignora NULL
MIN()	        Ignora NULL
MAX()	        Ignora NULL
*/

/*
TENER EN CUENTA - TEMA AVANZADO
Para responder "¿qué categorías concentran el 80% acumulado?" necesitarías calcular un total acumulado (running total). En MySQL esto se hace con window functions (SUM(...) OVER (ORDER BY ...)), un tema avanzado fuera del alcance de este bootcamp. Si llegas a necesitarlo, búscalo bajo el nombre "window functions" o "running total in MySQL".
*/

drop database if exists tienda_online;
CREATE DATABASE tienda_online;
USE tienda_online;

drop table if exists productos;
CREATE TABLE productos (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(100),
    categoria      VARCHAR(50),
    precio         DECIMAL(10,2),
    stock          INT,
    fecha_agregado DATE
);

INSERT INTO productos (nombre, categoria, precio, stock, fecha_agregado) VALUES 
    ('Laptop HP',           'Electrónica', 799.99,  15, '2024-01-05'),
    ('Mouse Logitech',      'Electrónica',  25.99,  50, '2024-01-06'),
    ('Teclado Mecánico',    'Electrónica',  89.99,  30, '2024-01-07'),
    ('Monitor LG 27"',      'Electrónica', 299.99,  12, '2024-01-08'),
    ('Webcam HD',           'Electrónica',  79.99,  25, '2024-01-09'),
    ('Camiseta Nike',       'Ropa',         29.99, 100, '2024-01-10'),
    ('Pantalón Levi',       'Ropa',         59.99,  45, '2024-01-11'),
    ('Zapatillas Adidas',   'Ropa',         89.99,  60, '2024-01-12'),
    ('Chaqueta North Face', 'Ropa',        149.99,  20, '2024-01-13'),
    ('Gorra Nike',          'Ropa',         19.99,  80, '2024-01-14'),
    ('Balón Fútbol',        'Deportes',     24.99,  40, '2024-01-15'),
    ('Raqueta Tenis',       'Deportes',    119.99,  15, '2024-01-16'),
    ('Bicicleta Montaña',   'Deportes',    499.99,   8, '2024-01-17'),
    ('Casco Ciclismo',      'Deportes',     45.99,  30, '2024-01-18'),
    ('Guantes Gym',         'Deportes',     15.99,  50, '2024-01-19');

-----------------------------------------------------------------------------------------
/** COUNT() - Contar filas o valores **/
select count(*) as total_productos
from productos;

/** COUNT(columna) - Contar valores no-NULL **/
select 
	count(*)                  as total_productos,
    count(stock)              as prod_stock,
    count(distinct categoria) as num_categoria
from productos;

-----------------------------------------------------------------------------------------
/** SUM() - Sumar valores **/
select sum(stock) as stock_total
from productos;

/** SUM con expresiones **/
select
	sum(precio)       as sum_precios,
    sum(precio*stock) as valor_inv_total
from productos;

-----------------------------------------------------------------------------------------
/** AVG() - Promedio **/
-- ⚠️ AVG ignora NULL
-- Si 3 productos no tienen precio (NULL)
-- AVG calcula sobre los 12 con precio (ignora los 3 NULL)

select avg(precio) as precio_promedio
from productos;

/** AVG con ROUND (redondear) **/
select 
	avg(precio) as precio_promedio,
    round(avg(precio), 2) as prom_redondeado
from productos;

-----------------------------------------------------------------------------------------
/** MIN() y MAX() - Valor mínimo y máximo **/
SELECT 
    MIN(precio) AS precio_minimo,
    MAX(precio) AS precio_maximo,
    MAX(precio) - MIN(precio) AS rango_precios
FROM productos;

/** MIN y MAX con fechas **/
SELECT 
    MIN(fecha_agregado) AS primer_producto,
    MAX(fecha_agregado) AS ultimo_producto,
    DATEDIFF(MAX(fecha_agregado), MIN(fecha_agregado)) AS dias_diferencia
FROM productos;

---------------------------------------------------------------------------------------------
/** Combinar múltiples agregaciones **/
select 
	count(*)                    as total_productos,
    count(distinct categoria)   as num_categoria,
    sum(stock)                  as stock_total,
    round(avg(precio), 2)       as precio_promedio,
    min(precio)                 as precio_minimo,
    max(precio)                 as precio_maximo,
    round(sum(precio*stock), 2) as valor_inv_total
from productos;

/** Agregaciones con WHERE **/
-- Solo productos de Electrónica
SELECT 
    COUNT(*)    AS num_productos,
    AVG(precio) AS precio_promedio,
    SUM(stock)  AS stock_total
FROM productos
WHERE categoria = 'Electrónica';

---------------------------------------------------------------------------------------------
/** NULL con agregaciones **/
-- Tabla con NULLs
CREATE TABLE test (valor INT);
INSERT INTO test VALUES (10), (20), (NULL), (30);

SELECT 
    COUNT(*) AS total_filas,       -- 4
    COUNT(valor) AS valores_nonull, -- 3
    SUM(valor) AS suma,             -- 60
    AVG(valor) AS promedio          -- 20 (60/3, no 60/4)
FROM test;

---------------------------------------------------------------------------------------------
/** EJERCICIOS **/
/* Productos con stock critico */
select count(*) as stock_bajo
from productos
where stock < (select avg(stock) from productos);

/* Contar productos por categoria */
select 
	count(*)                  as total_productos,
    categoria
from productos
group by categoria;

/* Productos de Ropa */
-- Estadísticas solo para categoría Ropa
SELECT 
    COUNT(*) AS productos_ropa,
    AVG(precio) AS precio_promedio,
    MIN(precio) AS precio_min,
    MAX(precio) AS precio_max,
    SUM(stock) AS stock_total
FROM productos
WHERE categoria = 'Ropa';
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
/*** 03. GROUP BY - Agrupar Resultados ***/
-- GROUP BY divide filas en grupos basados en valores de columnas, y luego aplica funciones de agregación a cada grupo.
USE tienda_online;

-- Verificar datos
SELECT categoria, nombre, precio, stock FROM productos ORDER BY categoria;

/*** GROUP BY básico - Una columna ***/
/** Ejemplo 1: Contar productos por categoría **/
select
	categoria,
    count(*) as num_prod
from productos
group by categoria;

/** Ejemplo 2: Precio promedio por categoría **/
select
	categoria,
    round(avg(precio), 2) as precio_prom
from productos
group by categoria
order by precio_prom desc;

/** Ejemplo 3: Múltiples agregaciones por grupo **/
select
	categoria,
    count(*)              as num_prod,
    round(avg(precio), 2) as precio_prom,
    min(precio)           as precio_min,
    max(precio)           as precio_max,
    sum(stock)            as stock_total
from productos
group by categoria;

---------------------------------------------------------------------------------------------
/*** GROUP BY con múltiples columnas ***/
-- Puedes agrupar por 2+ columnas para segmentación más detallada.

/** Ejemplo: Crear columnas adicionales **/
ALTER TABLE productos ADD COLUMN rango_precio VARCHAR(20);

/** Desbloqueamos Safe Updates para borrar prestamos y que RESTRICT no sea un problema **/
SET SQL_SAFE_UPDATES = 0;
/** Cargamos rango de precio **/
UPDATE productos SET rango_precio = 'económico' WHERE precio < 50;
UPDATE productos SET rango_precio = 'medio'     WHERE precio BETWEEN 50 AND 200;
UPDATE productos SET rango_precio = 'premium'   WHERE precio > 200;
/** Normalizamos Safe Updates **/
SET SQL_SAFE_UPDATES = 1;

/** Agrupar por categoría Y rango **/
select
	categoria,
    rango_precio,
    count(*)              as num_prod,
    round(avg(precio), 2) as precio_prom
from productos
group by categoria, rango_precio
order by categoria, rango_precio;

---------------------------------------------------------------------------------------------
/*** GROUP BY con WHERE ***/
-- WHERE filtra filas ANTES de agrupar
SELECT 
    categoria,
    COUNT(*)    AS num_productos,
    AVG(precio) AS precio_promedio
FROM productos
WHERE precio > 50  -- Filtra primero: solo productos > $50
GROUP BY categoria;

/*** ORDER BY con GROUP BY ***/
-- Ordena los resultados agrupados
SELECT 
    categoria,
	COUNT(*)   AS num_productos,
	SUM(stock) AS stock_total
FROM productos
GROUP BY categoria
ORDER BY stock_total DESC;  -- Ordenar por stock (descendente)

/*** CASOS DE USO ***/
/** 1. Top categorías por ventas **/
SELECT 
    categoria,
	COUNT(*)            AS productos,
	SUM(precio * stock) AS valor_inventario
FROM productos
GROUP BY categoria
ORDER BY valor_inventario DESC;

/** 2. Distribución de precios **/
select
	case
		when precio < 50               then 'economico'
        when precio between 50 and 200 then 'medio'
        else 'premium'
	end         as rango,
    count(*)    as cantidad,
    avg(precio) as promedio
from productos
group by rango
order by promedio;

/** 3. Stock por rango de cantidad **/
 SELECT
	CASE
		WHEN stock < 20              THEN 'bajo'
        WHEN stock BETWEEN 20 AND 50 THEN 'medio'
        ELSE 'alto'
	END      AS nivel_stock,
	COUNT(*) AS num_productos
FROM productos
GROUP BY nivel_stock;

---------------------------------------------------------------------------------------------
/** GROUP BY con fechas **/
-- Agregar columna de mes-- Agregar columna de mes
SELECT
	YEAR(fecha_agregado)  AS año,
    MONTH(fecha_agregado) AS mes,
    COUNT(*)              AS productos_agregados
FROM productos
GROUP BY año, mes
ORDER BY año, mes;

---------------------------------------------------------------------------------------------
/*** EJERCICIOS ***/
/** Ejercicio 1: Productos por categoría **/
-- Cuenta productos y suma stock por categoría
select
	categoria,
    count(*)   as num_productos,
    sum(stock) as stock_total
from productos
group by categoria
order by stock_total desc;

/** Ejercicio 2: Estadísticas de precios por categoría **/
-- Min, max, promedio por categoría
select
	categoria,
    round(avg(precio), 2) as precio_prom,
    min(precio)           as precio_min,
    max(precio)           as precio_max
from productos
group by categoria
order by categoria;

/** Ejercicio 3: Productos por rango de precio **/
-- Agrupa por rango (< $50, $50-$200, > $200)
select
	categoria,
    case
		when precio < 50               then 'economico'
        when precio between 50 and 200 then 'medio'
        else 'premium'
	end as rango
from productos;
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
/*** 04. HAVING - Filtrar Grupos ***/
-- HAVING filtra grupos DESPUÉS de que GROUP BY ha creado y calculado las agregaciones
-- WHERE filtra filas ANTES de agrupar / HAVING filtra grupos DESPUÉS de agrupar

/*** HAVING básico ***/
/** Ejemplo 1: Categorías con más de 3 productos **/
select categoria, count(*) as num_productos
from productos
group by categoria
having num_productos > 3;

/** Ejemplo 2: Categorías con precio promedio alto **/
select categoria, round(avg(precio), 2) as precio_prom
from productos
group by categoria
having precio_prom > 100;

/** Ejemplo 3: Stock total mayor a 150 **/
select categoria, sum(stock) as stock_total
from productos
group by categoria
having stock_total > 150;

---------------------------------------------------------------------------------------------
/*** Combinar WHERE + HAVING ***/
-- Puedes usar AMBOS en la misma consulta

/*** HAVING con múltiples condiciones ***/
/** Usando AND **/
select categoria, count(*) as num_productos, round(avg(precio), 2) as precio_prom
from productos
group by categoria
having num_productos > 3 and precio_prom > 50;

/** Usando OR **/
select categoria, sum(stock) as stock_total, round(avg(precio), 2) as precio_prom
from productos
group by categoria
having stock_total > 200 or precio_prom > 200;

/*** HAVING con subconsultas ***/
select categoria, round(avg(precio), 2) as precio_prom
from productos
group by categoria
having round(avg(precio), 2) > (select round(avg(precio), 2) from productos);

---------------------------------------------------------------------------------------------
/*** EJERCICIOS ***/
/** Ejercicio 1: Categorías con 4+ productos **/
-- Muestra categorías con 4 o más productos
select categoria, count(*) as num_productos
from productos
group by categoria
having num_productos >= 4;

/** Ejercicio 2: Categorías caras **/
-- Categorías con precio promedio > $100
select categoria, round(avg(precio), 2) as precio_prom
from productos
group by categoria
having precio_prom > 100;

/** Ejercicio 3: WHERE + HAVING **/
-- Productos con stock > 20, agrupar por categoría, solo categorías con 3+ productos
select categoria, count(*) as num_productos, sum(stock) as stock_total
from productos
where stock > 20
group by categoria
having num_productos > 3;

/** Ejercicio 4: Mayor al promedio general **/
-- Categorías con precio promedio mayor al promedio general de todos los productos
select categoria, round(avg(precio), 2) as precio_prom
from productos
group by categoria
having precio_prom > (select round(avg(precio), 2) from productos);
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
/*** 05. Combinando GROUP BY y ORDER BY ***/
/*** Combinar WHERE, GROUP BY, HAVING, ORDER BY ***/
select categoria, count(*) as num_productos, round(avg(precio), 2) as precio_prom
from productos
where stock > 10          -- 1. Filtra filas
group by categoria        -- 2. Agrupa
having num_productos >= 3 -- 3. Filtra grupos
order by precio_prom desc -- 4. Ordena
limit 5;
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
/*** 06. Funciones Escalares vs Funciones de Agregación ***/
-- funciones escalares (operan fila por fila) 
-- funciones de agregación (operan sobre grupos).

/*** Funciones escalares ***/
/*
-- Texto
UPPER(nombre)
LOWER(email)
CONCAT(nombre, ' ', apellido)
SUBSTRING(texto, inicio, longitud)
LENGTH(texto)

-- Números
ROUND(precio, 2)
ABS(valor)
CEIL(numero)
FLOOR(numero)

-- Fechas
YEAR(fecha)
MONTH(fecha)
DATEDIFF(fecha1, fecha2)
NOW()
CURDATE()

-- Condicionales
CASE WHEN ... THEN ... END
IF(condicion, si_true, si_false)
COALESCE(valor1, valor2, ...)
*/

/*** Funciones de agregacion ***/
/*
COUNT(*)        -- Contar filas
COUNT(columna)  -- Contar valores no-NULL
SUM(columna)    -- Sumar
AVG(columna)    -- Promedio
MIN(columna)    -- Mínimo
MAX(columna)    -- Máximo
*/

/*** Ejemplos - Funciones escalares ***/
SELECT 
    nombre,
    precio,
    ROUND(precio, 0)     AS precio_redondeado,  -- Escalar: 1 fila → 1 valor
    UPPER(categoria)     AS categoria_mayus,    -- Escalar: 1 fila → 1 valor
    YEAR(fecha_agregado) AS año                 -- Escalar: 1 fila → 1 valor
FROM productos;

/*** Escalares con agregaciones ***/
SELECT 
    categoria,
    COUNT(*)              AS num_productos,
    ROUND(AVG(precio), 2) AS precio_prom,
    UPPER(categoria)      AS cat_mayus
FROM productos
GROUP BY categoria
ORDER BY categoria;

/** Concatener con texto **/
SELECT 
    UPPER(categoria)                   AS categoria,
    CONCAT('$', ROUND(AVG(precio), 2)) AS precio_promedio_formateado
FROM productos
GROUP BY categoria;

---------------------------------------------------------------------------------------------
/*** Funciones escalares en WHERE vs agregaciones en HAVING ***/
/** Escalares con WHERE **/
SELECT categoria, COUNT(*)
FROM productos
WHERE YEAR(fecha_agregado) = 2024  -- Escalar OK en WHERE
GROUP BY categoria;

---------------------------------------------------------------------------------------------
/*** EJERCICIOS ***/
/** Ejercicio 2: Formatear output **/
-- Categoría, conteo, y valor total formateado como "$X,XXX.XX"
SELECT 
    categoria,
    COUNT(*)                                    AS productos,
    CONCAT('$', FORMAT(SUM(precio * stock), 2)) AS valor_total_formateado
FROM productos
GROUP BY categoria;
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
/*** 07. Reportes y Resúmenes Avanzados ***/
/*** Patrones de reportes comunes ***/
/** Patrón 1: Dashboard de inventario **/
select
	count(distinct categoria)                   as total_cat,
    count(*)                                    as total_prod,
	sum(stock)                                  as uni_inventario,
    concat('$', format(sum(precio * stock), 2)) as valor_total_formateado,
    round(avg(precio), 2)                       as precio_prom,
    min(precio)                                 as precio_min,
    max(precio)                                 as precio_max
from productos;

/** Patrón 2: Análisis por segmento **/
select
	categoria,
    count(*)                                    as num_prod,
    concat('$', round(avg(precio), 2))          as ticket_prom,
	sum(stock)                                  as stock_total,
    concat('$', format(sum(precio * stock), 2)) as valor_total_cat,
    round(100.0*sum(precio * stock) / (select sum(precio * stock) from productos))                                                as valor_porcentual
from productos
group by categoria
order by sum(precio * stock) desc;

/** Patrón 4: Top y Bottom N **/
-- Top 5 productos más caros
(SELECT 
    'Top 5 Caros' AS tipo,
    nombre,
    CONCAT('$', precio) AS precio
FROM productos
ORDER BY precio DESC
LIMIT 5)

UNION ALL

-- Top 5 productos más baratos
(SELECT 
    'Top 5 Baratos' AS tipo,
    nombre,
    CONCAT('$', precio) AS precio
FROM productos
ORDER BY precio ASC
LIMIT 5)
ORDER BY precio DESC;

/** Patrón 5: Análisis de concentración (top categorías por valor) **/
-- ¿Cuánto valor representa cada categoría sobre el total?
SELECT
    categoria,
    SUM(precio * stock) AS valor,
    ROUND(
        100.0 * SUM(precio * stock) /
        (SELECT SUM(precio * stock) FROM productos),
        2
    ) AS porcentaje
FROM productos
GROUP BY categoria
ORDER BY valor DESC;

---------------------------------------------------------------------------------------------
/*** Métricas de negocio ***/
/** 1. Rotacion de inventario **/
-- Asumiendo ventas mensuales = 20% del stock
select
	categoria,
    sum(stock)                                as stock_actual,
    round(sum(stock) * 0.2, 0)                as ventas_mes_estimadas,
    round(sum(stock) / (sum(stock) * 0.2), 1) as meses_inventario
from productos
group by categoria;

/** 2. Análisis ABC (Pareto) **/
SELECT 
    nombre,
    precio * stock AS valor,
    ROUND(100.0 * (precio * stock) / (SELECT SUM(precio * stock) FROM productos), 2) 
        AS porcentaje_valor,
    CASE 
        WHEN (precio * stock) > (SELECT AVG(precio * stock) * 2 FROM productos) THEN 'A'
        WHEN (precio * stock) > (SELECT AVG(precio * stock) FROM productos) THEN 'B'
        ELSE 'C'
    END AS clasificacion_abc
FROM productos
ORDER BY valor DESC;

/** 3. KPIs de inventario **/
SELECT 
    'KPIs Generales' AS seccion,
    COUNT(*)         AS total_productos,
    SUM(CASE WHEN stock < 10 THEN 1 ELSE 0 END) AS productos_stock_bajo,
    ROUND(100.0 * SUM(CASE WHEN stock < 10 THEN 1 ELSE 0 END) / COUNT(*), 2) 
                     AS porcentaje_stock_bajo,
    SUM(CASE WHEN stock = 0 THEN 1 ELSE 0 END) AS productos_agotados,
    CONCAT('$', FORMAT(AVG(precio), 2))        AS precio_promedio
FROM productos;

---------------------------------------------------------------------------------------------
/*** Formato y presentación ***/
/** 1. Formatear números **/

/** 2. Crear rangos dinámicos **/