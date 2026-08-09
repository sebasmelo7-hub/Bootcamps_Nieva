-- ======================================
-- NOTAS SEMANA 3 - SQL
-- RELACIONES Y CLAVES
-- Nombre: [PAUL SEBASTIAN MELO]
-- Fecha: [31-07-2026]
-- ======================================
/*******************************************************************************************/
/*** IMPORTANTE
/** Ver valor actual de AUTO_INCREMENT **/
SELECT AUTO_INCREMENT 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'nombre_base_datos' -- Colocar nombre de la base de datos
  AND TABLE_NAME = 'clientes';

/* Verificar FOREIGN KEYs existentes */
SELECT 
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'tienda_online'
  AND TABLE_NAME = 'ordenes'
  AND REFERENCED_TABLE_NAME IS NOT NULL; ***/
/*******************************************************************************************/
/* SET SQL_SAFE_UPDATES = 0;
--DELETE FROM productos WHERE nombre = 'Producto X';
SET SQL_SAFE_UPDATES = 1; */

/** Sintaxis y comandos **/

USE inventario_tienda;

/*** CREAR TABLA ***/

/** Eliminamos la tabla clientes / ordenes - si existe **/
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS ordenes; 

/** Creamos la tabla clientes **/
-- PRIMARY KEY (clave primaria)
CREATE TABLE clientes (
    id     INT PRIMARY KEY,
    nombre VARCHAR(100)
);

