-- ======================================
-- ENTREGABLE SEMANA 4 
-- FASE 3 -  LEFT JOIN
-- UNIVERSIDAD TECHMASTER - TECHMASTER
-- Nombre: [PAUL SEBASTIAN MELO]
-- Fecha: [27-08-2026]
-- =====================================

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

use techmaster_university;

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
