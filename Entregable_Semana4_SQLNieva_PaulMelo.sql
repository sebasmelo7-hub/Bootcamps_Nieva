-- ======================================
-- ENTREGABLE SEMANA 4
-- UNIVERSIDAD TECHMASTER - TECHMASTER
-- Nombre: [PAUL SEBASTIAN MELO]
-- Fecha: [28-08-2026]
-- =====================================
/*** FASE 0 - MONTAR SISTEMA ESCOLAR ***/
-- Base de datos cruda con: departamentos, profesores, estudiantes, cursos, inscripciones
-- Responder 15 preguntas de negocio: 
-- ¿quién enseña qué?, ¿qué estudiantes no se han inscrito en nada?, 
-- ¿qué profesor gana más que su jefe?, ¿qué cursos están vacíos?...

/** PASO 1 - DISEÑAR ERD USANDO dbdiagram.io **/
/**
// ============================================
//  TechMaster University — ERD completo (5 tablas)
//  Usando dbdiagram.io
// ============================================

Table departments {
  id            int     [pk, increment]
  name          varchar [unique, not null]
  budget        decimal                      // Presupuesto
  founding_date date                         // Fecha fundacion
}

Table professors {
  id             int     [pk, increment]
  name           varchar [not null]
  email          varchar [unique]
  department_id  int     [ref: > department.id]  // professors → departments (N:1)
  manager_id     int     [ref: > professors.id]  // 👈 SELF FK: it points to ITS OWN table!
  salary         decimal
  hire_date      date
}

Table students {
  id              int     [pk, increment]
  name            varchar [not null]
  email           varchar [unique]
  birth_date      date                     // Fecha cumpleaños
  enrollment_date date                     // Fecha inscripcion
  gpa             decimal
  status          varchar
}

Table courses {
  id            int     [pk, increment]
  code          varchar [unique, not null]
  name          varchar [not null]
  credits       int     [not null]
  professor_id  int     [ref: > professors.id]   // courses → professors (N:1)
  department_id int     [ref: > departments.id]  // courses → departments (N:1)
  max_capacity  int
  semester      varchar
}

Table enrollments {
  student_id      int     [ref: > students.id]  // enrollments → students
  course_id       int     [ref: > courses.id]   // enrollments → courses
  enrollment_date date                          // Fecha inscripcion
  grade           decimal                       // grado
  status          varchar
  indexes {
    (student_id, course_id) [pk]                // composite PK (Week 3's N:M)
  }
}
**/
/* CONEXIONES EDR
-- (cada línea ref: > es una flecha)
Línea ref:	                                Flecha en el diagrama	    Relación
professors.department_id > departments.id	professors → departments	N:1 (many professors, one department)
professors.manager_id > professors.id	    professors → professors	    SELF FK — the arrow leaves and returns to the same box (Phase 5)
courses.professor_id > professors.id	    courses → professors	    N:1 (many courses, one professor)
courses.department_id > departments.id	    courses → departments	    N:1 (many courses, one department)
enrollments.student_id > students.id	    enrollments → students	    part 1 of the N:M
enrollments.course_id > courses.id	        enrollments → courses	    part 2 of the N:M
*/

/* DIAGRAMA EDR
┌───────────────┐         ┌────────────────────┐         ┌───────────────┐
│  DEPARTMENTS  │         │     PROFESSORS     │         │   STUDENTS    │
├───────────────┤         ├────────────────────┤         ├───────────────┤
│ 🔑 id         │<────────│ 🔗 department_id   │         │ 🔑 id         │
│    name       │   1:N   │ 🔑 id        <──┐  │         │    name       │
│    budget     │         │ 🔗 manager_id ──┘  │         │    gpa        │
└───────────────┘         │    salary  SELF FK │         │    status     │
      ^                   └────────────────────┘         └───────────────┘
      │                        ^                                ^
      │ 1:N                    │ 1:N                            │ 1:N
      │ (department_id)        │ (professor_id)                 │ (student_id)
      │                        │                                │
┌─────┴──────────────────┐    │         ┌──────────────────┐   │
│        COURSES         │────┘         │   ENROLLMENTS    │───┘
├────────────────────────┤              ├──────────────────┤
│ 🔑 id                  │<─────────────│ 🔑🔗 course_id   │
│ 🔗 professor_id        │     1:N      │ 🔑🔗 student_id  │
│ 🔗 department_id       │              │    grade         │
│    code, credits       │              │    status        │
└────────────────────────┘              └──────────────────┘
                                         (composite PK made of two FKs =
                                          the students ↔ courses N:M)
*/


