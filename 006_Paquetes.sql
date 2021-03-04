/*
    Uso de paquetes.
    
    Schema usado: hr
    
*/


/*
    Ejemplo 1: Se crea el paquete llamado REGIONES para hacer El insert,delete and update de una region, el paquete tiene
    lo siguiente:
    
    PROCEDIMIENTOS:
         -  ALTA_REGION, con par�metro de c�digo y nombre Regi�n. Devuelve un error si la regi�n ya existe. 
            Inserta una nueva regi�n en la tabla. llama a la funci�n EXISTE_REGION para controlarlo.

         - BAJA_REGION, con par�metro de c�digo de regi�n y borra la regi�n con ese codigo
           genera un error si la regi�n no existe, Llama a la funci�n EXISTE_REGION para controlarlo

        -  MOD_REGION: se le pasa un c�digo y el nuevo nombre de la regi�n
           Modifica el nombre de una regi�n ya existente. Genera un error si la regi�n no existe, llama a la funci�n EXISTE_REGION para controlarlo.

    FUNCIONES
          -Privada EXISTE_REGION. Devuelve verdadero si la regi�n existe. 

*/
CREATE OR REPLACE PACKAGE regiones IS
    PROCEDURE alta_region (
        cod      NUMBER,
        nombre   VARCHAR2
    );

    PROCEDURE baja_region (
        cod NUMBER
    );

    PROCEDURE mod_region (
        cod         NUMBER,
        newnombre   VARCHAR2
    );

END regiones;
/

--Body

CREATE OR REPLACE PACKAGE BODY regiones 
IS
--Proc y funciones privadas
FUNCTION existe_region (cod NUMBER) RETURN BOOLEAN
IS       
    existe boolean;
    nombre   VARCHAR2(100);
BEGIN
    SELECT
        region_name
    INTO nombre
    FROM
        regions
    WHERE
        region_id = cod;
   
    existe := true;
    
    RETURN existe;
    
EXCEPTION
    WHEN no_data_found THEN
        existe:= false;
        RETURN existe;
END existe_region;

--Proc, func, publicas.


PROCEDURE alta_region (cod      NUMBER,nombre   VARCHAR2) 
IS
    existe boolean;
BEGIN
    --Comprobar que exista
    existe:= existe_region (cod);
        
    IF existe = false THEN
        INSERT into regions values(cod,nombre);
        COMMIT;
    ELSE 
        RAISE_APPLICATION_ERROR(-20002,'No se puede insertar, ya existe el registro');
    END IF;

    EXCEPTION
        WHEN no_data_found THEN
            raise_application_error(-20001, 'Error, no existe el registro');
END alta_region;
    
PROCEDURE baja_region (cod NUMBER)
IS
    existe boolean;
BEGIN
    --Comprobar que exista
    existe:= existe_region (cod);
        
    IF existe=true THEN
        DELETE FROM REGIONS WHERE region_id=cod;
        Commit;
    ELSE
        RAISE_APPLICATION_ERROR(-20004, 'No se puede eliminar, no existe el registro');
    END IF;
    
END baja_region;
    
PROCEDURE mod_region (cod         NUMBER,newnombre   VARCHAR2)
IS
    existe boolean;
BEGIN
    existe:= existe_region (cod);
        
    IF existe=true THEN
        UPDATE REGIONS SET region_id=cod,region_name=newnombre WHERE region_id=cod;
        Commit;
    ELSE
        RAISE_APPLICATION_ERROR(-20004, 'No se puede actualizar, no existe el registro');
    END IF;
    
END mod_region;

END regiones;
/


/*
    Ejemplo 2: Usando la sobrecarga de procedimientos
    Se crea el paquete NOMINA que tiene sobrecargada la funci�n CALCULAR_NOMINA de la siguiente forma:
    -CALCULAR_NOMINA(NUMBER): se calcula el salario del empleado restando un 15% de impuesto.
    -CALCULAR_NOMINA(NUMBER,NUMBER): el segundo par�metro es el porcentaje a aplicar. Se calcula el salario del empleado restando ese porcentaje al salario
    -CALCULAR_NOMINA(NUMBER,NUMBER,CHAR): el segundo par�metro es el porcentaje a aplicar, el tercero vale �V�. 
    Se calcula el salario del empleado aumentando la comisi�n que le pertenece que es de el 3%  y restando ese porcentaje al salario 
    siempre y cuando el empleado tenga comisi�n.
*/

CREATE OR REPLACE PACKAGE NOMINA
IS

PROCEDURE CALCULAR_NOMINA(salario number);

PROCEDURE CALCULAR_NOMINA(salario number, impuesto number);

PROCEDURE CALCULAR_NOMINA (salario number, impuesto number, comision char);

END NOMINA;
/

CREATE OR REPLACE PACKAGE BODY NOMINA
IS

    PROCEDURE CALCULAR_NOMINA(salario number)
    IS
    sal number:=0;
    BEGIN
        sal:= salario-salario*0.15;
        DBMS_OUTPUT.PUT_LINE('El Salario despues del descuento es: $'|| sal);
    END CALCULAR_NOMINA;
    
    PROCEDURE CALCULAR_NOMINA(salario number, impuesto number)
    IS
    sal number:=0;
    BEGIN
        sal:= salario-salario*impuesto;
        DBMS_OUTPUT.PUT_LINE('El Salario despues del descuento es: $'|| sal);
    
    END CALCULAR_NOMINA;
    
    PROCEDURE CALCULAR_NOMINA(salario  number, impuesto number, comision char)
    IS
    sal number:=0;
    BEGIN
        IF comision='V' THEN
            sal:= salario+(salario*0.03)-(salario*impuesto);
            DBMS_OUTPUT.PUT_LINE('El Salario despues del descuento mas la comision es: $'|| sal);
        ELSE
            sal:= salario-(salario*impuesto);
            DBMS_OUTPUT.PUT_LINE('El Salario despues del descuento sin la comision es: $'|| sal);
        END IF;
    END CALCULAR_NOMINA;

END NOMINA;