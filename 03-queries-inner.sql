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

use techmaster_university;

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
