-- ======================================
-- NOTAS SEMANA 6 - SQL
-- SUBCONSULTAS Y OPERADORES AVANZADOS
-- Nombre: [PAUL SEBASTIAN MELO]
-- Fecha: [10-10-2026]
-- ======================================
/*******************************************************************************************/
/**** 02. Qué son las Subconsultas (Subqueries) ****/
-- Las subconsultas son queries dentro de queries, y son una de las herramientas más poderosas de SQL.

/* DATOS DE PRACTICA */
CREATE DATABASE tienda_online;
USE tienda_online;

CREATE TABLE categorias (
    id     INT PRIMARY KEY,
    nombre VARCHAR(50)
);

CREATE TABLE productos (
    id           INT PRIMARY KEY,
    nombre       VARCHAR(100),
    categoria_id INT,
    precio       DECIMAL(10,2),
    stock        INT,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

INSERT INTO categorias VALUES (1, 'Electrónica'), (2, 'Ropa'), (3, 'Deportes');

INSERT INTO productos VALUES 
    (1, 'Laptop HP',  1, 799.99, 25),
    (2, 'Mouse',      1, 25.99, 150),
    (3, 'Teclado',    1, 89.99,  80),
    (4, 'Monitor',    1, 299.99, 30),
    (5, 'Camiseta',   2, 29.99, 200),
    (6, 'Pantalón',   2, 59.99, 120),
    (7, 'Zapatillas', 2, 89.99,  90),
    (8, 'Balón',      3, 24.99, 100),
    (9, 'Raqueta',    3, 119.99, 35),
    (10, 'Bicicleta', 3, 499.99, 15);

/*** Tipos de subconsultas ***/
/* 1. Subconsulta escalar (devuelve UN valor) */
SELECT nombre, precio
FROM productos
WHERE precio > (SELECT AVG(precio) FROM productos);

/* 2. Subconsulta de fila (devuelve UNA fila con múltiples columnas) */
SELECT nombre, precio
FROM productos
WHERE (precio) IN (SELECT MIN(precio) FROM productos);

/* 3. Subconsulta de columna (devuelve MÚLTIPLES filas, UNA columna) */
SELECT nombre
FROM productos
WHERE categoria_id IN (SELECT id FROM categorias WHERE nombre IN ('Electrónica', 'Ropa'));

/* 4. Subconsulta de tabla (devuelve MÚLTIPLES filas y columnas) */
SELECT p.nombre, p.precio
FROM productos p
JOIN (
    SELECT categoria_id, AVG(precio) AS promedio
    FROM productos
    GROUP BY categoria_id
) AS promedios ON p.categoria_id = promedios.categoria_id
WHERE p.precio > promedios.promedio;

/*** Dónde puedes usar subconsultas ***/
/* 1. En WHERE (filtrar filas) */
SELECT nombre, precio
FROM productos
WHERE precio > (SELECT AVG(precio) FROM productos);

/* 2. En SELECT (calcular columnas) */
SELECT 
    nombre,
    precio,
    (SELECT AVG(precio) FROM productos) AS precio_promedio_global,
    precio - (SELECT AVG(precio) FROM productos) AS diferencia_promedio
FROM productos;

/* 3. En FROM (tabla derivada) */
SELECT categoria, promedio
FROM (
    SELECT categoria_id, AVG(precio) AS promedio
    FROM productos
    GROUP BY categoria_id
) AS promedios_por_categoria;

/* 4. En HAVING (filtrar grupos) */
SELECT categoria_id, AVG(precio) AS promedio
FROM productos
GROUP BY categoria_id
HAVING AVG(precio) > (SELECT AVG(precio) FROM productos);

/*** Subconsultas correlacionadas vs no-correlacionadas ***/
/* No-correlacionada (independiente) */
-- La subconsulta NO depende de la query externa
SELECT nombre, precio
FROM productos
WHERE precio > (SELECT AVG(precio) FROM productos);
-- Subconsulta: Calcula AVG(precio) = 104.99
-- Query externa: Filtra productos WHERE precio > 104.99

/* Correlacionada (dependiente) */
-- La subconsulta USA columna de query externa (p.categoria_id)
SELECT p.nombre, p.precio
FROM productos p
WHERE p.precio > (
    SELECT AVG(precio) 
    FROM productos p2 
    WHERE p2.categoria_id = p.categoria_id  -- ← Correlación
);
-- Para cada producto en query externa:
-- Subconsulta calcula AVG de SU categoría
-- Compara precio del producto con ese promedio
-- Performance: Correlacionadas son más lentas (se ejecutan N veces).

/*** Ejemplos prácticos ***/
/* Ejemplo 1: Productos más caros que el promedio */
SELECT nombre, precio
FROM productos
WHERE precio > (SELECT AVG(precio) FROM productos)
ORDER BY precio DESC;

/* Ejemplo 2: Categorías con productos más caros que el promedio global */
SELECT DISTINCT c.nombre
FROM categorias c
JOIN productos  p ON c.id = p.categoria_id
WHERE p.precio > (SELECT AVG(precio) FROM productos);

/* Ejemplo 3: Producto más caro de cada categoría */
SELECT nombre, precio, categoria_id
FROM productos p
WHERE precio = (
    SELECT MAX(precio)
    FROM productos p2
    WHERE p2.categoria_id = p.categoria_id
);

/*** Ejercicios ***/
/* Ejercicio 1: Productos bajo el promedio */
-- Lista productos con precio menor al promedio
SELECT nombre, precio
FROM productos
WHERE precio < (SELECT AVG(precio) FROM productos)
ORDER BY precio;

/* Ejercicio 2: Categoría con más productos */
-- Encuentra la categoría con más productos
SELECT c.nombre, COUNT(p.id) AS num_productos
FROM categorias c
JOIN productos p ON c.id = p.categoria_id
GROUP BY c.id, c.nombre
HAVING COUNT(p.id) = (
    SELECT MAX(conteo)
    FROM (
        SELECT COUNT(*) AS conteo
        FROM productos
        GROUP BY categoria_id
    ) AS conteos
);

/* Ejercicio 3: Productos más caros que el promedio de su categoría */
SELECT p.nombre, p.precio, c.nombre AS categoria
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE p.precio > (
    SELECT AVG(precio)
    FROM productos p2
    WHERE p2.categoria_id = p.categoria_id
);

/*******************************************************************************************/
/**** 03. Subconsultas en WHERE y SELECT ****/

/*** Subconsultas en WHERE ***/
/* Patrón 2: Filtrar por valores de otra tabla */
-- Productos de categorías específicas
SELECT nombre, precio
FROM productos
WHERE categoria_id IN (
    SELECT id 
    FROM categorias 
    WHERE nombre IN ('Electrónica', 'Deportes')
);

/*** Subconsultas en SELECT ***/
/* Patrón 1: Agregar columnas calculadas */
SELECT 
    nombre,
    precio,
    (SELECT AVG(precio) FROM productos) AS precio_promedio_global,
    precio - (SELECT AVG(precio) FROM productos) AS diferencia_promedio
FROM productos;

/* Patrón 3: Calcular porcentajes */
SELECT 
    nombre,
    precio,
    ROUND(100.0 * precio / (SELECT SUM(precio) FROM productos), 2) AS porcentaje_valor
FROM productos;

/*** Subconsultas en FROM (tablas derivadas) ***/
-- Nota: Siempre necesitas alias para tablas derivadas.
SELECT categoria, promedio
FROM (
    SELECT categoria_id, AVG(precio) AS promedio
    FROM productos
    GROUP BY categoria_id
) AS promedios
WHERE promedio > 100;

/*** Ejercicios ***/
/* Ejercicio 1: Stock mayor al promedio */
SELECT nombre, stock
FROM productos
WHERE stock > (SELECT AVG(stock) FROM productos);

/* Ejercicio 2: Productos sin ventas */
SELECT nombre
FROM productos
WHERE id NOT IN (SELECT DISTINCT producto_id FROM ventas);

/*******************************************************************************************/
/**** 04. Subconsultas Correlacionadas ****/
-- Una subconsulta correlacionada referencia columnas de la query externa y se ejecuta por cada fila de la query externa.

/*** No-correlacionada ***/
SELECT nombre FROM productos
WHERE precio > (SELECT AVG(precio) FROM productos);
-- Subconsulta se ejecuta UNA VEZ

/*** No-correlacionada ***/
SELECT p.nombre FROM productos p
WHERE p.precio > (
    SELECT AVG(precio) FROM productos p2 
    WHERE p2.categoria_id = p.categoria_id  -- ← Referencia a query externa
);
-- Subconsulta se ejecuta POR CADA PRODUCTO

/* Ejemplo paso a paso */
SELECT p.nombre, p.precio, c.nombre AS categoria
FROM productos p
JOIN categorias c ON p.categoria_id = c.id
WHERE p.precio > (
    SELECT AVG(precio)
    FROM productos p2
    WHERE p2.categoria_id = p.categoria_id
);
/*
Ejecución:
1. Para producto 1 (Laptop, categoría Electrónica):
    2.1. Calcula AVG de Electrónica
    2.2. Compara 799.99 > promedio_electrónica
2. Para producto 2 (Mouse, categoría Electrónica):
    2.1. Calcula AVG de Electrónica (otra vez)
    2.2. Compara 25.99 > promedio_electrónica
Y así para cada producto...
*/

/*** Casos de uso ***/
/* 1. Comparar con promedio del grupo */
-- Empleados con salario mayor al promedio de su departamento
SELECT nombre, salario, departamento_id
FROM empleados e
WHERE salario > (
    SELECT AVG(salario)
    FROM empleados e2
    WHERE e2.departamento_id = e.departamento_id
);

/* 2. Encontrar el máximo por grupo */
-- Producto más caro de cada categoría
SELECT nombre, precio, categoria_id
FROM productos p
WHERE precio = (
    SELECT MAX(precio)
    FROM productos p2
    WHERE p2.categoria_id = p.categoria_id
);

/* 3. Verificar existencia relacionada */
-- Productos que tienen al menos una venta
SELECT nombre
FROM productos p
WHERE EXISTS (
    SELECT 1 FROM ventas v WHERE v.producto_id = p.id
);

/* 
Performance
⚠️ Correlacionadas son más lentas:
    Se ejecutan N veces (una por fila)
    Pueden causar problemas en tablas grandes
*/

/*** Alternativas más rápidas ***/
-- En lugar de correlacionada:
SELECT p.nombre FROM productos p
WHERE p.precio > (SELECT AVG(precio) FROM productos p2 WHERE p2.categoria_id = p.categoria_id);

-- Usa JOIN (más rápido):
SELECT p.nombre
FROM productos p
JOIN (
    SELECT categoria_id, AVG(precio) AS promedio
    FROM productos
    GROUP BY categoria_id
) AS promedios ON p.categoria_id = promedios.categoria_id
WHERE p.precio > promedios.promedio;

/*******************************************************************************************/
/**** 05. Operadores IN, NOT IN y EXISTS ****/

/*** IN ***/
-- Con subconsultas
SELECT nombre FROM productos
WHERE categoria_id IN (
    SELECT id FROM categorias WHERE nombre LIKE '%nica%'
);

/*** NOT IN ***/
-- Cuidado con NULL
-- Si ventas tiene NULL en producto_id, NOT IN devuelve resultados vacíos
-- Solución:
WHERE id NOT IN (SELECT producto_id FROM ventas WHERE producto_id IS NOT NULL);

/*** Operador EXISTS ***/
-- Verifica si una subconsulta devuelve ALGUNA fila
-- Productos con al menos una venta
SELECT p.nombre
FROM productos p
WHERE EXISTS (
    SELECT 1 FROM ventas v WHERE v.producto_id = p.id
);

/*** Operador NOT EXISTS ***/
-- Productos SIN ventas
SELECT p.nombre
FROM productos p
WHERE NOT EXISTS (
    SELECT 1 FROM ventas v WHERE v.producto_id = p.id
);

/*** IN vs EXISTS ***/
/* 
Aspecto	                    |IN	                            |EXISTS
Uso	                        |Lista de valores	            |Verificar existencia
Performance	                |Más lento en tablas grandes    |Más rápido
NULL	                    |Problemático con NULL	        |No afectado
Se detiene al encontrar	    |No	                            |Sí (primer match)
*/
-- Recomendación: Usa EXISTS cuando sea posible.

/*** Ejemplos prácticos ***/
/* 1. Clientes con órdenes: */
SELECT c.nombre
FROM clientes c
WHERE EXISTS (SELECT 1 FROM ordenes o WHERE o.cliente_id = c.id);

/* 2. Clientes sin órdenes: */
SELECT c.nombre
FROM clientes c
WHERE NOT EXISTS (SELECT 1 FROM ordenes o WHERE o.cliente_id = c.id);

/* 3. Productos de múltiples categorías: */
SELECT nombre
FROM productos
WHERE categoria_id IN (
    SELECT id FROM categorias WHERE nombre IN ('Electrónica', 'Deportes')
);
/*******************************************************************************************/
/**** 06. Operadores ANY, ALL y SOME ****/

/*** Operador ANY ***/
-- Sintaxis: valor operador ANY (subconsulta)
-- Significado: TRUE si la comparación es TRUE para AL MENOS UN valor de la subconsulta.
-- Productos más caros que CUALQUIER producto de Ropa
SELECT nombre, precio
FROM productos
WHERE precio > ANY (
    SELECT precio FROM productos WHERE categoria_id = 2
);

/*** Operador ALL ***/
-- Sintaxis: valor operador ALL (subconsulta)
-- Significado: TRUE si la comparación es TRUE para TODOS los valores de la subconsulta.
-- Productos más caros que TODOS los productos de Ropa
SELECT nombre, precio
FROM productos
WHERE precio > ALL (
    SELECT precio FROM productos WHERE categoria_id = 2
);

-- Equivalente a:
WHERE precio > (SELECT MAX(precio) FROM productos WHERE categoria_id = 2)

/*** Operador SOME ***/
-- SOME es sinónimo de ANY (mismo comportamiento).
-- Estas queries son idénticas:
WHERE precio > ANY (SELECT precio FROM productos WHERE categoria_id = 2)
WHERE precio > SOME (SELECT precio FROM productos WHERE categoria_id = 2)

/*** Tabla de equivalencias ***/
/*
Expresión	|Equivalente	|Significado
= ANY	    |IN	            |Igual a alguno
<> ALL	    |NOT IN	        |Diferente de todos
> ANY	    |> MIN()	    |Mayor que el mínimo
< ANY	    |< MAX()	    |Menor que el máximo
> ALL	    |> MAX()	    |Mayor que el máximo
< ALL	    |< MIN()	    |Menor que el mínimo
*/

/*** Ejemplos prácticos ***/
/* 1. Productos más caros que algún producto económico: */
SELECT nombre, precio
FROM productos
WHERE precio > ANY (SELECT precio FROM productos WHERE precio < 50);

/* 2. Productos más baratos que todos los productos premium: */
SELECT nombre, precio
FROM productos
WHERE precio < ALL (SELECT precio FROM productos WHERE precio > 500);

/* 3. Empleados con salario mayor que cualquier empleado junior: */
SELECT nombre, salario
FROM empleados
WHERE salario > ANY (SELECT salario FROM empleados WHERE nivel = 'Junior');

-- Recomendación: ANY/ALL son válidos pero MIN/MAX son más legibles.

/*******************************************************************************************/
/**** 07. UNION y UNION ALL ****/

/*** UNION - Sin duplicados ***/
-- Combina resultados de 2+ queries y elimina duplicados.
SELECT nombre FROM productos_2023
UNION
SELECT nombre FROM productos_2024;
/*
Características:
    ✅ Elimina filas duplicadas
    ❌ Más lento (necesita ordenar para eliminar duplicados)
*/

/*** UNION ALL - Con duplicados ***/
-- Combina resultados de 2+ queries incluyendo duplicados.
SELECT nombre FROM productos_2023
UNION ALL
SELECT nombre FROM productos_2024;
/*
Características:
    ✅ Incluye todas las filas (duplicados)
    ✅ Más rápido (no necesita ordenar)
*/

/*** Reglas de UNION ***/
/*
1. Mismo número de columnas:
2. Tipos de datos compatibles:
    --  Las columnas deben ser del mismo tipo o compatibles
3. Nombres de columnas de la primera query:
*/

/*** Casos de uso ***/

/* 1. Combinar datos históricos: */
-- Ventas de 2023 y 2024
SELECT fecha_venta, total, 'venta' AS tipo
FROM ventas_2023
UNION ALL
SELECT fecha_venta, total, 'venta' AS tipo
FROM ventas_2024
ORDER BY fecha_venta DESC;

/* 2. Listas combinadas con etiquetas: */
-- Todos los productos (activos e inactivos)
SELECT nombre, 'activo' AS estado
FROM productos
WHERE activo = TRUE
UNION ALL
SELECT nombre, 'inactivo' AS estado
FROM productos
WHERE activo = FALSE;

/* 3. Consolidar datos de múltiples fuentes: */
-- Contactos de clientes y proveedores
SELECT nombre, email, 'cliente' AS tipo
FROM clientes
UNION
SELECT nombre, email, 'proveedor' AS tipo
FROM proveedores
ORDER BY nombre;

/*** UNION vs UNION ALL - ¿Cuál usar? ***/
/*
Situación	                |Usa	    |Razón
No hay duplicados posibles	|UNION ALL	|Más rápido
Quieres eliminar duplicados	|UNION	    |Resultados únicos
Tablas disjuntas	        |UNION ALL	|Sin duplicados posibles
No estás seguro	            |UNION	    |Más seguro
*/

/*** ORDER BY con UNION ***/
-- ORDER BY va AL FINAL (aplica a todo el resultado)
SELECT nombre, precio FROM productos WHERE categoria_id = 1
UNION ALL
SELECT nombre, precio FROM productos WHERE categoria_id = 2
ORDER BY precio DESC;  -- Ordena el resultado completo

/*** UNION con agreagaciones ***/
-- Total de ventas por año
SELECT 2023 AS año, SUM(total) AS ventas_totales
FROM ventas_2023
UNION ALL
SELECT 2024 AS año, SUM(total)
FROM ventas_2024;

/*** Ejemplos prácticos ***/

/* 1. Top productos por categoría: */
(SELECT nombre, precio, 'Electrónica' AS categoria
 FROM productos WHERE categoria_id = 1
 ORDER BY precio DESC LIMIT 5)
UNION ALL
(SELECT nombre, precio, 'Ropa' AS categoria
 FROM productos WHERE categoria_id = 2
 ORDER BY precio DESC LIMIT 5);

/* 2. Resumen de inventario: */
SELECT 'En stock' AS estado, COUNT(*) AS cantidad
FROM productos WHERE stock > 0
UNION ALL
SELECT 'Agotado', COUNT(*)
FROM productos WHERE stock = 0
UNION ALL
SELECT 'Stock bajo', COUNT(*)
FROM productos WHERE stock > 0 AND stock < 10;

/*** Performance ***/
/*
UNION:
    Necesita ordenar y eliminar duplicados
    Más lento en datasets grandes
UNION ALL:
    Solo concatena resultados
    Mucho más rápido
-- Recomendación: Usa UNION ALL si sabes que no hay duplicados.
*/