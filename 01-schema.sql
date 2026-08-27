-- ======================================
-- ENTREGABLE SEMANA 4 
-- FASE 1 -  CREATE TABLES
-- UNIVERSIDAD TECHMASTER - TECHMASTER
-- Nombre: [PAUL SEBASTIAN MELO]
-- Fecha: [28-08-2026]
-- =====================================

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
    
    constraint fk_enrollment_students
		foreign key (student_id) references students(id)
        on delete cascade,
	constraint fk_enrollment_courses
		foreign key (course_id) references courses(id)
        on delete cascade,
        
    constraint chk_grade 
		check (grade >= 0 and grade <= 10)
);
