SET SERVEROUTPUT ON

/*
    Uso de Array Asociativos (INDEX BY TABLE)
    
    SCHEMA usado: HR
*/

/*
    Ejemplo 1: Se usan dos index by table para demostrar que el tipo de dato que se puede ocupar puede ser simple
    o complejo como lo es un record.
*/
DECLARE
    TYPE departamentos IS
        TABLE OF departments.department_name%TYPE INDEX BY PLS_INTEGER;
    TYPE empleados IS
        TABLE OF employees%rowtype INDEX BY PLS_INTEGER;
        
    depts    departamentos;
    emples   empleados;
BEGIN
 --Ingreso tipo simple
    depts(1) := 'Informatica';
    depts(2) := 'RRHH';
    dbms_output.put_line(depts(1));
    dbms_output.put_line(depts(2));
    dbms_output.put_line(depts.last);
    dbms_output.put_line(depts.first);
    IF depts.EXISTS(3) THEN
        dbms_output.put_line(depts(3));
    ELSE
        dbms_output.put_line('ESE VALOR NO XISTE');
    END IF;
    
--Ingreso tipo complejo

    SELECT
        *
    INTO
        emples(1)
    FROM
        employees
    WHERE
        employee_id = 100;

    dbms_output.put_line(emples(1).first_name);
END;
/

/*
    Ejemplo 2: Se usa un index by table para almacenar los primeros 10 departamentos y mostrar su nombre,
    usando como tipo de dato de la tabla un variable %rowtype.
*/
DECLARE
    TYPE departamentos IS
        TABLE OF departments%rowtype INDEX BY PLS_INTEGER;
    depts departamentos;
BEGIN
    FOR i IN 1..10 LOOP SELECT
                            *
                        INTO
                            depts
                        (i)
                        FROM
                            departments
                        WHERE
                            department_id = i * 10;

    END LOOP;

    FOR i IN 1..10 LOOP dbms_output.put_line(depts(i).department_name);
    END LOOP;

END;
/


/*

Ejemplo 3:Uso de record y tabla index by para traer los empleados del id 100 al 206

Visualizamos toda la colección
Visualizamos el primer empleado
Visualizamos el último empleado
Visualizamos el número de empleados
Borramos los empleados que ganan menos de 7000 y visualizamos de nuevo la colección
Volvemos a visualizar el número de empleados para ver cuantos se han borrado
*/

DECLARE
    TYPE empleado IS RECORD (
        name       VARCHAR2(100),
        sal        employees.salary%TYPE,
        cod_dept   employees.department_id%TYPE
    );
    TYPE listaempleado IS
        TABLE OF empleado INDEX BY PLS_INTEGER;
    lista listaempleado;
BEGIN
    FOR i IN 100..206 LOOP SELECT
                               first_name
                               || ' '
                               || last_name,
                               salary,
                               department_id
                           INTO
                               lista(i - 99).name,
                               lista(i - 99).sal,
                               lista(i - 99).cod_dept
                           FROM
                               employees
                           WHERE
                               employee_id = i;

    END LOOP;

    FOR i IN lista.first..lista.last LOOP dbms_output.put_line('Empleado: '
                                                      || lista(i).name
                                                      || ' Salario: $'
                                                      || lista(i).sal
                                                      || ' ID Departamento: '
                                                      || lista(i).cod_dept);
    END LOOP;

    dbms_output.put_line('El primero es: ' || lista.first);
    dbms_output.put_line('El ultimo es: ' || lista.last);
    dbms_output.put_line('Se tienen un total de empleados de : ' || lista.count);
    
    --Siempre hacer el recorrido asi porque no sabemos si el indice del asociative array sera 1
    FOR i IN lista.first..lista.last LOOP 
        IF lista(i).sal < 7000 THEN
            lista.DELETE(i);
        END IF;
    END LOOP;

    dbms_output.put_line('Luego de eliminar se tienen un total de empleados de : ' || lista.count);
END;