drop database if exists techmaster_university;
create database techmaster_university;

use techmaster_university;

select database();
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
/*** FASE 1 - TABLAS PRINCIPALES ***/
/*
1. departments    (no depende de nadie)
2. professors     (depende de departments & de sí misma vía manager_id)
3. students       (no depende de nadie)
4. courses        (depende de professors y departments)
5. enrollments    (depende de students y courses)  ← la N:M de Week 3
*/

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
	
    primary key (student_id, course_id),
    
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
describe professor;
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
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
/*** FASE 2 - INNER JOIN ***/
/*
┌───────────────┐                ┌──────────────────┐
│  DEPARTMENTS  │      1:N       │    PROFESSORS    │
├───────────────┤                ├──────────────────┤
│ 🔑 id         │<───────────────│ 🔗 department_id │
│    name       │                │    name          │
└───────────────┘                └──────────────────┘

          ON p.department_id = d.id   (🔗 FK = 🔑 PK)
*/

/** QUERY 1 - CADA PROFESOR CON EL NOMBRE DE SU DEPARTAMENTO **/
-- on p.department_id = d.id
/* Validamos la lista de departamentos */
select *
from departments;

/* Validamos la lista de profesores */
select *
from professors;

/* Usamos JOIN para traer profesor - departamento */
select 
	p.name as professor,
    d.name as department
from professors p
join departments d on p.department_id = d.id
order by d.name, p.name;

/** QUERY 2 - CURSO CON SU PROFESOR Y SU DEPARTAMENTO **/
-- on c.department_id = d.id
-- on c.professor_id  = p.id
/* Validamos la lista de cursos */
-- Existe un curso sin asignación de profesor
select *
from courses;

/* Validamos la lista de profesores */
select *
from professors;

/* Validamos la lista de departamentos */
select *
from departments;

/* Usamos JOIN para traer curso - profesor - departamento */
/* 1. Usamos JOIN para traer curso - profesor */
select 
	c.code as code_course,
    c.name as course,
    p.name as professor
from courses    c
join professors p on c.professor_id = p.id
order by p.name, c.name;

/* 2. Usamos JOIN para traer curso - profesor - departamento */
select 
	c.code as code_course,
    c.name as course,
    p.name as professor,
    d.name as department
from courses     c
join professors  p on c.professor_id  = p.id
join departments d on c.department_id = d.id
order by d.name, p.name, c.name;

/** QUERY 3 - ESTUDIANTES EN "Differential Calculus" CON CALIFICACION **/
-- on e.student_id = s.id
-- on e.course_id  = c.id
/* Validamos la lista de estudiantes */
select *
from students;

/* Validamos la lista de cursos */
select *
from courses;

-- No existe relacion directa entre estudiantes - cursos
-- Usamos inscripciones para unir estudiantes y cursos
/* Validamos la lista de inscripciones */
select *
from enrollments;

/* Usamos JOIN para traer estudiante - inscripcion - curso - calificacion */
/* 1. Usamos JOIN para traer estudiante - inscripcion */
select 
	s.name as student,
    e.student_id
from students    s
join enrollments e on e.student_id = s.id
order by s.id;

select 
	c.name as course,
    e.course_id
from courses      c
join enrollments e on e.course_id = c.id
order by c.id;

/* 2. Usamos JOIN para traer estudiante - inscripcion - curso */
select 
	s.name as student,
    c.code,
    c.name
from students    s
join enrollments e on e.student_id = s.id
join courses     c on e.course_id  = c.id
order by c.code, s.name;

/* 3. Usamos JOIN para traer estudiante - inscripcion - curso - calificacion */
select 
	s.name as student,
    e.grade,
    e.status
from students    s
join enrollments e on e.student_id = s.id
join courses     c on e.course_id  = c.id
where c.code = 'MATH101' and e.grade is not null
order by e.grade desc;
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
/*** FASE 3 - LEFT JOIN ***/
/*
┌──────────────────┐                    ┌────────────────┐
│     COURSES      │        N:1         │   PROFESSORS   │
├──────────────────┤                    ├────────────────┤
│ 🔑 id            │                    │ 🔑 id          │
│ 🔗 professor_id ─┼───────────────────>│    name        │
│    code          │                    │    salary      │
└──────────────────┘                    └────────────────┘
        │
        └── ⚠️ COMP401 tiene professor_id = NULL → su flecha NO existe.
            INNER JOIN lo descarta en silencio; LEFT JOIN lo conserva
            (con NULL del lado derecho). Lo mismo pasa con Irene y Lucas
            en students ←── enrollments: sin flecha entrante, solo un
            LEFT los mantiene en el reporte.
*/

