-- ======================================
-- ENTREGABLE SEMANA 4 
-- FASE 6 - QUERIES DE NEGOCIO
-- UNIVERSIDAD TECHMASTER - TECHMASTER
-- Nombre: [PAUL SEBASTIAN MELO]
-- Fecha: [27-08-2026]
-- =====================================

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

use techmaster_university;

/** QUERY 13 - TOP 3 CURSOS CON MÁS ESTUDIANTES INSCRITOS **/
-- "cursos con más inscritos"
-- "inscritos" de verdad → excluye los withdrawn

/* Validamos la lista de cursos */
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

/** QUERY 14 - ESTUDIANTES INCRITOS EN CURSOS DE 2 O MÁS DEPARTAMENTOS DISTINTOS **/
-- "estudiantes inscritos". "2+ departamentos"

/* Validamos la lista de cursos */
select *
from courses;

/* Validamos la lista de profesores */
select *
from students;

/* Validamos la lista de departamentos */
select *
from departments;

-- No existe relacion directa entre estudiantes - cursos
-- Usamos inscripciones para unir estudiantes y cursos
/* Validamos la lista de inscripciones */
select *
from enrollments;

/* Usamos JOIN para traer estudiantes inscritos en cursos */
/* 1. Usamos tabla enrollments para traer los estudiantes con course_id */
select s.name as student, e.course_id
from students    s
join enrollments e on e.student_id = s.id
order by s.id;

/* 2. Usamos students - enrollments para traer los cursos */
select s.name as student, c.code, c.name as course
from students    s 
join enrollments e on e.student_id = s.id
join courses     c on e.course_id  = c.id
order by s.id, c.code;

/* 3. Usamos students - enrollments - courses para traer los departamentos */
select s.name as student, c.code, c.name as course, d.name as department
from students    s 
join enrollments e on e.student_id    = s.id
join courses     c on e.course_id     = c.id
join departments d on c.department_id = d.id
order by s.id, c.code;

/* 4. Contamos departamentos unicos de cursos inscritos por c/estudiante */
-- Usamos COUNT(DISTINCT ...) para contar departamentos unicos
-- Usamos HAVING para filtrar despues del GROUP BY
select s.name as student, count(distinct c.department_id) as num_deparmets
from students    s 
join enrollments e on e.student_id    = s.id
join courses     c on e.course_id     = c.id
group by s.name
having count(distinct c.department_id) >=2
order by num_deparmets desc;

/** QUERY 15 - REPORTE EJECUTIVO POR DEPARTAMENTO **/
-- Para cada departamento: total de profesores, total de cursos, y 
-- total de estudiantes únicos inscritos en sus cursos
-- on p.department_id = d.id

/* Validamos la lista de departamentos */
select *
from departments;

/* Validamos la lista de profesores */
select *
from professors;

/* Validamos la lista de cursos */
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

/** Total de profesores - cursos - estudiantes para c/departamento **/
/* 1. Usamos JOIN para traer total de profesores por c/departamento */
-- Usamos COUNT(DISTINCT ...) para contar
select 
	d.name as department, 
    count(distinct p.name) as num_professors
from departments d
join professors  p on p.department_id = d.id
group by d.name, p.department_id
order by num_professors desc, d.name;

/* 2. Usamos JOIN para traer total de cursos por c/departamento */
-- Usamos COUNT(DISTINCT ...) para contar
select 
	d.name as department, 
    count(distinct p.name) as num_professors,
    count(distinct c.code) as num_courses
from departments d
join professors  p on p.department_id = d.id
join courses     c on c.department_id = d.id
group by d.name
order by num_professors desc, department;

/* 3. Usamos JOIN para traer total de estudiantes por c/departamento */
-- Usamos COUNT(DISTINCT ...) para contar
select 
	d.name as department, 
    count(distinct p.name) as num_professors,
    count(distinct c.code) as num_courses,
    count(distinct s.id)   as num_students
from departments      d
left join professors       p on p.department_id = d.id
left join courses          c on c.department_id = d.id
left join enrollments e on e.course_id     = c.id
left join students    s on e.student_id    = s.id
group by d.name
order by num_professors desc, num_students desc;

select 
	d.name as department, 
    count(distinct p.name)       as num_professors,
    count(distinct c.code)       as num_courses,
    count(distinct e.student_id) as num_students
from departments      d
left join professors       p on p.department_id = d.id
left join courses          c on c.department_id = d.id
left join enrollments e on e.course_id     = c.id
group by d.name
order by num_professors desc, num_students desc;
