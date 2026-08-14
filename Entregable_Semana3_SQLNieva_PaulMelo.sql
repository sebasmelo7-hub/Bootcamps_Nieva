-- ======================================
-- ENTREGABLE SEMANA 3
-- BIBLIOTECA PUBLICA - BIBLIOTECH
-- Nombre: [PAUL SEBASTIAN MELO]
-- Fecha: [10-07-2026]
-- =====================================
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


/** PASO 3 - ERD USANDO dbdiagram.io **/
/**
// ============================================
//  BiblioTech — ERD completo (6 tablas)
//  Usando dbdiagram.io
// ============================================

Table categories {
  id          int [pk, increment]
  name        varchar [unique, not null]
  description text
}

Table authors {
  id         int [pk, increment]
  name       varchar [not null]
  country    varchar
  birth_date date
}

Table users {
  id              int [pk, increment]
  email           varchar [unique, not null]
  name            varchar [not null]
  membership_type varchar
}

Table books {
  id               int [pk, increment]
  isbn             varchar [unique, not null]
  title            varchar [not null]
  category_id      int [ref: > categories.id] // books → categories (N:1)
  publication_year int
  price            decimal
  stock            int
}

Table loans {
  id         int [pk, increment]
  user_id    int [ref: > users.id] // loans → users (N:1)
  book_id    int [ref: > books.id] // loans → books (N:1)
  loan_date  date
  due_date   date
  fine       decimal
}

Table book_authors {
  book_id      int [ref: > books.id]
  author_id    int [ref: > authors.id]
  author_order int
  indexes {
    (book_id, author_id) [pk] // PK compuesta
  }
}
**/
/* CONEXIONES EDR
-- (cada línea ref: > es una flecha)
Línea ref:	                         Flecha en el diagrama	 Relación
books.category_id > categories.id	|books → categories	    |N:1 (muchos libros, una categoría)
loans.user_id > users.id	        |loans → users	        |N:1 (muchos préstamos, un usuario)
loans.book_id > books.id	        |loans → books	        |N:1 (muchos préstamos, un libro)
book_authors.book_id > books.id	    |book_authors → books	|parte 1 de la N:M
book_authors.author_id > authors.id |book_authors → authors	|parte 2 de la N:M
*/

/* DIAGRAMA EDR
┌──────────────┐         ┌───────────────┐         ┌──────────────┐
│  CATEGORIES  │◄───┐    │     BOOKS     │    ┌───►│   AUTHORS    │
├──────────────┤    │    ├───────────────┤    │    ├──────────────┤
│ 🔑 id        │    │    │ 🔑 id         │    │    │ 🔑 id        │
│   name       │    │    │   isbn        │    │    │   name       │
│   descript.  │    │    │ 🔗 categ_id   │────┘    │   country    │
└──────────────┘    │    │   title       │         │   birth_date │
                    │    │   year, price │         └──────────────┘
                    │    │   stock       │                  ▲
                    │    └───────┬───────┘                  │
                    └────1:N─────┘                          │
                                 │                          │
                                 ▼                          │
                       ┌─────────────────────┐              │
                       │    BOOK_AUTHORS     │              │
                       │  (junction table)   │              │
                       ├─────────────────────┤              │
                       │ 🔑+🔗 book_id       │              │
                       │ 🔑+🔗 author_id     │──────N:M─────┘
                       │     author_order    │
                       └─────────────────────┘

┌──────────────┐         ┌───────────────────┐
│    USERS     │◄────────┤       LOANS       │
├──────────────┤   1:N   ├───────────────────┤
│ 🔑 id        │         │ 🔑 id             │
│   email      │         │ 🔗 user_id        │
│   name       │         │ 🔗 book_id        │──► BOOKS
│   membership │         │   loan_date       │
└──────────────┘         │   due_date        │
                         │   return_date     │
                         │   fine            │
                         └───────────────────┘
*/


DROP DATABASE IF EXISTS bibliotech_library;
CREATE DATABASE bibliotech_library;

USE bibliotech_library;

SELECT DATABASE ();
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
/*** FASE 2 - TABLAS PRINCIPALES ***/
/*
1. categories     (no depende de nadie)
2. authors        (no depende de nadie)
3. books          (depende de categories)
4. book_authors   (depende de books y authors)
5. users          (no depende de nadie)
6. loans          (depende de users y books)
*/

/** Eliminamos la tablas principales - si existe **/
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS loans;