/** QUERY 4 - TODOS LOS CURSOS **/
-- on c.department_id = d.id
-- on c.professor_id  = p.id
/* Validamos la lista de cursos */
-- Existe un curso sin asignación de profesor y la vamos a mostrar en los resultados (TODOS)
select *
from courses;

/* Validamos la lista de profesores */
select *
from professors;

/* Validamos la lista de departamentos */
select *
from departments;

/* Usamos LEFT JOIN para traer todos los cursos con su profesor y departamento */
/* 1. Usamos LEFT JOIN para traer curso - profesor */
-- Usamos coalesce para traducir - null
select 
	c.code as code_course,
    c.name as course,
    coalesce(p.name, '(unassigned)') as professor
from courses    c
left join professors p on c.professor_id = p.id
order by c.code;

/* 2. Usamos LEFT JOIN para traer curso - profesor - departamento */
select 
	c.code as code_course,
    c.name as course,
    p.name as professor,
    d.name as department
from courses     c
left join professors  p on c.professor_id  = p.id
join departments d on c.department_id = d.id
order by d.name, p.name, c.name;

/** QUERY 5 - TODOS LOS ESTUDIANTES CON SUS CURSOS **/
-- on c.department_id = d.id
-- on c.professor_id  = p.id
/* Validamos la lista de estudiantes */
select *
from students;

/* Validamos la lista de cursos */
-- Existe un curso sin asignación de profesor y la vamos a mostrar en los resultados (TODOS)
select *
from courses;

-- No existe relacion directa entre estudiantes - cursos
-- Usamos inscripciones para unir estudiantes y cursos
/* Validamos la lista de inscripciones */
select *
from enrollments;

/* Usamos LEFT JOIN para traer todos los estudiante con su numero de cursos */
/* 1. Usamos tabla enrollments para traer todos los estudiantes y asociar los cursos */
select
	s.name,
    e.course_id
from students         s
left join enrollments e on e.student_id = s.id
order by e.course_id;

/* 2. Usamos students - enrollments para traer los cursos de la tabla course */
select
	s.name as student,
    c.code,
    c.name as course
from students    s
left join enrollments e on e.student_id = s.id
left join courses     c on e.course_id  = c.id
order by c.code;

/* 3. Calculamos la cantidad de cursos por estudiante */
select
	s.name as student,
    count(e.course_id) as num_course
from students    s
left join enrollments e on e.student_id = s.id
group by s.name
order by num_course desc, s.name;

/** DEMO - ROMPE LEFT JOIN **/
/** Paso 1 - Version A. Usamos on - and **/
-- Filtro despues de ON conserva todos los datos
select s.name, e.course_id, e.status
from students        s
left join enrollments e on e.student_id = s.id and e.status = 'passed'
order by s.name, e.course_id;

/** Paso 2 - Version B. Usamos on - where **/
-- WHERE se evalua despues del JOIN → LEFT JOIN se comporta como INNER JOIN
select s.name, e.course_id, e.status
from students        s
left join enrollments e on e.student_id = s.id 
where e.status = 'passed'
order by s.name, e.course_id;

/** QUERY 6 - PROFESORES SIN CURSOS ASIGNADOS **/
-- on c.department_id = d.id
-- on c.professor_id  = p.id

/* Validamos la lista de profesores */
select *
from professors;

/* Validamos la lista de cursos */
-- Existe un curso sin asignación de profesor
select *
from courses;

/* Usamos JOIN para traer cursos sin profesores asignados */
/* 1. Usamos LEFT JOIN para traer curso - profesor */
select 
	p.name as professor,
    c.code,
    c.name as course
from courses         c
left join professors p on c.professor_id = p.id
where p.name is null 
order by p.name, c.code;

/* 2. Usamos LEFT JOIN para traer profesor sin cursos asignados */
select 
	p.name as professor,
    c.code,
    c.name as course