/** Creamos la tabla ordenes **/
-- FOREIGN KEY (clave foránea)
CREATE TABLE ordenes (
    id         INT PRIMARY KEY,
    cliente_id INT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Constraints
UNIQUE, NOT NULL, CHECK, DEFAULT

-- Acciones referenciales
ON DELETE CASCADE
ON DELETE SET NULL
ON UPDATE CASCADE
**/

/*******************************************************************************************/
/*** PRIMARY KEY - Clave Primaria ***/
/* Características obligatorias:
UNIQUE (único) - No puede haber dos filas con el mismo valor
NOT NULL (no nulo) - Siempre debe tener valor
INMUTABLE (no cambia) - Una vez asignada, no debería modificarse */
AUTO_INCREMENT - IDs automáticos

USE inventario_tienda;

/*** CREAR TABLA ***/

/** Eliminamos la tabla clientes - si existe **/
DROP TABLE IF EXISTS clientes;

/** Creamos la tabla clientes **/
-- PRIMARY KEY (clave primaria)
CREATE TABLE clientes (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    email  VARCHAR(100)
);

/** Insertamos los productos en la tabla clientes **/
INSERT INTO clientes (nombre, email) 
VALUES
	('Ana García', 'ana@email.com'),
    ('Carlos López', 'carlos@email.com'),
    ('María Torres', 'maria@email.com');

/** Verificamos datos de la tabla clientes **/
SELECT * FROM clientes;

/** MySQL asigna automáticamente - AUTO_INCREMENT **/
-- No especificas id
-- Puedes especificar ID manualmente
-- IDs eliminados NO se reutilizan
INSERT INTO clientes (nombre, email) 
VALUES 
    ('Juan', 'juan@email.com');

/** Ver valor actual de AUTO_INCREMENT **/
SELECT AUTO_INCREMENT 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'nombre_base_datos' -- Colocar nombre de la base de datos
  AND TABLE_NAME = 'clientes';

/** PRIMARY KEY compuesta **/
/* A veces necesitas múltiples columnas para identificar únicamente una fila */
-- Ejemplo: Tabla de asistencia
CREATE TABLE asistencia (
    estudiante_id INT,
    fecha         DATE,
    presente      BOOLEAN,
    PRIMARY KEY (estudiante_id, fecha)
);
-- Se usa fecha con PRIMARY KEY para evitar que un estudiante tenga dos asistencias el mismo día

/** Insertamos los registros de asistencia en la tabla asistencia **/
INSERT INTO asistencia VALUES (10, '2024-01-15', TRUE);
INSERT INTO asistencia VALUES (10, '2024-01-16', TRUE);   -- ✅ OK (fecha diferente)
INSERT INTO asistencia VALUES (20, '2024-01-15', FALSE);  -- ✅ OK (estudiante diferente)
INSERT INTO asistencia VALUES (10, '2024-01-15', FALSE);  -- ❌ ERROR (duplicado)

/** PRIMARY KEY natural vs sintética **/
/* Natural (valor significativo) */
CREATE TABLE paises (
    codigo_iso CHAR(2) PRIMARY KEY,  -- 'MX', 'US', 'ES'
    nombre     VARCHAR(100)
);

/* Sintética (ID auto-generado) */
-- Recomendación: Usa PRIMARY KEY sintética (INT AUTO_INCREMENT) en el 95% de casos.
CREATE TABLE paises (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    codigo_iso CHAR(2),
    nombre     VARCHAR(100)
);

/** Agregar PRIMARY KEY a tabla existente
-- 1. Agregar columna id
ALTER TABLE productos ADD COLUMN id INT AUTO_INCREMENT FIRST;
-- 2. Agregar PRIMARY KEY
ALTER TABLE productos ADD PRIMARY KEY (id);

-- En un solo paso Agregar columna id y Agregar PRIMARY KEY
ALTER TABLE productos 
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY FIRST; **/

/** Eliminar y modificar PRIMARY KEY **/
/* Eliminar PRIMARY KEY 
ALTER TABLE productos DROP PRIMARY KEY;
-- ⚠️ Cuidado: Si hay FOREIGN KEYs apuntando a esta tabla, dará error. */

/* Modificar PRIMARY KEY 
-- No puedes "modificar" directamente
-- Debes eliminar y recrear:
ALTER TABLE productos DROP PRIMARY KEY;
ALTER TABLE productos ADD PRIMARY KEY (nueva_columna); */

/** Buenas prácticas de PRIMARY KEY **/
-- 1. Siempre tener PRIMARY KEY
-- 2. Usar INT AUTO_INCREMENT
-- 3. Nombrar consistentemente
-- 4. PRIMARY KEY como primera columna
--------------------------------------------------------------------------------------------
/*** EJERCICIOS ***/
/** CREAR TABLA CON PRIMARY KEY **/
-- Crea tabla autores con id, nombre, pais
CREATE TABLE autores (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    pais   VARCHAR(50)
);

/** INSERTAR DATOS CON PRIMARY KEY **/
-- Inserta 3 autores (sin especificar id)
INSERT INTO autores (nombre, pais) 
VALUES 
    ('Gabriel García Márquez', 'Colombia'),
    ('Isabel Allende', 'Chile'),
    ('Jorge Luis Borges', 'Argentina');

-- Verificar ids
SELECT * FROM autores; -- id = 1, 2, 3 (automático)

/** PRIMARY KEY COMPUESTA **/
-- Crea tabla reservas_hotel con PRIMARY KEY (habitacion_id, fecha)
/* Eliminamos la tabla reservas_hotel - si existe */
DROP TABLE IF EXISTS reservas_hotel;

/** Creamos la tabla reservas_hotel **/
CREATE TABLE reservas_hotel (
    habitacion_id INT,
    fecha         DATE,
    huesped       VARCHAR (100),
    PRIMARY KEY (habitacion_id, fecha)
);

/* Insertamos los datos en la tabla reservas_hotel */
INSERT INTO reservas_hotel (habitacion_id, fecha, huesped) 
VALUES
	(101, '2024-01-15', 'Ana García'),
    (101, '2024-01-16', 'Carlos López'),
    (101, '2024-01-15', 'María Torres'); -- ❌ Error fecha, habitación

/* Verificamos datos de la tabla reservas_hotel */
SELECT * FROM reservas_hotel;

/** AGREGAR PRIMARY KEY EN TABLA EXISTENTE **/
-- Tabla productos_sin_pk no tiene PK. Agrégala.
-- Crear tabla sin PK (ejemplo)
CREATE TABLE productos_sin_pk (
    nombre VARCHAR(100),
    precio DECIMAL(10,2)
);

-- Agregar id y PRIMARY KEY
ALTER TABLE productos_sin_pk 
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY FIRST;

-- Verificar
DESCRIBE productos_sin_pk;

/*******************************************************************************************/
/*** FOREIGN KEY - Clave Foránea ***/
/* Características obligatorias:
Una FOREIGN KEY es una columna (o conjunto de columnas) 
en una tabla que referencia la PRIMARY KEY de otra tabla. */

/** Problema sin FOREIGN KEY **/
-- Escenario: Órdenes sin protección
CREATE TABLE clientes (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE ordenes (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT,
    total      DECIMAL(10,2),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)  -- 🔑 Protección
);

-- Insertar cliente
INSERT INTO clientes (nombre) VALUES ('Ana García');  -- id = 1

-- Insertar orden válida
INSERT INTO ordenes (cliente_id, total) VALUES (1, 299.99);  -- ✅ OK

-- Intentar orden con cliente inexistente
INSERT INTO ordenes (cliente_id, total) VALUES (999, 499.99);  -- ❌ ERROR
-- Si no existiera FOREINGN KEY entre tablas, MySQL permote la inserción de una orden con cliente inexistente
--------------------------------------------------------------------------------------------
/** EJEMPLO PASO A PASO **/
-- Paso 1: Crear base de datos
CREATE DATABASE tienda_online;
USE tienda_online;

-- Paso 2: Crear tabla padre (clientes)
CREATE TABLE clientes (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email  VARCHAR(100) NOT NULL
);

-- Paso 3: Crear tabla hija (ordenes) con FOREIGN KEY
CREATE TABLE ordenes (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id  INT NOT NULL,
    fecha_orden TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total       DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Paso 4: Insertar clientes (tabla padre primero)
INSERT INTO clientes (nombre, email) 
VALUES 
    ('Ana García', 'ana@email.com'),
    ('Carlos López', 'carlos@email.com'),
    ('María Torres', 'maria@email.com');

-- Paso 5: Insertar órdenes (tabla hija después)
INSERT INTO ordenes (cliente_id, total) 
VALUES 
    (1, 299.99),   -- Ana
    (1, 149.50),   -- Ana (segunda orden)
    (2, 599.00),   -- Carlos
    (3, 89.99);    -- María

-- Paso 6: Verificar relación
SELECT * FROM clientes;
SELECT * FROM ordenes;
--------------------------------------------------------------------------------------------
/** REGLAS - FOREIGN KEY **/
-- Regla 1: Tabla padre debe existir primero
-- Regla 2: Columna referenciada debe ser PRIMARY KEY (o UNIQUE)
-- Regla 3: Tipos de datos deben coincidir EXACTAMENTE
-- Regla 4: Insertar en tabla padre primero


/* Verificar FOREIGN KEYs existentes */
SELECT 
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'tienda_online'
  AND TABLE_NAME = 'ordenes'
  AND REFERENCED_TABLE_NAME IS NOT NULL;

/** FOREIGN KEY con NULL **/
-- Caso 1: NOT NULL (obligatorio) -- Cliente_id obligatorio
CREATE TABLE ordenes (
    id INT PRIMARY KEY,
    cliente_id INT NOT NULL,  -- Cliente obligatorio
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- ❌ Error: cliente_id no puede ser NULL
INSERT INTO ordenes (id, cliente_id, total) VALUES (1, NULL, 100.00);

-- Caso 2: NULL (opcional) -- Usuario opcional (anónimos permitidos)
CREATE TABLE comentarios (
    id INT PRIMARY KEY,
    usuario_id INT NULL,  -- Usuario opcional (anónimos permitidos)
    texto TEXT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- ✅ OK: Comentario anónimo
INSERT INTO comentarios (id, usuario_id, texto) 
VALUES (1, NULL, 'Comentario anónimo');

-- ✅ OK: Comentario con usuario
INSERT INTO comentarios (id, usuario_id, texto) 
VALUES (2, 10, 'Comentario de usuario registrado');

/** BUENAS PRACTIVAS **/
-- 1. Siempre nombrar FKs
-- 2. Mismo tipo de dato
-- 3. Índices en FKs
-- 4. Documentar relaciones
--------------------------------------------------------------------------------------------
/** EJERCICIOS **/
/* Ejercicio 1: Crear relación básica */
-- Crea tablas categorias y productos con FOREIGN KEY
-- Tabla padre
CREATE TABLE categorias (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

-- Tabla hija
CREATE TABLE productos (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    categoria_id INT NOT NULL,
    precio       DECIMAL(10,2),
    CONSTRAINT fk_productos_categoria
        FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

-- Insertar
INSERT INTO categorias (nombre) VALUES ('Electrónica'), ('Ropa');
INSERT INTO productos (nombre, categoria_id, precio) 
VALUES ('Laptop', 1, 799.99), ('Camiseta', 2, 19.99);

/* Ejercicio 1: Crear relación básica */
-- Intenta insertar producto con categoria_id inexistente
-- Esto dará error
INSERT INTO productos (nombre, categoria_id, precio) 
VALUES ('Zapatillas', 999, 49.99);

-- Error: Cannot add or update a child row

-- Solución: Crear categoría primero
INSERT INTO categorias (id, nombre) VALUES (999, 'Calzado');
INSERT INTO productos (nombre, categoria_id, precio) 
VALUES ('Zapatillas', 999, 49.99);

/*******************************************************************************************/
/** RELACIONES 1:1 y 1:N **/
/** TIPO DE RELACIONES **/
/*
Tipo	        Símbolo	Ejemplo
Uno a Uno	    1:1	    Usuario → Perfil
Uno a Muchos	1:N	    Cliente → Órdenes
Muchos a Muchos	N:M	    Estudiantes ↔ Cursos
*/

/** RELACIONES 1:1 **/
-- DEFINICION_ Una fila en Tabla A se relaciona con UNA Y SOLO UNA fila en Tabla B.
/*
Diagrama conceptual:
Copiar
USUARIOS                 PERFILES
+----+-------+          +----+------------+-------------+
| id | email |          | id | usuario_id | avatar      |
+----+-------+          +----+------------+-------------+
|  1 | ana@  | ───────&gt; |  1 |          1 | ana.jpg     |
|  2 | carlos| ───────&gt; |  2 |          2 | carlos.jpg  |
|  3 | maria | ───────&gt; |  3 |          3 | maria.jpg   |
+----+-------+          +----+------------+-------------+

Relación: 1 usuario → 1 perfil
*/
/** IMPLEMENTACION 1:1 **/
-- Tabla padre: usuarios
CREATE TABLE usuarios (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    email          VARCHAR(100) NOT NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla hija: perfiles (1:1 con usuarios)
CREATE TABLE perfiles (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id       INT NOT NULL UNIQUE,  -- 🔑 UNIQUE hace 1:1
    nombre_completo  VARCHAR(150),
    avatar           VARCHAR(255),
    bio              TEXT,
    fecha_nacimiento DATE,
    CONSTRAINT fk_perfiles_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Insertar usuarios
INSERT INTO usuarios (email, password_hash) 
VALUES 
    ('ana@email.com'   , 'hash1'),
    ('carlos@email.com', 'hash2'),
    ('maria@email.com' , 'hash3');

-- Insertar perfiles (1 por usuario)
INSERT INTO perfiles (usuario_id, nombre_completo, avatar, bio) 
VALUES 
    (1, 'Ana García'  , 'ana.jpg'   , 'Desarrolladora Full Stack'),
    (2, 'Carlos López', 'carlos.jpg', 'Diseñador UX/UI'),
    (3, 'María Torres', 'maria.jpg' , 'Product Manager');

-- Verificar relación 1:1
SELECT u.id, u.email, p.nombre_completo, p.avatar
FROM usuarios u
LEFT JOIN perfiles p ON u.id = p.usuario_id;

/* ¿Cuándo usar 1:1? */
-- 1. Separar datos sensibles
-- 2. Datos opcionales/voluminosos
-- 3. Extensión de tabla existente (sin modificarla)

/** RELACIONES 1:N **/
-- DEFINICION: Una fila en Tabla A se relaciona con MÚLTIPLES filas en Tabla B.
/*
Diagrama conceptual:
Copiar
CLIENTES                 ORDENES
+----+----------+        +----+------------+--------+
| id | nombre   |        | id | cliente_id | total  |
+----+----------+        +----+------------+--------+
|  1 | Ana      | ────┬──&gt; 1 |          1 | 299.99 |
|  2 | Carlos   |     ├──&gt; 2 |          1 | 149.50 |
|  3 | María    |     └──&gt; 3 |          1 |  89.99 |
+----+----------+          |              |        |
                        ┌──&gt; 4 |          2 | 599.00 |
                        └──&gt; 5 |          3 |  45.00 |
                             +----+------------+--------+

Relación: 1 cliente → N órdenes
*/
/** IMPLEMENTACION 1:N **/
-- Tabla padre: clientes (el "1")
CREATE TABLE clientes (
    id       INT AUTO_INCREMENT PRIMARY KEY,
    nombre   VARCHAR(100) NOT NULL,
    email    VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20)
);

-- Tabla hija: ordenes (el "N")
CREATE TABLE ordenes (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id  INT NOT NULL,  -- 🔑 Sin UNIQUE (permite duplicados)
    fecha_orden TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total       DECIMAL(10,2) NOT NULL,
    estado      VARCHAR(20) DEFAULT 'pendiente',
    CONSTRAINT fk_ordenes_cliente
        FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Insertar clientes (lado "1")
INSERT INTO clientes (nombre, email, telefono) 
VALUES 
    ('Ana García'  , 'ana@email.com'   , '555-0001'),
    ('Carlos López', 'carlos@email.com', '555-0002'),
    ('María Torres', 'maria@email.com' , '555-0003');

-- Insertar órdenes (lado "N")
INSERT INTO ordenes (cliente_id, total, estado) 
VALUES 
    (1, 299.99, 'completada'),   -- Ana    - orden 1
    (1, 149.50, 'completada'),   -- Ana    - orden 2
    (1, 89.99,  'pendiente'),    -- Ana    - orden 3
    (2, 599.00, 'completada'),   -- Carlos - orden 1
    (3, 45.00,  'pendiente');    -- María  - orden 1

-- Verificar: Un cliente, múltiples órdenes
SELECT c.nombre, COUNT(o.id) AS num_ordenes, SUM(o.total) AS total_gastado
FROM clientes c
LEFT JOIN ordenes o ON c.id = o.cliente_id
GROUP BY c.id, c.nombre;

/* ¿Cuándo usar 1:N? */
-- 1. Colecciones/Listas
-- 2. Histórico/Eventos
-- 3. Jerarquías
-- 4. Dependientes/Hijos
--------------------------------------------------------------------------------------------
/** EJEMPLO COMPLETO - BLOG **/
-- Tabla autores (nivel 1)
CREATE TABLE autores (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email  VARCHAR(100) NOT NULL UNIQUE
);

-- Tabla posts (nivel 2, 1:N con autores)
CREATE TABLE posts (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    autor_id          INT NOT NULL,
    titulo            VARCHAR(200) NOT NULL,
    contenido         TEXT NOT NULL,
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_posts_autor
        FOREIGN KEY (autor_id) REFERENCES autores(id)
);

-- Tabla comentarios (nivel 3, 1:N con posts)
CREATE TABLE comentarios (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    post_id          INT NOT NULL,
    autor_comentario VARCHAR(100) NOT NULL,
    texto            TEXT NOT NULL,
    fecha            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comentarios_post
        FOREIGN KEY (post_id) REFERENCES posts(id)
);

/* Insertar datos en tablas */
-- Insertar autores
INSERT INTO autores (nombre, email) VALUES ('Ana García', 'ana@blog.com');

-- Insertar posts (múltiples por autor)
INSERT INTO posts (autor_id, titulo, contenido) VALUES 
    (1, 'Introducción a SQL', 'Contenido...'),
    (1, 'Relaciones en MySQL', 'Contenido...'),
    (1, 'Normalización avanzada', 'Contenido...');

-- Insertar comentarios (múltiples por post)
INSERT INTO comentarios (post_id, autor_comentario, texto) VALUES 
    (1, 'Carlos', 'Excelente artículo'),
    (1, 'María', 'Muy útil, gracias'),
    (2, 'Juan', '¿Puedes profundizar en FKs?');
--------------------------------------------------------------------------------------------
/*** EJERCICIOS ***/
/** EJERCICIO 2 **/
-- Crea tablas empresas y sedes_principales con relación 1:1
CREATE TABLE empresas(
    id      INT AUTO_INCREMENT PRIMARY KEY,
    nombre  VARCHAR(100) NOT NULL,
    rfc     VARCHAR(20) NOT NULL UNIQUE    
);

CREATE TABLE sedes_principales(
    id         INT AUTO_INCREMENT PRIMARY KEY,
    empresa_id INT NOT NULL UNIQUE,  -- 🔑 UNIQUE hace 1:1
    direccion  VARCHAR(255) NOT NULL,
    telefono   VARCHAR(20),
    CONSTRAINT fk_sedes_empresa
        FOREIGN KEY (empresa_id) REFERENCES empresas(id)
);

/* Insertar datos en tablas */
INSERT INTO empresas (nombre, rfc) VALUES ('TechCorp', 'TCO123456');
INSERT INTO sedes_principales (empresa_id, direccion, telefono) 
VALUES (1, 'Av. Principal 123', '555-0001');

/** EJERCICIO 3 **/
-- Crea tablas categorias y productos (1:N)
CREATE TABLE categorias (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE productos (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    categoria_id INT NOT NULL,  -- Sin UNIQUE (permite 1:N)
    nombre       VARCHAR(100) NOT NULL,
    precio       DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_productos_categoria
        FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

-- Insertar
INSERT INTO categorias (nombre) VALUES ('Electrónica'), ('Ropa');
INSERT INTO productos (categoria_id, nombre, precio) VALUES 
    (1, 'Laptop', 799.99),
    (1, 'Mouse', 25.99),
    (1, 'Teclado', 89.99),
    (2, 'Camiseta', 19.99),
    (2, 'Pantalón', 39.99);

-- Verificar: Una categoría, múltiples productos
SELECT c.nombre AS categoria, COUNT(p.id) AS num_productos
FROM categorias c
LEFT JOIN productos p ON c.id = p.categoria_id
GROUP BY c.id, c.nombre;
/*******************************************************************************************/
/** RELACIONES N:M - MUCHOS A MUCHOS **/
-- Para N:M se crea una tercera tabla que conecta las otras dos. 
-- Cada fila en esa tabla representa una asociación entre A y B

LIBROS                LIBROS_AUTORES              AUTORES
+----+-----------+    +----------+-----------+    +----+-----------+
| id | titulo    |    | libro_id | autor_id  |    | id | nombre    |
+----+-----------+    +----------+-----------+    +----+-----------+
|  1 | Good Omens|&lt;───|        1 |         1 |───&gt;|  1 | Gaiman    |
|  2 | American  |    |        1 |         2 |    |  2 | Pratchett |
|    |  Gods     |&lt;───|        2 |         1 |    |  3 | King      |
|  3 | Sandman   |&lt;───|        3 |         1 |    +----+-----------+
+----+-----------+    +----------+-----------+

/* Lectura:
- Good Omens (1) tiene autores 1 (Gaiman) y 2 (Pratchett)
- Gaiman (1) escribió libros 1, 2 y 3 */

-- La tabla libros_autores no almacena ni libros ni autores — almacena asociaciones. 
-- Cada fila dice "este libro está conectado con este autor".
--------------------------------------------------------------------------------------------
/** IMPLEMENTACION N:M - MUCHOS A MUCHOS **/
CREATE TABLE autores (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    nacionalidad VARCHAR(50)
);

CREATE TABLE libros (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    titulo           VARCHAR(200) NOT NULL,
    anio_publicacion INT,
    isbn             VARCHAR(20) UNIQUE
);
-- Importante: ninguna de las dos tiene FK a la otra. Las tablas principales no se conocen
/* Se crea tabla union libros_autores */
CREATE TABLE libros_autores (
    libro_id INT NOT NULL,
    autor_id INT NOT NULL,
    PRIMARY KEY (libro_id, autor_id),  -- 🔑 PK compuesta
    CONSTRAINT fk_la_libro
        FOREIGN KEY (libro_id) REFERENCES libros(id),
    CONSTRAINT fk_la_autor
        FOREIGN KEY (autor_id) REFERENCES autores(id)
);

/* Insertar datos ejemplo */
-- Insertar autores
INSERT INTO autores (nombre, nacionalidad) VALUES
    ('Neil Gaiman', 'Británico'),
    ('Terry Pratchett', 'Británico'),
    ('Stephen King', 'Estadounidense');

-- Insertar libros
INSERT INTO libros (titulo, anio_publicacion, isbn) VALUES
    ('Good Omens', 1990, '978-0-06-085398-3'),
    ('American Gods', 2001, '978-0-380-78903-0'),
    ('The Sandman: Volume 1', 1989, '978-1-4012-2575-1'),
    ('It', 1986, '978-0-670-81302-5'),
    ('The Talisman', 1984, '978-0-670-69199-9');  -- King + Straub

-- Insertar autor adicional
INSERT INTO autores (nombre, nacionalidad) VALUES ('Peter Straub', 'Estadounidense');

-- Asociar libros con autores (la magia ocurre aquí)
INSERT INTO libros_autores (libro_id, autor_id) VALUES
    (1, 1),  -- Good Omens ← Gaiman
    (1, 2),  -- Good Omens ← Pratchett (mismo libro, otro autor)
    (2, 1),  -- American Gods ← Gaiman
    (3, 1),  -- The Sandman ← Gaiman
    (4, 3),  -- It ← King
    (5, 3),  -- The Talisman ← King
    (5, 4);  -- The Talisman ← Straub (mismo libro, otro autor)
--------------------------------------------------------------------------------------------
/* Consultas N:M */
-- Listar todos los libros con sus autores
SELECT
    l.titulo,
    a.nombre AS autor
FROM libros l
INNER JOIN libros_autores la ON l.id = la.libro_id
INNER JOIN autores a ON la.autor_id = a.id
ORDER BY l.titulo;

-- Todos los libros de un autor
SELECT l.titulo, l.anio_publicacion
FROM libros l
INNER JOIN libros_autores la ON l.id = la.libro_id
INNER JOIN autores a ON la.autor_id = a.id
WHERE a.nombre = 'Neil Gaiman';

-- Todos los autores de un libro
SELECT a.nombre, a.nacionalidad
FROM autores a
INNER JOIN libros_autores la ON a.id = la.autor_id
INNER JOIN libros l ON la.libro_id = l.id
WHERE l.titulo = 'Good Omens';

-- Cuántos libros tiene cada autor
SELECT
    a.nombre,
    COUNT(la.libro_id) AS total_libros
FROM autores a
LEFT JOIN libros_autores la ON a.id = la.autor_id
GROUP BY a.id, a.nombre
ORDER BY total_libros DESC;

-- Libros co-escritos (más de un autor)
SELECT
    l.titulo,
    COUNT(la.autor_id) AS num_autores
FROM libros l
INNER JOIN libros_autores la ON l.id = la.libro_id
GROUP BY l.id, l.titulo
HAVING COUNT(la.autor_id) < 1;
--------------------------------------------------------------------------------------------
/*** EJEMPLO: ESTUDIANTES - CURSOS ***/
CREATE TABLE estudiantes (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email  VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE cursos (
    id       INT AUTO_INCREMENT PRIMARY KEY,
    titulo   VARCHAR(150) NOT NULL,
    creditos INT NOT NULL
);

CREATE TABLE inscripciones (
    estudiante_id     INT NOT NULL,
    curso_id          INT NOT NULL,
    fecha_inscripcion DATE NOT NULL,
    calificacion      DECIMAL(4,2),         -- 📌 Dato de la asociación
    estado            VARCHAR(20) DEFAULT 'activo', -- 📌 Dato de la asociación
    PRIMARY KEY (estudiante_id, curso_id),
    CONSTRAINT fk_insc_estudiante
        FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id),
    CONSTRAINT fk_insc_curso
        FOREIGN KEY (curso_id) REFERENCES cursos(id)
);

/* Insertar datos ejemplo */
INSERT INTO inscripciones
    (estudiante_id, curso_id, fecha_inscripcion, calificacion, estado)
VALUES
    (1, 101, '2026-02-01', 8.5, 'completado'),
    (1, 102, '2026-02-01', NULL, 'activo'),    -- aún sin calificación
    (2, 101, '2026-02-15', 9.2, 'completado');

-- Consultar promedio por curso
SELECT
    c.titulo,
    AVG(i.calificacion) AS promedio,
    COUNT(i.estudiante_id) AS num_inscritos
FROM cursos c
INNER JOIN inscripciones i ON c.id = i.curso_id
WHERE i.estado = 'completado'
GROUP BY c.id, c.titulo;
--------------------------------------------------------------------------------------------
/*** EJERCICIOS ***/
/** EJERCICIO 2: DISEÑAR PELICULAS - GENEROS **/
-- Crea las tres tablas necesarias para que una película pueda pertenecer a varios géneros 
-- y un género agrupe varias películas. 
-- Inserta 3 películas, 4 géneros, y al menos 5 asociaciones (al menos una película con 2 géneros)
CREATE TABLE peliculas (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    anio   INT
);

CREATE TABLE generos (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE peliculas_generos (
    pelicula_id INT NOT NULL,
    genero_id   INT NOT NULL,
    PRIMARY KEY (pelicula_id, genero_id),
    FOREIGN KEY (pelicula_id) REFERENCES peliculas(id),
    FOREIGN KEY (genero_id) REFERENCES generos(id)
);

-- Insertar Datos
INSERT INTO peliculas (titulo, anio) VALUES
    ('The Matrix', 1999),
    ('Get Out', 2017),
    ('Parasite', 2019);

INSERT INTO generos (nombre) VALUES
    ('Acción'), ('Ciencia Ficción'), ('Terror'), ('Thriller');

INSERT INTO peliculas_generos (pelicula_id, genero_id) VALUES
    (1, 1),  -- Matrix: Acción
    (1, 2),  -- Matrix: Ciencia Ficción
    (2, 3),  -- Get Out: Terror
    (2, 4),  -- Get Out: Thriller
    (3, 4);  -- Parasite: Thriller

-- Verificar
SELECT p.titulo, g.nombre AS genero
FROM peliculas p
INNER JOIN peliculas_generos pg ON p.id = pg.pelicula_id
INNER JOIN generos g ON pg.genero_id = g.id
ORDER BY p.titulo, g.nombre;

/** EJERCICIO 3: INSCRIPCIONES CON CALIFICACION **/
-- Diseña estudiantes, cursos e inscripciones (con calificación). 
-- Inscribe 2 estudiantes en 3 cursos cada uno y asigna calificaciones.
-- Después escribe la consulta que devuelve el promedio de cada estudiante.
CREATE TABLE estudiantes (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email  VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE cursos (
    id       INT AUTO_INCREMENT PRIMARY KEY,
    titulo   VARCHAR(150) NOT NULL,
    creditos INT NOT NULL
);

CREATE TABLE inscripciones (
    estudiante_id INT NOT NULL,
    curso_id      INT NOT NULL,
    calificacion  DECIMAL(4,2),
    PRIMARY KEY (estudiante_id, curso_id),
    FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id),
    FOREIGN KEY (curso_id) REFERENCES cursos(id)
);

INSERT INTO estudiantes (nombre, email) VALUES
    ('Ana García', 'ana@uni.edu'),
    ('Carlos López', 'carlos@uni.edu');

INSERT INTO cursos (titulo, creditos) VALUES
    ('Bases de Datos', 4),
    ('Algoritmos', 4),
    ('Redes', 3);

INSERT INTO inscripciones (estudiante_id, curso_id, calificacion) VALUES
    (1, 1, 9.2), (1, 2, 8.5), (1, 3, 9.8),
    (2, 1, 7.5), (2, 2, 8.0), (2, 3, 6.9);

-- Promedio por estudiante
SELECT
    e.nombre,
    ROUND(AVG(i.calificacion), 2) AS promedio
FROM estudiantes e
INNER JOIN inscripciones i ON e.id = i.estudiante_id
GROUP BY e.id, e.nombre
ORDER BY promedio DESC;

/*******************************************************************************************/
/*** INTEGRIDAD REFERENCIAL ***/
-- Integridad referencial es el conjunto de reglas que garantiza que las 
-- relaciones entre tablas permanezcan consistentes.

/* Acciones referenciales disponibles */
/*
Acción	        Comportamiento
1. CASCADE	    Propaga la acción (elimina/actualiza hijos automáticamente)
2. SET NULL	    Establece FK a NULL en hijos
3. RESTRICT	    Previene la acción si hay hijos (DEFAULT)
4. NO ACTION	Similar a RESTRICT (diferencia en timing)
5. SET DEFAULT	Establece FK a valor DEFAULT (no soportado en MySQL) */

--------------------------------------------------------------------------------------------
/** ON DELETE CASCADE **/
-- Cuando eliminas registro padre, elimina automáticamente todos los hijos.
CREATE TABLE clientes (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE ordenes (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    total      DECIMAL(10,2),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
        ON DELETE CASCADE  -- 🔑 Elimina órdenes automáticamente
);

/* Ejemplo Practico */
-- Insertar cliente y órdenes
INSERT INTO clientes (id, nombre) VALUES (1, 'Ana García');
INSERT INTO ordenes (cliente_id, total) VALUES 
    (1, 299.99),
    (1, 149.50),
    (1, 89.99);

-- Verificar órdenes
SELECT * FROM ordenes WHERE cliente_id = 1;
-- Output: 3 órdenes

-- Eliminar cliente
DELETE FROM clientes WHERE id = 1;
-- ✅ CASCADE elimina automáticamente las 3 órdenes

-- Verificar
SELECT * FROM ordenes WHERE cliente_id = 1;
-- Output: Empty set (órdenes eliminadas automáticamente)

/* ¿Cuando usar CASCADE?
1. Comentarios de un post
-- Si eliminas post, elimina sus comentarios
CREATE TABLE posts (id INT PRIMARY KEY);
CREATE TABLE comentarios (
    post_id INT,
    FOREIGN KEY (post_id) REFERENCES posts(id)
        ON DELETE CASCADE  -- Comentarios inútiles sin post
);
2. Items de una factura
-- Si eliminas factura, elimina sus items
CREATE TABLE facturas (id INT PRIMARY KEY);
CREATE TABLE factura_items (
    factura_id INT,
    FOREIGN KEY (factura_id) REFERENCES facturas(id)
        ON DELETE CASCADE  -- Items no existen sin factura
); */
--------------------------------------------------------------------------------------------

/** ON DELETE SET NULL **/
-- Cuando eliminas registro padre, establece FK a NULL en hijos
CREATE TABLE categorias (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50)
);

CREATE TABLE productos (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100),
    categoria_id INT NULL,  -- Debe permitir NULL
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
        ON DELETE SET NULL  -- 🔑 Establece a NULL
);

/* Ejemplo Practico */
-- Insertar categoría y productos
INSERT INTO categorias (id, nombre) VALUES (1, 'Electrónica');
INSERT INTO productos (nombre, categoria_id) VALUES 
    ('Laptop', 1),
    ('Mouse', 1),
    ('Teclado', 1);

-- Verificar
SELECT nombre, categoria_id FROM productos;
-- Output: Todos tienen categoria_id = 1

-- Eliminar categoría
DELETE FROM categorias WHERE id = 1;
-- ✅ SET NULL establece categoria_id = NULL en productos

-- Verificar
SELECT nombre, categoria_id FROM productos;

/* ¿Cuando usar SET NULL?
1. Productos sin categoría
-- Productos pueden existir sin categoría (temporalmente)
categoria_id INT NULL
ON DELETE SET NULL
2. Comentarios de usuario anónimo
-- Si usuario se elimina, comentarios quedan anónimos
usuario_id INT NULL
ON DELETE SET NULL
3. Empleado sin manager
-- Si manager se va, empleado queda sin manager
manager_id INT NULL
ON DELETE SET NULL */

--------------------------------------------------------------------------------------------
/** ON DELETE RESTRICT (DEFAULT) **/
-- Previene eliminación del padre si tiene hijos. Es la acción por defecto.
CREATE TABLE clientes (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE ordenes (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
        ON DELETE RESTRICT  -- O sin especificar (es default)
);

/* Ejemplo Practico */
-- Insertar cliente y orden
INSERT INTO clientes (id, nombre) VALUES (1, 'Ana García');
INSERT INTO ordenes (cliente_id, total) VALUES (1, 299.99);

-- Intentar eliminar cliente
/*
DELETE FROM clientes WHERE id = 1; 
# Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails}
*/
-- Solución: Eliminar órdenes primero:
DELETE FROM ordenes WHERE cliente_id = 1;
DELETE FROM clientes WHERE id = 1;  -- Ahora funciona

/* ¿Cuando usar RESTRICT?
1. Cliente con órdenes
-- NO eliminar cliente con historial de compras
ON DELETE RESTRICT  -- Protege contra eliminación accidental
2. Departamento con empleados
-- NO eliminar departamento si tiene empleados
ON DELETE RESTRICT  -- Fuerza reasignación manual primero
3. Autor con libros publicados
-- NO eliminar autor con libros
ON DELETE RESTRICT  -- Preserva integridad histórica */

--------------------------------------------------------------------------------------------
/** ON UPDATE CASCADE **/
-- Cuando actualizas PRIMARY KEY del padre, actualiza automáticamente FKs en hijos.
CREATE TABLE clientes (
    id     INT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE ordenes (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
        ON UPDATE CASCADE  -- 🔑 Actualiza FKs automáticamente
);

/* Ejemplo Practico */
INSERT INTO clientes (id, nombre) VALUES (10, 'Ana García');
INSERT INTO ordenes (cliente_id, total) VALUES (10, 299.99), (10, 149.50);

-- Verificar
SELECT * FROM ordenes;
-- cliente_id = 10 en ambas

-- Cambiar id del cliente
UPDATE clientes SET id = 100 WHERE id = 10;
-- ✅ CASCADE actualiza órdenes automáticamente

-- Verificar
SELECT * FROM ordenes;
-- cliente_id ahora = 100 en ambas (actualizado automáticamente)