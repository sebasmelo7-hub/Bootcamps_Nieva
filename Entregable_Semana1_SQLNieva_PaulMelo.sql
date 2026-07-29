-- ======================================
-- ENTREGABLE SEMANA 1 — CATÁLOGO STREAMFLIX
-- Nombre: [PAUL SEBASTIAN MELO]
-- Fecha: [25-07-2026]
-- ======================================

USE streamflix;

/*** FASE 1 - CREAR TABLA movies ***/

/** Eliminamos la tabla movies - si existe **/
DROP TABLE IF EXISTS movies; 

/** Creamos la tabla movies **/
CREATE TABLE movies (
    id                INT AUTO_INCREMENT PRIMARY KEY, /** ID película - Llave primaria **/
    title             VARCHAR(150) NOT NULL,          /** Título de la película **/
    original_title    VARCHAR(200),
    director          VARCHAR(100) NOT NULL,          /** Director de la película **/
    release_year      INT,                            /** Tipo o categoría de la película **/
    duration_min      INT,                            /** Duración en minutos **/
    genre             VARCHAR(50) NOT NULL,
    rating            DECIMAL(3, 1),                  /** Clasificación de la película **/
    synopsis          TEXT,
    original_language VARCHAR(50) DEFAULT 'English',
    is_featured       BOOLEAN DEFAULT FALSE,
    added_date        DATE DEFAULT (CURRENT_DATE)
);

DESCRIBE movies;

SHOW TABLES;
SELECT COUNT(*) 
FROM movies;

/*** FASE 2 - INSERTAR DATOS EN TABLA movies ***/

/** Insertamos las películas en la tabla movies **/
INSERT INTO movies (title, original_title, director, release_year, duration_min, genre, rating, synopsis, original_language, is_featured)
VALUES 
    ('El Padrino', 'The Godfather', 'Francis Ford Coppola', 1972, 175, 'Drama', 9.2,
    'La historia de la familia Corleone en el mundo de la mafia italiana.', 'English', TRUE),
    ('Pulp Fiction', 'Pulp Fiction', 'Quentin Tarantino', 1994, 154, 'Crimen', 8.9,
    'Historias entrelazadas de criminales en Los Ángeles.', 'English', TRUE),
    ('El Caballero Oscuro', 'The Dark Knight', 'Christopher Nolan', 2008, 152, 'Acción', 9.0,
    'Batman enfrenta al Joker, un maestro criminal.', 'English', TRUE),
    ('Forrest Gump', 'Forrest Gump', 'Robert Zemeckis', 1994, 142, 'Drama', 8.8,
    'La historia de un hombre con bajo coeficiente intelectual pero buenas intenciones.', 
    'English', FALSE),
    ('Titanic', 'Titanic', 'James Cameron', 1997, 195, 'Romance', 7.8,
    'Una historia de amor a bordo del desafortunado RMS Titanic.', 'English', TRUE),
    ('La Matriz', 'The Matrix', 'The Wachowskis', 1999, 136, 'Ciencia Ficción', 8.7,
    'Un hacker descubre que la realidad es una simulación.', 'English', TRUE),
    ('Gladiador', 'Gladiator', 'Ridley Scott', 2000, 155, 'Acción', 8.5,
    'Un general romano busca venganza contra un emperador corrupto.', 'English', FALSE),
    ('Avatar', 'Avatar', 'James Cameron', 2009, 162, 'Ciencia Ficción', 7.8,
    'Los humanos exploran y explotan el mundo alienígena Pandora.', 'English', TRUE),
    ('El Rey León', 'The Lion King', 'Roger Allers', 1994, 88, 'Animación', 8.5,
    'Un joven príncipe león debe recuperar su reino.', 'English', TRUE),
    ('Buscando a Nemo', 'Finding Nemo', 'Andrew Stanton', 2003, 100, 'Animación', 8.1,
    'Un pez payaso busca a su hijo perdido en el océano.', 'English', TRUE),
    ('Frozen', 'Frozen', 'Chris Buck', 2013, 102, 'Animación', 7.4,
    'Dos hermanas enfrentan desafíos mágicos en un reino helado.', 'English', TRUE),
    ('Shrek', 'Shrek', 'Andrew Adamson', 2001, 90, 'Animación', 7.9,
    'Un ogro emprende una aventura para rescatar a una princesa.', 'English', TRUE),
    ('Interestelar', 'Interstellar', 'Christopher Nolan', 2014, 169, 'Ciencia Ficción', 8.6,
    'Un equipo viaja a través de un agujero de gusano buscando un nuevo hogar para la humanidad.',
    'English', TRUE),
    ('El Club de la Pelea', 'Fight Club', 'David Fincher', 1999, 139, 'Drama', 8.8,
    'Un insomne crea un club de lucha subterráneo.', 'English', FALSE),
    ('La Bella y la Bestia', 'Beauty and the Beast', 'Gary Trousdale', 1991, 84, 'Animación', 8.0,
    'Una joven se enamora de un príncipe maldito.', 'English', TRUE);
    