/** Creamos la tabla categories **/
-- Atributos: id, name, description
CREATE TABLE categories (
    id           INT AUTO_INCREMENT PRIMARY KEY,   /** ID de la categoria - Llave primaria **/
    name         VARCHAR(50) UNIQUE NOT NULL,      /** Nombre de la categoria - Unico **/
    description  TEXT
);

/** Insertamos las categorías de los libros **/
INSERT INTO productos (name, descripcion)
VALUES
      ('Fiction',    'Novels and fiction stories'),
      ('Science',    'Scientific and technical books'),
      ('History',    'History books and biographies'),
      ('Children',   'Literature for children'),
      ('Technology', 'Programming, development, AI');

/** Creamos la tabla authors **/
-- Atributos: id, name, country, birth_date
CREATE TABLE authors (
    id          INT AUTO_INCREMENT PRIMARY KEY,  /** ID de la categoria - Llave primaria **/
    name        VARCHAR(150) NOT NULL,           /** Nombre del author(es) - No NULL **/
    country     VARCHAR(50),                     /** Pais de nacimiento **/
    birth_date  DATE,                            /** Fecha de nacimiento **/
    biography   TEXT                             /** Bibliografia **/
);

/** Insertamos los autores de los libros **/
INSERT INTO authors (name, country, birth_date)
VALUES
      ('Gabriel García Márquez', 'Colombia',       '1927-03-06'),   -- 1
      ('Isabel Allende',         'Chile',          '1942-08-02'),   -- 2
      ('Stephen Hawking',        'United Kingdom', '1942-01-08'),   -- 3
      ('J.K. Rowling',           'United Kingdom', '1965-07-31'),   -- 4
      ('Yuval Noah Harari',      'Israel',         '1976-02-24'),   -- 5
      ('Roald Dahl',             'United Kingdom', '1916-09-13'),   -- 6
      ('Andrew S. Tanenbaum',    'United States',  '1944-03-16'),   -- 7
      ('Ian Goodfellow',         'United States',  '1985-01-01'),   -- 8
      ('Yoshua Bengio',          'Canada',         '1964-03-05'),   -- 9
      ('Eric Matthes',           'United States',  '1970-01-01'),   -- 10
      ('Joshua Bloch',           'United States',  '1961-08-28');   -- 11

/** Creamos la tabla books **/
-- Atributos: id, isbn, title, category_id, publication_year, price, stock
CREATE TABLE books (
    id                 INT AUTO_INCREMENT PRIMARY KEY,      /** ID de la categoria - Llave primaria **/
    isbn               VARCHAR(20) UNIQUE NOT NULL,         /** Identificador unico de libros - ISBN **/
    title              VARCHAR(250) NOT NULL,               /** Titulo del libro - No NULL **/
    category_id        INT,                                 /** ID categoria, FK tabla categories **/
    publication_year   INT,                                 /** Anio de publicacion **/
    price              DECIMAL(10,2) NOT NULL,              /** Costo del libro - No 0 **/            
    stock              INT DEFAULT 0,                       /** Inventario **/
    is_active          BOOLEAN DEFAULT TRUE,                /** Se encuentra activo para loans **/
    added_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_books_categories
      FOREIGN KEY (category_id) REFERENCES categories(id)
      ON DELETE SET NULL,
    
    CONSTRAINT chk_year  CHECK (publication_year BETWEEN 1450 AND 2100),
    CONSTRAINT chk_price CHECK (price > 0),
    CONSTRAINT chk_stock CHECK (stock >= 0)
);

/** Insertamos los libros **/
INSERT INTO books (isbn, title, category_id, year_publication, price, stock)
VALUES
    -- Fiction (cat 1)
      ('978-0307474728', 'One Hundred Years of Solitude',            1, 1967, 18.99, 5),
      ('978-0142437247', 'The House of the Spirits',                 1, 1982, 16.50, 3),
      ('978-0439708180', 'Harry Potter and the Philosopher''s Stone',1, 1997, 22.99, 8),

      -- Science (cat 2)
      ('978-0553380163', 'A Brief History of Time',                  2, 1988, 15.99, 4),
      ('978-0062316097', 'Sapiens: A Brief History of Humankind',    2, 2011, 24.99, 6),
      ('978-0062464310', 'Homo Deus',                                2, 2015, 26.50, 4),

      -- History (cat 3)
      ('978-0062315007', '21 Lessons for the 21st Century',          3, 2018, 20.99, 5),

      -- Children (cat 4)
      ('978-0142410318', 'Matilda',                                  4, 1988, 12.99, 10),
      ('978-0142410387', 'Charlie and the Chocolate Factory',        4, 1964, 14.50, 7),
      ('978-0141365534', 'The BFG',                                  4, 1982, 13.99, 6),

      -- Technology (cat 5)
      ('978-0132126953', 'Modern Operating Systems',                 5, 2007, 89.99, 3),
      ('978-0262035613', 'Deep Learning',                            5, 2016, 75.00, 2),
      ('978-0135957059', 'Computer Networks',                        5, 2010, 95.50, 2),
      ('978-1593279288', 'Python Crash Course',                      5, 2019, 39.99, 8),
      ('978-0134685991', 'Effective Java',                           5, 2017, 54.99, 4);

