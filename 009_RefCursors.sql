SET SERVEROUTPUT ON

/*
    Uso de REF CURSORS o Cursores Variables
    
    SCHEMA usado: HR
*/

/*
Ejemplo 1: Uso de un ref cursor definiendo el tipo de dato que tiene que manejar con la
setencia RETURN en la declaracion del REF_CURSOR

*/
DECLARE
    
    TYPE CURSOR_VARIABLE IS REF CURSOR RETURN DEPARTMENTS%ROWTYPE;
    V1 CURSOR_VARIABLE ;
    
    DEPARTAMENTOS DEPARTMENTS%ROWTYPE;
BEGIN
OPEN V1 FOR SELECT * FROM DEPARTMENTS WHERE DEPARTMENT_ID > 150;
    FETCH V1 INTO DEPARTAMENTOS;
    WHILE V1%FOUND LOOP
        DBMS_OUTPUT.PUT_LINE(DEPARTAMENTOS.DEPARTMENT_NAME);
        FETCH V1 INTO DEPARTAMENTOS;
    END LOOP;
    CLOSE V1;
END;
/


/*
Ejemplo 2: Uso de un ref cursor como parametro en un funcion, la unica condicion que se tiene es que
el ref cursor debe ser un parametro de tipo in out.

*/
CREATE OR REPLACE PACKAGE PAQ1
AS
  TYPE C_VARIABLE IS REF CURSOR;
  FUNCTION DEVOLVER_DATOS(C1 IN OUT C_VARIABLE ,X NUMBER) RETURN VARCHAR2;
END;
/

CREATE OR REPLACE PACKAGE BODY PAQ1 AS
   FUNCTION DEVOLVER_DATOS(C1 IN OUT C_VARIABLE ,X NUMBER) RETURN VARCHAR2
   IS     
        DEPARTAMENTOS DEPARTMENTS%ROWTYPE;
        EMPLEADOS EMPLOYEES%ROWTYPE;
   BEGIN
        IF X=1 THEN
            OPEN C1 FOR SELECT *  FROM EMPLOYEES;
            FETCH C1 INTO EMPLEADOS;
            RETURN EMPLEADOS.FIRST_NAME; 
            
        ELSE
            OPEN C1 FOR SELECT *  FROM DEPARTMENTS;
            FETCH C1 INTO DEPARTAMENTOS;
            RETURN DEPARTAMENTOS.DEPARTMENT_NAME; 
        END IF;
    END;
END;
/

--Prueba del paquete
set serveroutput on;
DECLARE
  DATOS PAQ1.C_VARIABLE;
BEGIN
    DBMS_OUTPUT.PUT_LINE(PAQ1.DEVOLVER_DATOS(DATOS,1));
END;
/


/*
Ejemplo 3:Como se pueden "compartir" ref cursors entre si apuntando al mismo espacio de memoria.

*/


DECLARE
    TYPE CURSOR_VARIABLE IS REF CURSOR RETURN EMPLOYEES%ROWTYPE;
    V1 CURSOR_VARIABLE;
    V2 CURSOR_VARIABLE;
   
    EMPLEADOS EMPLOYEES%ROWTYPE;
    
BEGIN
    --ABRIMOS EL CURSOR CON LA PRIMERA VARIABLE
    OPEN V1 FOR SELECT * FROM EMPLOYEES ORDER BY FIRST_NAME;
    FETCH V1 INTO EMPLEADOS;
    DBMS_OUTPUT.PUT_LINE(EMPLEADOS.FIRST_NAME||' '||EMPLEADOS.SALARY);
    
    --ASIGNAMOS V1 A V2
    V2:=V1;
    --No apunta al priemr valor que apuntaba v1 apunta al 2.
    FETCH V2 INTO EMPLEADOS;
    DBMS_OUTPUT.PUT_LINE(EMPLEADOS.FIRST_NAME||' '||EMPLEADOS.SALARY);
    
    FETCH V1 INTO EMPLEADOS;
    DBMS_OUTPUT.PUT_LINE(EMPLEADOS.FIRST_NAME||' '||EMPLEADOS.SALARY);
    
    FETCH V2 INTO EMPLEADOS;
    DBMS_OUTPUT.PUT_LINE(EMPLEADOS.FIRST_NAME||' '||EMPLEADOS.SALARY);
   
    CLOSE V1;
