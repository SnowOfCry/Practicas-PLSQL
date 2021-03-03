/*
    Uso de Basico de Procedimientos con o sin parametros
    
    SCHEMA usado: HR
*/


/*
    Ejemplo 1: procedimiento simple para mostrar todos los empleados
*/
CREATE OR REPLACE PROCEDURE visualizar IS
    CURSOR empleados IS
    SELECT
        first_name,
        salary
    FROM
        employees;

BEGIN
    FOR i IN empleados LOOP
        dbms_output.put_line(i.first_name
                             || ' Salario: '
                             || i.salary);
    END LOOP;
END visualizar;
/

SET SERVEROUTPUT ON

EXECUTE visualizar;
/

/*
    Ejemplo 2: Ahora el procedimiento con parametros, pasandole el numero de departamento
    que vamos a buscar,se deja en modo in porque no necesitamos modificarlo y se crea una variable out para guardar el numero de empleados
*/

CREATE OR REPLACE PROCEDURE visualizarparametros (
    idde              IN    NUMBER,
    numeroempleados   OUT   NUMBER
) IS
    CURSOR empleadospordepa IS
    SELECT
        first_name,
        salary
    FROM
        employees
    WHERE
        department_id = idde;

BEGIN
    FOR i IN empleadospordepa LOOP
        dbms_output.put_line('Los empleados del departamento '
                             || idde
                             || ' Son:');
        dbms_output.put_line(i.first_name
                             || ' Salario: '
                             || i.salary);
    END LOOP;

    SELECT
        COUNT(*)
    INTO numeroempleados
    FROM
        employees
    WHERE
        department_id = idde;

EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Error, el id del departamento no es valido o no existe');
END visualizarparametros;
/

DECLARE
    numempleados NUMBER := 0;
BEGIN
    visualizarparametros(80, numempleados);
    dbms_output.put_line(numempleados);
END;
/