/*
    Ejemplo 1:Funcion que dado un numero de departamento,
    devuelve la suma de los salarios de dicho departamento.
*/


CREATE OR REPLACE FUNCTION totalsalariodepa (
    iddep IN employees.DEPARTMENT_ID%TYPE
) RETURN NUMBER IS
    deparId departments.DEPARTMENT_ID%type:=0;
    salariototal NUMBER := 0;
BEGIN

    --Como se ocupa una funcion de agregacion, si no encuentra nada no devuelve null, por tanto se tiene que comprobar antes si el departamento existe
    --Se puede hacer todo con un inner join pero motivos de simplicidad y que no se esta evaluando el sql vamos a usar otro cursor implicito (SELECT INTO)
    
    SELECT DEPARTMENT_ID into deparId FROM departments WHERE DEPARTMENT_ID=iddep;
    
    SELECT
        SUM(salary)
    INTO salariototal
    FROM
        employees
    WHERE
        DEPARTMENT_ID = deparId
    GROUP BY DEPARTMENT_ID;

    RETURN salariototal;
EXCEPTION    
WHEN NO_DATA_FOUND THEN
     RAISE_APPLICATION_ERROR(-20001,'ERROR, DEPARTAMENTO '||iddep|| ' NO EXISTE');
END;
/

--Prueba
SET SERVEROUTPUT ON
DECLARE
department_id number:=100;
total number:=0;
BEGIN 
 total:= totalsalariodepa(department_id);
 DBMS_OUTPUT.PUT_LINE('La suma de todos los salarios del departamento->' || department_id ||' Es: $'|| total);
END;
/

/*
    Ejemplo 2: Funcion a la cual se le pasa un nombre de region y se devuelve el codigo de region asignado
    Se debe insertar el registro de esa region, El código de la región se calcula de forma automática.
*/

CREATE OR REPLACE FUNCTION codigoRegion(nombreRegion IN regions.region_name%type)
RETURN number
IS
nombre regions.region_name%type;
codigo regions.region_id%TYPE :=0;

BEGIN
    
    --Se comprueba que la region existe, si existe se da error
    SELECT region_name into nombre from regions WHERE region_name= UPPER(nombreRegion);
    --Se activa el error porque si lo encontro no puedo guardarlo
    RAISE_APPLICATION_ERROR(-20000, 'LA REGION YA ESTA REGISTRADA');

    
EXCEPTION
    --Se ocupa la excepcion para ejecutar DML por lo que esta excepcion se ocupa para hacer lo correcto
    WHEN NO_DATA_FOUND THEN
        SELECT MAX(region_id)+1 INTO codigo FROM regions;
        INSERT INTO REGIONS VALUES(codigo,UPPER(nombreRegion));
        COMMIT;
        RETURN codigo;
    

END codigoRegion;
/

--probando
DECLARE
    N_REGION regions.region_name%type;
BEGIN
    N_REGION:=codigoRegion('NORMANDIA');
    DBMS_OUTPUT.PUT_LINE('EL NUMERO ASIGNADO ES:'||N_REGION);
END;
/

