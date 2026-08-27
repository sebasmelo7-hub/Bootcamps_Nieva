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

use techmaster_university;

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
