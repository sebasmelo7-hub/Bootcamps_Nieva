/*** FASE 1 - TABLAS PRINCIPALES ***/
/*
1. departments    (no depende de nadie)
2. professors     (depende de departments & de sí misma vía manager_id)
3. students       (no depende de nadie)
4. courses        (depende de professors y departments)
5. enrollments    (depende de students y courses)  ← la N:M de Week 3
*/

use techmaster_university;

/** Eliminamos la tablas principales - si existe **/
drop table if exists departments;
drop table if exists professors;
drop table if exists students;
drop table if exists courses;
drop table if exists enrollments;

/** CREAR TABLAS **/
/** 1. Creamos la tabla departments **/
-- Atributos: id, name, budget, founding_date
create table departments (
    id            int auto_increment primary key,   /** ID de la categoria - Llave primaria **/
    name          varchar(100) unique not null,     /** Nombre del departamento - Unico - No Nulo **/
    budget        decimal(12,2),                    /** Presupuesto **/
    founding_date date                              /** Fecha de fundacion **/
);

/** 2. Creamos la tabla professors **/
/* 
professors tiene una FK hacia sí misma (manager_id → professors.id) — 
una relación recursiva para modelar la jerarquía 
"cada profesor tiene un jefe que también es profesor". 
*/
-- Atributos: id, name, email, department_id, manager_id, salary, hire_date
create table professors (
    id             int auto_increment primary key,  /** ID del profesor - Llave primaria **/
    name           varchar(100) not null,           /** Nombre del profesor - No Nulo **/
    email          varchar(50)  unique,             /** Correo profesores **/
    department_id  int,                             /** ID departamento, FK tabla departments **/
    manager_id     int,                             /** ID manager, FK hacia sí misma (manager_id → professors.id) **/
    salary         decimal(10,2),
    hire_date      date,                            /** Fecha de contratación **/
    
    constraint fk_professors_departments
		foreign key (department_id) references departments(id),
	constraint fk_professors_manager
		foreign key (manager_id) references professors(id)
);

/** 3. Creamos la tabla students **/
-- Atributos: id, name, email, birth_date, enrollment_date, gpa, status
create table students (
    id               int auto_increment primary key,          /** ID del estudiante - Llave primaria **/
    name             varchar(100) not null,                   /** Nombre del estudiante - No Nulo **/
    email            varchar(50)  unique,                     /** Correo estudiantes **/
    birth_date       date,                                    /** Fecha de cumpleaños estudiante **/
    enrollment_date  date,                                    /** Fecha de inscripción **/
    gpa              decimal(4,2),                        
    status           enum('active', 'graduated', 'withdrawn') 
						default 'active'                      /** Estado del estudiante **/
);

/** 4. Creamos la tabla courses **/
-- Atributos: id, code, name, credits, professor_id, department_id, max_capacity, semester
create table courses (
    id             int auto_increment primary key, /** ID del curso - Llave primaria **/
    code           varchar(20)  unique not null,   /** Codigo del curso - Unico - No Nulo **/
    name           varchar(100) not null,          /** Nombre del curso - No Nulo **/
    credits        int not null,                   /** Creditos por estudiante - No Nulo **/
    professor_id   int,                            /** ID profesor, FK tabla professors **/
    department_id  int not null,                   /** ID departamento, FK tabla departments **/
    max_capacity   int default 30,                 /** Capacidad maxima del curso - Por defecto = 30 **/     
    semester       varchar(10),                    /** Semestre **/
    
    constraint fk_courses_departments
		foreign key (department_id) references departments(id),
	constraint fk_coruses_professors
		foreign key (professor_id) references professors(id),
        
    constraint chk_credits check (credits > 0)
);

/** 5. Creamos la tabla enrollments **/
-- Atributos: student_id, course_id, enrollment_date, grade, status
create table enrollments (
    student_id       int,                             /** ID estudiante, FK tabla students **/
    course_id        int,                             /** ID curso, FK tabla coruses **/
    enrollment_date  date default (current_date),     /** Fecha de inscripción **/
    grade            decimal(4,2),                        
    status           enum('enrolled', 'passed', 'failed', 'withdrawn')
						default 'enrolled',           /** Estado del estudiante **/
    
    constraint fk_enrollment_students
		foreign key (student_id) references students(id)
        on delete cascade,
	constraint fk_enrollment_courses
		foreign key (course_id) references courses(id)
        on delete cascade,
        
    constraint chk_grade 
		check (grade >= 0 and grade <= 10)
);
--------------------------------------------------------------------------------------------------
/** INSERTAR DATOS EN TABLAS **/
/** Insertamos departamentos en tabla departments **/
-- Atributos: id, name, budget, founding_date
insert into departments (name, budget, founding_date)
values
	('Computer Science', 5000000.00, '1998-08-15'),
    ('Mathematics',      3500000.00, '1995-01-10'),
    ('Physics',          4200000.00, '1995-01-10'),
    ('Humanities',       2000000.00, '2005-03-22'),
    ('Biology',          3800000.00, '2000-09-01');

