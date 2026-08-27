-- ======================================
-- ENTREGABLE SEMANA 4
-- FASE 0 - EDR dbdiagram.io
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
  department_id  int     [ref: > departments.id]  // professors → departments (N:1)
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
