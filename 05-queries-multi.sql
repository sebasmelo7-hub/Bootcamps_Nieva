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

use techmaster_university;

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