from professors   p
left join courses c on c.professor_id = p.id
where c.id is null
order by p.name, c.code;
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
/*** FASE 4 - ENCADENAR TABLAS ***/
/*
┌──────────┐      ┌─────────────┐      ┌─────────┐      ┌─────────────┐
│ STUDENTS │<─────│ ENROLLMENTS │─────>│ COURSES │─────>│ DEPARTMENTS │
└──────────┘      └─────────────┘      └─────────┘      └─────────────┘
    🔑 id  =  🔗 student_id · 🔗 course_id  =  🔑 id │ 🔗 department_id = 🔑 id
                    ▲ el HUB (la N:M)               │
                                                    │ 🔗 professor_id = 🔑 id
                                                    v
                                             ┌────────────┐
                                             │ PROFESSORS │
                                             └────────────┘
*/

/** QUERY 7 - POR DEPARTAMENTO: CUANTOS PROFESORES Y CURSOS **/
-- Tamaño de cada departamento: profesores y cursos". "Cada departamento" 
-- on p.department_id = d.id
-- on c.department_id = d.id
-- on c.professor_id  = p.id

/* Validamos la lista de departamentos */
select *
from departments;

/* Validamos la lista de profesores */
select *
from professors;

/* Validamos la lista de cursos */
-- Existe un curso sin asignación de profesor
select *
from courses;

/* Usamos LEFT JOIN para por departamento los profesores y cursos */
/* 1. Usamos JOIN para traer profesores por departamento */
-- Sabemos que cada profesor tiene asignado un departamento
select
	d.name as department,
    p.name as professor
from departments d
join professors  p on p.department_id = d.id 
order by d.id desc, p.name;

/* 2. Usamos LEFT JOIN para traer los cursos con su profesor por departamento */
-- Existen un cursos sin asignación de profesor
select
	d.name as department,
    p.name as professor,
    c.code,
    c.name as course
from departments  d
join professors   p on p.department_id = d.id
left join courses c on c.department_id = d.id
order by d.name;

/* 3. Agruamos y contamos número de profesores y número de cursos */
-- Usamos COUNT(DISTINCT ...) para contar valores unicos
-- Usamos GROUP BY para agrupar por departamento
select
	d.name as department,
    count(distinct p.id) as num_professors,
    count(distinct c.id) as num_courses
from departments  d
join professors   p on p.department_id = d.id
left join courses c on c.department_id = d.id
group by d.id
order by d.name;

/** QUERY 8 - CURSOS DE C/ESTUDIANTE - (estudiante, código, curso, nota) **/
-- "solo estudiantes con al menos una inscripción"
-- on e.student_id = s.id
-- on e.courses_id = c.id

/* Validamos la lista de departamentos */
select *
from students;

/* Validamos la lista de cursos */
-- Existe un curso sin asignación de profesor
select *
from courses;

-- No existe relacion directa entre estudiantes - cursos
-- Usamos inscripciones para unir estudiantes y cursos
/* Validamos la lista de inscripciones */
select *
from enrollments;

/* Usamos JOIN para traer los estudiante con cursos */
/* 1. Usamos tabla enrollments para traer los estudiantes con inscripción a cursos */
select
	s.name,
    e.course_id
from students    s
join enrollments e on e.student_id = s.id
order by e.course_id;

/* 2. Usamos students - enrollments para traer los cursos de la tabla course */
select
	s.name as student,
    c.code,
    c.name as course,
    e.grade,
    e.status
from students    s
join enrollments e on e.student_id = s.id
join courses     c on e.course_id  = c.id
order by c.code, e.grade desc;

/** QUERY 9 - ESTUDIANTES EN "Computer Science" CON CURSO y PROFESOR **/
-- on e.student_id    = s.id
-- on e.course_id     = c.id
-- on c.professor_id  = p.id
-- on c.department_id = d.id
-- on p.department_id = d.id

/* Validamos la lista de estudiantes */
select *
from students;

/* Validamos la lista de cursos */
select *
from courses;

/* Validamos la lista de cursos */
select *
from professors;

-- No existe relacion directa entre estudiantes - cursos
-- Usamos inscripciones para unir estudiantes y cursos
/* Validamos la lista de inscripciones */
select *
from enrollments;

/* Usamos JOIN para traer estudiante - inscripcion - curso - profesor */
/* 1. Usamos JOIN para traer estudiante - inscripcion */
select 
	s.name as student,
    e.student_id
from students    s
join enrollments e on e.student_id = s.id
order by s.id;

select 
	c.name as course,
    e.course_id