END;
/

/*
Ejemplo 4: Se crea un REF CURSOR para que visualice el primer nombre de región de la
tabla REGIONS y la primera ciudad de la tabla LOCATIONS.

*/
DECLARE
    TYPE cursorVariable IS REF CURSOR;
    
    ref_cur1 cursorVariable;
    
    nom_region regions%ROWTYPE;
    ciudad locations%ROWTYPE;
BEGIN
    open ref_cur1 for SELECT * FROM LOCATIONS;
    fetch ref_cur1 into ciudad;
    dbms_output.put_line(ciudad.city);
    close ref_cur1;
    
    open ref_cur1 for SELECT * FROM REGIONS;
    fetch ref_cur1 into nom_region;
    dbms_output.put_line(nom_region.region_name);
    close ref_cur1;

END;
/

/*
Ejemplo 5: Se Crea un procedimiento que tiene un parámetro de tipo numérico. Si es un visualiza 
todos los nombres de regiones. Si es un 2 visualiza todas las ciudades. 

*/
create or replace  PROCEDURE Procedimiento_RefCursor(eleccion number)
IS
    TYPE cursorVariable IS REF CURSOR;

    ref_cur1 cursorVariable;

    dato varchar2(50);
BEGIN
    IF eleccion= 1 THEN
        open ref_cur1 for SELECT REGION_NAME FROM REGIONS ;
    ELSIF eleccion = 2 THEN
        open ref_cur1 for SELECT city FROM LOCATIONS;
    END IF;

    fetch ref_cur1 into dato;

    WHILE ref_cur1%found LOOP
        DBMS_OUTPUT.PUT_LINE(dato);
        fetch ref_cur1 into dato;

    END LOOP;


END Procedimiento_RefCursor;
/

--Prueba 
EXECUTE Procedimiento_RefCursor(2);


/*
Ejemplo 6: Se Crea una función que recibe como argumento un salario y
que devuelve un REF CURSOR de tipo EMPLOYEES con los empleados que
ganen más de esa salario

*/
CREATE OR REPLACE FUNCTION funcion_returnrefc (salario NUMBER) 
RETURN SYS_REFCURSOR 
IS
    --Se le coloca el tipo de dato que puede manejar para que no haya un error en la integridad de los datos 
    --y solo se retorne datos de empleados.
    
    TYPE refc_empleado IS REF CURSOR RETURN employees%rowtype;
    empleados refc_empleado;
BEGIN
    OPEN empleados FOR SELECT
                           *
                       FROM
                           employees
                       WHERE
                           salary > salario;

    RETURN empleados;
END funcion_returnrefc;
/

--Aca se podria ocupar dicha funcion para saber los que ganan mas de 2000

DECLARE
    refc_empleados  SYS_REFCURSOR;
    salario    NUMBER;
    empleado   employees%rowtype;
BEGIN
    salario := 2000;
    refc_empleados := funcion_returnrefc(salario);
    LOOP
        FETCH refc_empleados INTO empleado;
        dbms_output.put_line(empleado.first_name
                             || '
'
                             || empleado.salary);
        EXIT WHEN refc_empleados%notfound;
    END LOOP;

END;
/

/*
Ejemplo 7: 
Se Crea un paquete que Declara una variable de tipo REF_CURSOR de tipo EMPLOYEES.
Crea también una función dentro del paquete que tiene como
argumento el REF_CURSOR creado anteriormente y que devuelve la
media de los salarios.

*/

CREATE OR REPLACE PACKAGE pqt_refcur IS
    TYPE refc_empleados IS REF CURSOR RETURN employees%rowtype;
    FUNCTION mediasalarios (emple refc_empleados) RETURN NUMBER;

END;
/

CREATE OR REPLACE PACKAGE BODY pqt_refcur 
IS

FUNCTION mediasalarios (emple refc_empleados) RETURN NUMBER
IS            
    salarios number := 0;
    media         NUMBER := 0;
    numempleados  NUMBER := 0;
    empleados     employees%rowtype;

BEGIN

    FETCH emple INTO empleados;
    WHILE emple%found LOOP
        salarios := salarios + empleados.salary;
        numempleados := numempleados + 1;
    END LOOP;

    media := salarios / numempleados;
    RETURN media;
    
END mediasalarios;

END;
/

--