/** Insertamos profesores en tabla professors **/
-- Atributos: id, name, email, department_id, manager_id, salary, hire_date
-- id 1, 2, 6, 8, 9 son jefes de departamento (manager_id NULL)
insert into professors (name, email, department_id, manager_id, salary, hire_date)
values
	('Dr. Robert Mendez',   'rmendez@uni.edu',   1, null, 95000, '2010-08-01'),  -- 1  Jefe Computer Science
    ('Dr. Sara Lopez',      'slopez@uni.edu',    2, null, 92000, '2008-01-15'),  -- 2  Jefa Mathematics
    ('Dr. Michael Vega',    'mvega@uni.edu',     1,    1, 78000, '2015-03-10'),  -- 3
    ('Dr. Anna Torres',     'atorres@uni.edu',   1,    1, 76000, '2017-09-05'),  -- 4
    ('Dr. Charles Ruiz',    'cruiz@uni.edu',     2,    2, 72000, '2018-02-12'),  -- 5
    ('Dr. Elena Martinez',  'emartinez@uni.edu', 3, null, 88000, '2012-08-20'),  -- 6  Jefa Physics
    ('Dr. Felix Castro',    'fcastro@uni.edu',   3,    6, 70000, '2019-01-15'),  -- 7
    ('Dr. Gabrielle Perez', 'gperez@uni.edu',    4, null, 75000, '2014-09-01'),  -- 8  Jefa Humanities
    ('Dr. Hector Silva',    'hsilva@uni.edu',    5, null, 80000, '2013-08-15'),  -- 9  Jefe Biology
    ('Dr. Isabel Ramos',    'iramos@uni.edu',    5,    9, 68000, '2020-03-01'),  -- 10
    ('Dr. James Nunez',     'jnunez@uni.edu',    4,    8, 65000, '2021-09-10');  -- 11

/** Insertamos estdiantes en tabla students **/
-- Atributos: id, name, email, birth_date, enrollment_date, gpa, status
insert into students (name, email, birth_date, enrollment_date, gpa, status)
values
	('Alice Garcia',    'agarcia@uni.edu',    '2002-05-15', '2020-08-20', 8.5,  'active'),
    ('Brian Hernandez', 'bhernandez@uni.edu', '2001-11-22', '2020-08-20', 7.2,  'active'),
    ('Carol Ruiz',      'cruiz.stu@uni.edu',  '2003-03-10', '2021-08-20', 9.1,  'active'),
    ('Daniel Torres',   'dtorres@uni.edu',    '2002-07-08', '2020-08-20', 8.8,  'active'),
    ('Emma Lopez',      'elopez.stu@uni.edu', '2001-12-30', '2019-08-20', 9.5,  'graduated'),
    ('Frank Salinas',   'fsalinas@uni.edu',   '2003-04-25', '2021-08-20', 6.8,  'active'),
    ('Grace Mendez',    'gmendez@uni.edu',    '2002-09-12', '2020-08-20', 8.2,  'active'),
    ('Hugo Vega',       'hvega@uni.edu',      '2003-06-18', '2022-08-20', 7.9,  'active'),
    ('Irene Castro',    'icastro@uni.edu',    '2001-10-05', '2019-08-20', 5.5,  'withdrawn'),
    ('Jacob Nunez',     'jnunez.stu@uni.edu', '2002-08-29', '2020-08-20', 8.0,  'active'),
    ('Karla Romero',    'kromero@uni.edu',    '2003-01-17', '2022-08-20', null, 'active'),  -- sin GPA
    ('Lucas Aguilar',   'laguilar@uni.edu',   '2004-02-22', '2023-08-20', null, 'active');  -- nuevo, sin notas