from courses      c
join enrollments e on e.course_id = c.id
order by c.id;

/* 2. Usamos JOIN para traer estudiante - inscripcion - curso */
select 
	s.name as student,
    c.code,
    c.name as course
from students    s
join enrollments e on e.student_id = s.id
join courses     c on e.course_id  = c.id
order by c.code, s.name;

/* 3. Usamos JOIN para traer estudiante - inscripcion - curso - profesor */
select 
	s.name as student,
    c.code,
    c.name as course,
    p.name as professor
from students    s
join enrollments e on e.student_id   = s.id
join courses     c on e.course_id    = c.id
join professors  p on c.professor_id = p.id
order by c.code;

/* 4. Usamos JOIN para traer estudiante - inscripcion - curso - profesor - departamento */
-- on c.department_id = d.id
-- on p.department_id = d.id
select 
	s.name as student,
    c.code,
    c.name as course,
    p.name as professor,
    d.name as department
from students    s
join enrollments e on e.student_id   = s.id
join courses     c on e.course_id    = c.id
join professors  p on c.professor_id = p.id
join departments d on p.department_id = d.id
-- where c.code = 'MATH101' and e.grade is not null
order by c.code;

/* 5. Usamos WHERE para filtrar por departamento - "Computer Science" */
select 
	s.name as student,
    c.code,
    c.name as course,
    p.name as professor,
    d.name as department
from students    s
join enrollments e on e.student_id   = s.id
join courses     c on e.course_id    = c.id
join professors  p on c.professor_id = p.id
join departments d on p.department_id = d.id
where d.name = 'Computer Science'
order by c.code;

/* Contamos número de estudiantes en "Computer Science" por curso */
select
	c.name as course,
    p.name as professor,
    d.name as department,
    count(s.name) as num_students
from students    s
join enrollments e on e.student_id   = s.id
join courses     c on e.course_id    = c.id
join professors  p on c.professor_id = p.id
join departments d on p.department_id = d.id
where d.name = 'Computer Science'
group by c.code;
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
/*** FASE 5 - SELF JOIN ***/
/*
   En el ERD (una caja):              Al escribir el JOIN (dos alias):

┌────────────────────┐        alias p (empleado)      alias m (jefe)
│     PROFESSORS     │      ┌──────────────────┐    ┌──────────────────┐
├────────────────────┤      │    PROFESSORS    │    │    PROFESSORS    │
│ 🔑 id        <──┐  │  ==> ├──────────────────┤    ├──────────────────┤
│ 🔗 manager_id ──┘  │      │ 🔑 id            │    │ 🔑 id            │<─┐
│    salary          │      │ 🔗 manager_id ───┼────┼──────────────────┼──┘
└────────────────────┘      │    salary        │1:N │    salary        │
       SELF FK              └──────────────────┘    └──────────────────┘

                              ON p.manager_id = m.id
*/
-- SELF JOIN une una tabla con ella misma, usando dos alias distintos como si fueran dos tablas.

/** QUERY 10 - CADA PROFESOR CON EL NOMBRE DE SU JEFE **/
-- "el organigrama: cada profesor y su jefe, con nombres" 
-- on p.manager_id = p2.id

/* Validamos la lista de profesores */
select *
from professors;

/* Usamos INNER/LEFT JOIN para tener professors - manager */
/* 1. Usamos JOIN para traer profesores con jefe */
select
    p.name  as professor,
    p2.name as manager
from professors p
join professors p2 on p.manager_id = p2.id
order by p.name;

/* 2. Usamos LEFT JOIN para traer profesores con/sin jefe */
-- Usamos COALESCE para convertir NULL en 'No manager'
select
    p.name  as professor,
    coalesce(p2.name, 'NO MANAGER')as manager
from professors      p
left join professors p2 on p.manager_id = p2.id
order by p.name;

/** QUERY 11 - PROFESORES QUE GANAN MAS QUE SU JEFE **/
-- on p.manager_id = p2.id

/* Validamos la lista de profesores */
select *
from professors;

/* Usamos JOIN para tener professors - manager - salary */
/* 1. Usamos JOIN para traer profesores con jefe y salario */
select
    p.name  as professor,
    p.salary,
    p2.name as manager,
    p2.salary
from professors p
join professors p2 on p.manager_id = p2.id
order by p.name;