/** Creamos las tablas users **/ 
-- Atributos: id, email, name, phone, membership_type
CREATE TABLE users (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    email            VARCHAR(150) UNIQUE NOT NULL, 
    name             VARCHAR(150) NOT NULL,
    phone            VARCHAR(20),
    membership_type  ENUM('basic', 'premium', 'vip') DEFAULT 'basic', /** ENUM - Lista enumerada por valores **/
    is_active        BOOLEAN DEFAULT TRUE,                            /** Usuario se encuentra activo **/
    registered_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/** Insertamos los usuarios **/
INSERT INTO users (email, name, phone, membership_type)
VALUES
      ('alice.garcia@email.com',     'Alice Garcia',     '555-0001', 'premium'),   -- 1
      ('charles.lopez@email.com',    'Charles Lopez',    '555-0002', 'basic'),     -- 2
      ('mary.torres@email.com',      'Mary Torres',      '555-0003', 'vip'),       -- 3
      ('john.perez@email.com',       'John Perez',        NULL,      'basic'),     -- 4
      ('lucy.martinez@email.com',    'Lucy Martinez',    '555-0005', 'premium'),   -- 5
      ('sophie.rodriguez@email.com', 'Sophie Rodriguez', '555-0006', 'basic'),     -- 6
      ('david.fernandez@email.com',  'David Fernandez',   NULL,      'basic');     -- 7

/** Creamos las tablas loans **/ 
-- Atributos: id, user_id, book_id, loan_date, due_date, return_date, fine, notes
CREATE TABLE loans (
    id           INT AUTO_INCREMENT PRIMARY KEY,       /** ID de la categoria - Llave primaria **/
    user_id      INT NOT NULL,                         /** ID usuarios, FK tabla users **/
    book_id      INT NOT NULL,                         /** ID libros, FK tabla books **/
    loan_date    DATE NOT NULL DEFAULT (CURRENT_DATE), /** Fecha prestamo **/
    due_date     DATE NOT NULL,
    return_date  DATE,
    fine         DECIMAL(10,2) DEFAULT 0.00,
    notes        TEXT,

    CONSTRAINT fk_loans_users
      FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE RESTRICT, -- No puedes borrar un usuario que tiene prestamos

    CONSTRAINT fk_loans_books
      FOREIGN KEY (book_id) REFERENCES books(id)
      ON DELETE RESTRICT, -- No puedes borrar un libro prestado

    CONSTRAINT chk_fine CHECK (fine >= 0),
    CONSTRAINT chk_return_date CHECK (
        return_date IS NULL OR
        return_date >= loan_date
    )
);

SHOW TABLES;
DESCRIBE categories;
DESCRIBE authors;
DESCRIBE books;
DESCRIBE users;

/* Validamos la informacion */
SELECT
  SELECT COUNT(*) FROM categories   AS categories,
  SELECT COUNT(*) FROM authors      AS authors,
  SELECT COUNT(*) FROM books        AS books,
  SELECT COUNT(*) FROM users        AS users;
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
/*** FASE 3 - TABLA UNIION N:M ***/

/** PASO 1 - CREAR TABLA UNION - book_authors **/

/** Eliminamos la tabla book_authors - si existe **/
DROP TABLE IF EXISTS book_authors;

/** Creamos la tabla book_authors **/
-- Atributos: book_id, author_id, author_order
CREATE TABLE book_authors (
    book_id       INT NOT NULL,   /** ID libros, FK tabla books **/
    author_id     INT NOT NULL,   /** ID autores, FK tabla authors **/
    author_order  INT DEFAULT 1,  /** 1 = autor principal, 2 = co-autor, etc **/

    PRIMARY KEY (book_id, author_id)

    CONSTRAINT fk_ba_books
      FOREIGN KEY (book_id) REFERENCES books(id)
      ON DELETE CASCADE,
    
    CONSTRAINT fk_ba_authors
      FOREIGN KEY (author_id) REFERENCES authors(id)
      ON DELETE CASCADE
);

/** PASO 2 - CARAGA INFORMACION TABLA book_authors **/

/** Insertamos parejas libro-autor en la tabla book_authors **/
INSERT INTO book_authors (book_id, author_id, author_order)
VALUES
      (1,  1, 1),   -- One Hundred Years → García Márquez
      (2,  2, 1),   -- The House of the Spirits → Allende
      (3,  4, 1),   -- Harry Potter → Rowling
      (4,  3, 1),   -- A Brief History → Hawking
      (5,  5, 1),   -- Sapiens → Harari
      (6,  5, 1),   -- Homo Deus → Harari
      (7,  5, 1),   -- 21 Lessons → Harari
      (8,  6, 1),   -- Matilda → Dahl
      (9,  6, 1),   -- Charlie → Dahl
      (10, 6, 1),   -- The BFG → Dahl
      (11, 7, 1),   -- Modern Operating Systems → Tanenbaum
      (12, 8, 1),   -- Deep Learning → Goodfellow (autor principal)
      (12, 9, 2),   -- Deep Learning → Bengio (co-autor)   ← ¡un libro, dos autores!
      (13, 7, 1),   -- Computer Networks → Tanenbaum
      (14, 10, 1),  -- Python Crash Course → Matthes
      (15, 11, 1);  -- Effective Java → Bloch

/** PASO 3 - VERIFICAR RELACION N:M **/

-- Libros co-escritos (más de un autor) — debe salir solo Deep Learning
SELECT b.title, COUNT(*) AS num_authors
FROM book_authors ba
JOIN books b ON ba.book_id = b.id
GROUP BY ba.book_id, b.title
HAVING COUNT(*) > 1;
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
/*** FASE 4 - CARGAR PRESTAMOS ***/
/** Insertamos parejas libro-autor en la tabla book_authors **/
INSERT INTO loans (user_id, book_id, loan_date, due_date, return_date, fine, notes)
VALUES
      -- Devueltos (históricos, multa ya guardada — tarifa: $2.50 por día de retraso)
      (1, 1, '2024-01-01', '2024-01-15', '2024-01-14',  0.00),    -- Alice, devolvió a tiempo
      (2, 3, '2024-01-05', '2024-01-19', '2024-01-25', 15.00),    -- Charles, 6 días tarde × 2.50
      (3, 5, '2024-01-08', '2024-01-22', '2024-01-20',  0.00),    -- Mary, devolvió antes
      (1, 8, '2024-01-10', '2024-01-24', '2024-01-23',  0.00),    -- Alice, a tiempo
      (4, 9, '2024-01-12', '2024-01-26', '2024-02-05', 25.00),    -- John, 10 días tarde × 2.50

      -- Activos (return_date = NULL; fechas relativas a HOY)
      -- Usamos DATE_SUB(CURDATE() para que las fechas sean recientes basados en el día de ejecución en SQL
      (1,  4, DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_SUB(CURDATE(), INTERVAL  6 DAY), NULL, 0.00),  -- Alice, 6 días vencido
      (5,  5, DATE_SUB(CURDATE(), INTERVAL 12 DAY), DATE_ADD(CURDATE(), INTERVAL  2 DAY), NULL, 0.00),  -- Lucy, al corriente
      (6, 10, DATE_SUB(CURDATE(), INTERVAL  9 DAY), DATE_ADD(CURDATE(), INTERVAL  5 DAY), NULL, 0.00),  -- Sophie, al corriente
      (7, 14, DATE_SUB(CURDATE(), INTERVAL  6 DAY), DATE_ADD(CURDATE(), INTERVAL  8 DAY), NULL, 0.00),  -- David, al corriente
      (2, 11, DATE_SUB(CURDATE(), INTERVAL  4 DAY), DATE_ADD(CURDATE(), INTERVAL 10 DAY), NULL, 0.00);  -- Charles, al corriente
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
/*** FASE 5 - REPORTES CON JOINs ***/

/** Consulta - Libros de tecnología por su autor **/
SELECT
      b.title,
      a.name as author,
      b.stock
FROM books        b
JOIN categories   c  on b.category_id = c.id
JOIN book_authors ba on ba.book_id    = b.id
JOIN authors      a  on ba.author_id  = a.id
WHERE c.name = 'Technology'
ORDER BY ba.author_order;

/** Consulta - Usuarios con préstamos activos **/

/** Consulta - LTop 5 libros más prestados **/

/** Consulta - Total de multas por usuario **/