/** Insertamos cursos en tabla courses **/
-- Atributos: id, code, name, credits, professor_id, department_id, max_capacity, semester
insert into courses (code, name, credits, professor_id, department_id, max_capacity, semester)
values
	('COMP101', 'Introduction to Programming', 4, 1,    1, 30, '2026-1'),
    ('COMP201', 'Data Structures',             4, 3,    1, 25, '2026-1'),
    ('COMP301', 'Databases',                   4, 4,    1, 25, '2026-1'),
    ('MATH101', 'Differential Calculus',       5, 2,    2, 35, '2026-1'),
    ('MATH201', 'Linear Algebra',              4, 5,    2, 30, '2026-1'),
    ('PHYS101', 'General Physics',             4, 6,    3, 30, '2026-1'),
    ('PHYS202', 'Quantum Mechanics',           5, 7,    3, 20, '2026-1'),
    ('HUMA101', 'Contemporary Philosophy',     3, 8,    4, 40, '2026-1'),
    ('HUMA201', 'Latin American Literature',   3, 11,   4, 40, '2026-1'),
    ('BIOL101', 'Cell Biology',                4, 9,    5, 28, '2026-1'),
    ('BIOL202', 'Molecular Genetics',          5, 10,   5, 22, '2026-1'),
    ('COMP401', 'Distributed Systems',         4, null, 1, 20, '2026-1');  -- sin profesor asignado

/** Insertamos inscripciones en la tabla enrollments **/
-- Atributos: student_id, course_id, enrollment_date, grade, status
insert into enrollments (student_id, course_id, grade, status)
values
	(1, 1, 9.0,  'passed'),   (1, 4, 8.5,  'passed'),   (1, 6, null, 'enrolled'),  -- Alice
    (2, 1, 7.0,  'passed'),   (2, 4, 6.5,  'failed'),   (2, 8, null, 'enrolled'),  -- Brian
    (3, 1, 9.5,  'passed'),   (3, 2, 9.0,  'passed'),   (3, 3, null, 'enrolled'),
    (3, 4, 9.8,  'passed'),                                                         -- Carol
    (4, 1, 8.5,  'passed'),   (4, 2, 9.0,  'passed'),   (4, 3, null, 'enrolled'),  -- Daniel
    (5, 1, 9.5,  'passed'),   (5, 2, 9.8,  'passed'),   (5, 3, 9.5,  'passed'),
    (5, 4, 10.0, 'passed'),                                                         -- Emma (graduada)
    (6, 4, 5.5,  'failed'),   (6, 8, 7.0,  'passed'),                               -- Frank
    (7, 6, 8.5,  'passed'),   (7, 7, null, 'enrolled'),                             -- Grace
    (8, 1, null, 'enrolled'), (8, 4, null, 'enrolled'),                             -- Hugo
    -- Irene (withdrawn): sin inscripciones, a propósito
    (10, 8, 7.5, 'passed'),   (10, 9, null, 'enrolled'),                            -- Jacob
    (11, 1, null, 'enrolled'), (11, 4, null, 'enrolled');                           -- Karla
    -- Lucas: sin inscripciones todavía (recién ingresó)

show tables;
describe departments;
describe professors;
describe students;
describe courses;

/* Validamos la informacion */
select
  (select count(*) from departments)  as departments,
  (select count(*) from professors)   as professors,
  (select count(*) from students)     as students,
  (select count(*) from courses)      as courses,
  (select count(*) from enrollments)  as enrollments;
  
select 
	'departments' as table_name,
    count(*)      as row_count
from departments
union all select 'professors',  count(*) from professors
union all select 'students',    count(*) from students
union all select 'courses',     count(*) from courses
union all select 'enrollments', count(*) from enrollments;

/** Trampa intencional — la PK compuesta protege la N:M **/
-- Brian (student_id = 2) ya está inscrito en COMP101 (course_id = 1). 
-- Intentamos inscribirlo otra vez:
insert into enrollments (student_id, course_id, grade, status)
value
	(2, 1, null, 'enrolled');

select student_id, course_id, grade, status
from enrollments
where student_id = 2;

/** Con la configuración actual la PK no protege la N:M **/
-- requiere añadir PK compuesta -> primary key (student_id, course_id)
/* 1. Eliminar duplicados de la tabla enrollments */
delete
from enrollments
where student_id = 2 and course_id = 1 and grade is null and status = 'enrolled';

/* Agregamos restriccción PK compuesta */
alter table enrollments
add primary key (student_id, course_id);

-- Intentamos inscribirlo otra vez:
insert into enrollments (student_id, course_id, grade, status)
value
	(2, 1, null, 'enrolled');
-- Error Code: 1062. Duplicate entry '2-1' for key 'enrollments.PRIMARY'