/* 2. Usamos LEFT JOIN para traer profesores con/sin jefe */
-- Usamos WHERE para comparar salarios p.salary > p2.salary
-- No existe jefe con menor salario que un profesor
select
    p.name  as professor,
    p.salary,
    p2.name as manager,
    p2.salary
from professors p
join professors p2 on p.manager_id = p2.id
where p.salary > p2.salary
order by p.name;

/** QUERY 12 - PARES DE PROFESORES DEL MISMO DEPARTAMENTO **/
-- "ponme junto a cada profesor todos los de su mismo depto"
-- on p.manager_id    = p2.id
-- on p.department_id = p2.department_id

/* Validamos la lista de profesores */
select *
from professors;

/* Usamos JOIN para tener professors - department - profesors */
/* 1. Usamos JOIN para traer profesores con su par */
select
    p.name  as professor,
    p2.name as professor2
from professors  p
join professors p2 on p.department_id = p2.department_id;

/* 2. Usamos JOIN para traer profesores con departamento */
-- Usamos la desigualdad para tener una sola versión de cada par - p1.id < p2.id 
select
    p.name  as professor,
    p2.name as professor2,
    d.name  as department
from professors  p
join professors p2 on p.department_id = p2.department_id and p.name < p2.name
join departments d on p.department_id = d.id
order by p.name, p2.name;

/** DEMO - CROSS JOIN: el cartesiano a propósito **/
-- un producto cartesiano empareja cada fila de A con cada fila de B.
-- CROSS JOIN es el único que no lleva ON: no hay condición que cumplir.

select s.name as student, c.code
from students s
cross join courses c
order by s.name, c.code;

/** Paso 2 - Version B. Usamos on - where **/
-- WHERE se evalua despues del JOIN → LEFT JOIN se comporta como INNER JOIN
select s.name, e.course_id, e.status
from students        s
left join enrollments e on e.student_id = s.id 
where e.status = 'passed'
order by s.name, e.course_id;
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
/*** FASE 6 - QUERIES DE NEGOCIO ***/
/*
                    ┌─────────────┐
                    │ DEPARTMENTS │  ← FROM: una fila por depto, pase lo que pase
                    └─────────────┘
                     /           \
             LEFT   /             \   LEFT
                   v               v
        ┌────────────┐          ┌─────────┐          ┌─────────────┐
        │ PROFESSORS │          │ COURSES │─── LEFT ─>│ ENROLLMENTS │
        └────────────┘          └─────────┘          └─────────────┘
         (rama corta)            (rama larga: sigue hasta el hub)

  Dos ramas × varias filas cada una = filas repetidas → COUNT(DISTINCT ...)
*/
-- → JOIN correcto 
-- → GROUP BY la entidad del reporte 
-- → COUNT/SUM sin inflar 
-- → ORDER BY lo que importa 
-- → LIMIT si piden un top.

/** QUERY 13 - TOP 3 CURSOS CON MÁS ESTUDIANTES INSCRITOS **/
-- "cursos con más inscritos"
-- "inscritos" de verdad → excluye los withdrawn

/* Validamos la lista de profesores */
select *
from courses;

/* Validamos la lista de profesores */
select *
from students;

-- No existe relacion directa entre estudiantes - cursos
-- Usamos inscripciones para unir estudiantes y cursos
/* Validamos la lista de inscripciones */
select *
from enrollments;

/* Usamos JOIN para traer los cursos con estudiantes inscritos */
/* 1. Usamos tabla enrollments para traer los cursos con student_id */
select c.code, c.name as course, e.student_id
from courses     c
join enrollments e on e.course_id = c.id
order by e.course_id;

/* 2. Usamos courses - enrollments para traer los estudiantes inscritos */
select c.code, c.name as course, s.name as student
from courses     c
join enrollments e on e.course_id  = c.id
join students    s on e.student_id = s.id
order by e.course_id, s.name;
-- 27 row(s) returned

/* 4. Usamos courses - enrollments para traer los estudiantes inscritos. Excluyendo los withdrawn */
select c.code, c.name as course, s.name as student
from courses     c
join enrollments e on e.course_id  = c.id
join students    s on e.student_id = s.id
where e.status <> 'withdrawn'
order by e.course_id, s.name;
-- 27 row(s) returned

/* 4. Contamos número de estudiantes por curso */
select 
	c.code,
    c.name as course, 
    count(s.name) as num_students
from courses     c
join enrollments e on e.course_id  = c.id
join students    s on e.student_id = s.id
group by c.code
order by num_students desc
limit 3;