SELECT COUNT(*) AS Total
FROM movies;

SELECT id, title, original_title, release_year, added_date
FROM movies;

/*** FASE 3 - CONSULTAS ***/

/** Q1 - Listado películas con diferentes columnas **/
SELECT title, original_title, release_year, duration_min, genre
FROM movies;

/** Q2 - Listado de películas de Animación **/
SELECT title, duration_min, genre, rating
FROM movies
WHERE genre = "Animación";

/** Q3 - Listado de directores en la tabla movies ordenados alfabeticamente **/
SELECT DISTINCT director
FROM movies
ORDER BY director;

/** Q4 - Listado de películas no destacadas - is_featured = FALSE **/
SELECT title, rating, is_featured
FROM movies
WHERE is_featured = FALSE;

/** Q5 - Listado de películas de Acción y destacadas  **/
SELECT title, duration_min, genre, rating, is_featured
FROM movies
WHERE genre = "Acción" AND is_featured = TRUE;

/** Q6 - Listado de películas estrenadas entre 2000 y 2010  **/
SELECT title, release_year
FROM movies
WHERE release_year BETWEEN 2000 AND 2010
ORDER BY release_year;

/** Q7 - Listado de películas con duración mayor o igual a 100 min  **/
SELECT title, duration_min, genre
FROM movies
WHERE duration_min >= 100;

/** Q8 - Listado de películas de Drama y Romance  **/
SELECT title, genre
FROM movies
WHERE genre IN ('Drama', 'Romance');

/** Q9 - Listado de películas cuyo titulo contiene "la"  **/
SELECT title
FROM movies
WHERE title LIKE '%la%';

/** Q10 - Listado de directores cuyo nombre comienza con "James"  **/
SELECT DISTINCT director
FROM movies
WHERE director LIKE 'James%';

/** Q11 - Top 5 películas mejor calificadas  **/
SELECT title, rating
FROM movies
ORDER BY rating DESC
LIMIT 5;

/** Q12 - Listado de películas ordenadas por genero  **/
SELECT title, genre
FROM movies
ORDER BY genre;

/** Q12 - Top 5 películas de mayor duración  **/
SELECT title, duration_min
FROM movies
WHERE duration_min IS NOT NULL
ORDER BY duration_min DESC
LIMIT 3;

/*** FASE 4 - RETOS ***/

/** Reto 1 - Búsqueda multi-condición  **/
SELECT title, genre, release_year, rating
FROM movies
WHERE genre IN ("Acción", "Ciencia Ficción") AND rating > 8.0 AND release_year > 2000 
ORDER BY rating;

/** Reto 1 - Listado de géneros únicos disponibles  **/
SELECT DISTINCT genre
FROM movies
ORDER BY genre;

/** Reto 3 - Cuádruple filtro  **/
SELECT title, is_featured, duration_min, rating
FROM movies
WHERE is_featured = TRUE 
AND duration_min > 140
AND rating >= 8.5
ORDER BY rating DESC;

-- DECISIONES DE DISEÑO
-- ======================================
--
-- 1. ¿Por qué DECIMAL(3,1) para rating en vez de FLOAT?
--    [Porque la columna rating relaciona una calificación que suele ser un número de uno o
--     máximo dos decimales DECIMAL me permite definir ese criterio]
--
-- 2. ¿Por qué VARCHAR(200) para title en vez de TEXT?
--    [Aunque TEXT me permite definir una columna sin limite de caracteres, al usar VARCHAR
--     puedo definir un limite apropiado para películas]
--
-- 3. ¿Qué ventaja tiene AUTO_INCREMENT en id?
--    [Garantiza que los datos se inserten en un ID unico garantizando que no existan duplicados]
--
-- 4. Si tuvieras que agregar rental_price, ¿qué tipo usarías?
--    [Usaría DECIMAL ya que me permite definir cuantos la cantidad de digitos y los decimales.alter
--     considerando que es dinero podría ser DECIMAL(5,3) considerando el valor en miles - COP]
--
-- 5. ¿Qué fue lo que más te sorprendió esta semana?
--    [Entender la importancia al momento de definir un dato o analizar como lo definieron para una
--     base de datos especifica. Al comprender esto, te permite darte una idea de la importancia de
--     cada atributo en la base de datos]
