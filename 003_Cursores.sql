SET SERVEROUTPUT ON

/*
    Uso de Cursores y cursores con parametros
    
    SCHEMA usado: HR
*/


/*
    1-Se tiene un cursor que  visualiza los salarios de los empleados. 
    Si en el cursor aparece el jefe (Steven King) se  genera un RAISE_APPLICATION_ERROR 
    indicando que el sueldo del jefe no se puede ver.


*/

DECLARE
    CURSOR empleados IS
    SELECT
        *
    FROM
        employees;

BEGIN
    FOR i IN empleados LOOP
        IF i.first_name || i.last_name = 'StevenKing' THEN
            raise_application_error(-20000, 'El sueldo del jefe no puede verse.');
        ELSE
            dbms_output.put_line('El sueldo del empleado es: ' || i.salary);
        END IF;
    END LOOP;
END;
/

/*
2-Se crean dos cursores
(Esto se puede hacer fácilmente con una sola SELECT 
pero se hace de esta manera para probar parámetros en cursores)

-el primero de empleados
-El segundo de departamentos que tiene como parámetro el MANAGER_ID
-Por cada fila del primero, se abre el segundo curso pasando el ID del MANAGER
-Se pinta el Nombre del departamento y el nombre del MANAGER_ID
-Si el empleado no es MANAGER de ningún departamento se poner “No es jefe de nada”

*/

DECLARE
    
    CURSOR empleados IS
    SELECT
        *
    FROM
        employees;

    CURSOR departs (
        m_id NUMBER
    ) IS
    SELECT
        *
    FROM
        departments
    WHERE
        manager_id = m_id;

    --Se puede declarar un record del tipo de cursor que acabamos de crear
    depart empleados%rowtype;

BEGIN
    FOR i IN empleados LOOP
        OPEN departs(i.employee_id);
        FETCH departs INTO depart;
        IF departs%notfound THEN
            dbms_output.put_line('No es jefe de nadie');
        ELSE
            dbms_output.put_line(depart.department_name || i.first_name);
        END IF;

        CLOSE departs;
    END LOOP;

    /* Cuando se tiene un cursor que no devuelve nada y se corre en el for, nunca entra, por ende solo hara los que no den error
    para estos casos, solo de ser sumamente necesario ocupar un cursor for loop, tener una variable que te diga si entro en el for
	Este tipo de errores da mas en cursores con parametros.

    FOR j in departs(1000) LOOP
            if departs%rowcount =0 then
             dbms_output.put_line('No es manager');
             Else
            dbms_output.put_line('Number of rows processed: '||nvl(to_char(sql%rowcount),'Null'));

            end if;
    END loop;
    */
END;
/

/* 
   3- Se cre un cursor con parámetros,pasando el número de departamento 
   visualizando el número de empleados de ese departamento


*/

DECLARE
    CURSOR depa (
        num_dep NUMBER
    ) IS
    SELECT
        COUNT(*)
    FROM
        employees
    WHERE
        department_id = num_dep;

    numero_depart NUMBER;
BEGIN
    OPEN depa(1000);
    FETCH depa INTO numero_depart;
    IF depa%notfound THEN
        dbms_output.put_line('No existe departamento con ese id');
    ELSE
        dbms_output.put_line('Se tienen: '
                             || numero_depart
                             || ' de empleados');
    END IF;

    CLOSE depa;
END;
/

/* 
   4- Se crea un bucle FOR donde se declara una subconsulta que
   devuelve el nombre de los empleados que sean ST_CLERK. 
*/

DECLARE BEGIN
    FOR i IN (
        SELECT
            first_name
            || ' '
            || last_name AS nombref
        FROM
            employees
        WHERE
            job_id = 'ST_CLERK'
    ) LOOP
        dbms_output.put_line(i.nombref);
    END LOOP;
END;
/

/*
5-Creamos un bloque que tenga un cursor para empleados en el cual se va a actualizar.

Por cada fila recuperada, si el salario es mayor de 8000 se incrementa el salario un 2%
Si es menor de 800 lo hacem en un 3%


*/

DECLARE
    filas number:=0;
    CURSOR empleados IS
    SELECT
        *
    FROM
        employees
    FOR UPDATE;

BEGIN 
    FOR i IN empleados LOOP 
        IF i.salary>8000 THEN
            UPDATE employees SET salary= salary*1.02 WHERE CURRENT OF empleados;
            filas:= filas + (sql%rowcount);
        ELSE
            UPDATE employees SET salary= salary+salary*1.03 WHERE CURRENT OF empleados;
            filas:=filas +(sql%rowcount);
        END IF;
        
    END loop;
        DBMS_OUTPUT.PUT_LINE(filas);
        commit; -- SI SE OCUPA EL FOR UPDATE, LOS COMMITS VAN FUERA DEL FOR
END;
/