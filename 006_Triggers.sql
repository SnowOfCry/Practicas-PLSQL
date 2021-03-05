/*
    Uso de triggers BASICOS
    
    Schema usado: HR
*/

/*
    Ejemplo1: Trigger DML, que sirve de auditoria para conocer que usuario agrego una region
*/

--Creacion de la tabla de prueba
CREATE TABLE hr.log_table (
    log_column   VARCHAR2(100),
    usuario      VARCHAR2(100)
);
/

CREATE OR REPLACE TRIGGER ins_empl AFTER
    INSERT ON regions
BEGIN
    INSERT INTO log_table VALUES (
        'Insercion en la tabla regiones',
        user
    );

END;
/

/*
    Ejemplo 2: Control de la tabla region, donde solo el usuario HR puede trabajar con la tabla
    Teniendo multiples eventos y controlando el update a nivel de columna
    
*/

CREATE OR REPLACE TRIGGER tri_region BEFORE
    INSERT OR UPDATE OF region_name OR DELETE ON regions
BEGIN
    IF user <> 'HR' THEN
        raise_application_error(-20001, 'SOLO HR PUEDE TRABAJAR EN LA TABLA REGIONS');
    END IF;
END;
/

/*
    Ejemplo 3: Trigger donde se controla el tipo de evento que se ejecuta.
    
*/

CREATE OR REPLACE TRIGGER tri_region BEFORE
    INSERT OR UPDATE OF region_name OR DELETE ON regions
BEGIN
    IF inserting THEN
        INSERT INTO log_table VALUES (
            'INSERT en tabla regions',
            user
        );

    ELSIF updating THEN
        INSERT INTO log_table VALUES (
            'UPDATE en tabla regions',
            user
        );

    ELSIF deleting THEN
        INSERT INTO log_table VALUES (
            'DELETE en tabla regions',
            user
        );

    ELSE
        dbms_output.put_line('No se realizo ninguna accion');
    END IF;
END;
/

/*
    Ejemplo 4: Uso basico de trigger compuesto
*/

--Desactivando los triggers anteriores

ALTER TRIGGER tri_region DISABLE;
/

CREATE OR REPLACE TRIGGER trigger_compues FOR
    DELETE OR INSERT OR UPDATE ON regions
COMPOUND TRIGGER
    BEFORE STATEMENT IS BEGIN
        INSERT INTO log_table VALUES (
            'BEFORE STATEMENT ',
            user
        );

    END BEFORE STATEMENT;
    AFTER STATEMENT IS BEGIN
        INSERT INTO log_table VALUES (
            'AFTER STATEMENT ',
            user
        );

    END AFTER STATEMENT;
    BEFORE EACH ROW IS BEGIN
        INSERT INTO log_table VALUES (
            'BEFORE EACH ROW',
            user
        );

    END BEFORE EACH ROW;
    AFTER EACH ROW IS BEGIN
        INSERT INTO log_table VALUES (
            'AFTER EACH ROW ',
            user
        );

    END AFTER EACH ROW;
END trigger_compues;
/

/*
    Ejemplo 5: Trigger DDL que no permite borrar una tabla
*/

CREATE OR REPLACE TRIGGER trigger1_ddl BEFORE DROP ON hr.SCHEMA BEGIN
    raise_application_error(-20000, 'NO SE PUEDE BORRAR TABLAS');
END;
/

/*
    Ejemplo 6: TIRGGER QUE NO PERMITE ELIMINAR EL REGISTRO SI EL JOB_ID
    TIENE ALGO RELACIONADO CON CLERK
*/

CREATE OR REPLACE TRIGGER eliminarempleado BEFORE
    DELETE ON employees
    FOR EACH ROW
BEGIN
    IF :old.job_id LIKE ( '%CLERK%' ) THEN
        raise_application_error(-20000, 'No se puede eliminar un empleado relacionado con un trabajo CLERK');
    END IF;
END eliminarempleado;
/

--Probando

DELETE FROM employees
WHERE
    job_id LIKE ( '%CLERK' );

/*
    Ejemplo 7: Trigger que hace autoincremental la pk de una tabla.
    
        Desde la version 12c oracle provee la sentencia IDENTITY para crear llaves primarias autoincrementales
        Pero si se trabaja en una version anterior a esa, oracle no tiene esa funcionalidad automatica, por lo que se realiza atraves de un trigger

*/

--Creando la tabla de auditoria

CREATE TABLE auditoria (
    id                NUMBER(10) NOT NULL,
    usuario           VARCHAR(50),
    fecha             DATE,
    salario_antiguo   NUMBER,
    salario_nuevo     NUMBER
);

--Asignando la pk a ID (Esto tambien se puede hacer dentro del create table)

ALTER TABLE auditoria ADD CONSTRAINT auditoria_pk PRIMARY KEY ( id );
  
--Se crea la sequencia, se obtiene el mismo resultado si solo se ocupa create sequence AUDITORIA_SEQ, aca se hace completo para saber cuales
--son los parametros para crear una secuencia

CREATE SEQUENCE auditoria_seq START WITH 1 INCREMENT BY 1 MAXVALUE 99999999 MINVALUE 1 NOCYCLE;
  

/*En este caso no se permite que se envien ids en la creacion, ya que se generaran automaticamente
La logica de como y que se permite crear registros, va a depender de la logica del negocio, ya que existen
otras formas de tratar esta situacion, como por ejemplo sin importar te envien o no un id, tu asignas el siguiente valor
de la sequencia. o solo manejas cuando no te envian id y dejas el manejo de error de oracle manejar el evento de que te manden un id que ya existe.
*/

CREATE OR REPLACE TRIGGER auth_pk BEFORE
    INSERT ON auditoria
    FOR EACH ROW
BEGIN
    IF :new.id IS NOT NULL THEN
        raise_application_error(-20001, 'EL ID NO DEBE SER ESPECIFICADO, SE GENERA AUTOMATICAMENTE');
    ELSE
        :new.id := auditoria_seq.nextval;
    END IF;
END auth_pk;
/

/*
    Ejemplo 8: trigger que cada vez que se hace un INSERT en la tabla REGIONS guarda una fila en la tabla AUDITORIA con el usuario y la fecha en 
    la que se ha hecho el INSERT

*/

CREATE OR REPLACE TRIGGER auth_regions BEFORE
    INSERT ON regions
BEGIN
    INSERT INTO auditoria (
        usuario,
        fecha
    ) VALUES (
        user,
        sysdate
    );

END auth_regions;
/

--Probando

INSERT INTO regions VALUES (
    91,
    'China'
);

COMMIT;


/*
    Ejemplo 9: Trigger, que al intentar actualizar el salario, no permite la modificación, si esta supone rebajar el salario, mostrando “no se puede bajar un salario”. 
        Si el salario es mayor, lo actualiza y deja el salario antiguo y el salario nuevo en la tabla AUDITORIA.*
*/

CREATE OR REPLACE TRIGGER empl_salary BEFORE
    UPDATE OF salary ON employees
    FOR EACH ROW
BEGIN
    IF :old.salary > :new.salary THEN
        raise_application_error(-20001, 'NO SE PUEDE BAJAR EL SALARIO DE UN EMPLEADO');
    ELSIF :old.salary < :new.salary THEN
        INSERT INTO auditoria (
            usuario,
            fecha,
            salario_antiguo,
            salario_nuevo
        ) VALUES (
            user,
            sysdate,
            :old.salary,
            :new.salary
        );

    END IF;
END;

/*
    Ejemplo 10: Trigger que al insertar un departamento comprueba que el código no esté repetido, que si el LOCATION_ID es NULL 
    le pone 3200 y si el MANAGER_ID es NULL le ponga 200

*/

CREATE OR REPLACE TRIGGER depart_inser BEFORE
    INSERT ON departments
    FOR EACH ROW
DECLARE
    name_dept departments.department_name%TYPE;
BEGIN
    SELECT
        departament_name
    INTO name_dept
    FROM
        departments
    WHERE
        department_id = :new.id;

    raise_application_error(-20000, 'THIS DEPARTMENT ALREADY EXISTS');
EXCEPTION
    WHEN no_data_found THEN
        IF :new.location_id IS NULL THEN
            :new.location_id := 3200;
        END IF;
        
        IF :new.manager_id IS NULL THEN
            :new.manager_id:=200;
        END IF;
END depart_inser;