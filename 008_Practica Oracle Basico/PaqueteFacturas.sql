CREATE OR REPLACE PACKAGE facturap IS
--Procedimientos
    PROCEDURE crear_factura (
        cod_fact   NUMBER,
        fecha         DATE,
        descripcion   VARCHAR2
    );
PROCEDURE eliminar_factura(cod_fact number);
PROCEDURE mod_descri(cod_fact number, descrip varchar2);
PROCEDURE mod_fecha(cod_fact number, fechaNueva date);

--FUNCIONES
FUNCTION num_factura(fecha_inicio date,fecha_fin date) return number;
FUNCTION total_factura(cod_fact number) return number;

END facturap;
/

CREATE OR REPLACE PACKAGE BODY facturap IS

--Funciones y procedimientos privados

/**Si bien las constraints creadas no permiten que se introduzcan valores duplicados,
Se hace esta funcion por motivos de practica de funciones, ya que en la vida real se deja
que la constraint maneje ese error, y en todo caso si se quiere mostrar un mensaje personalizado
Se edita la excepcion no predefinida con pragma y exec_init
**/

FUNCTION existe_factura (cod NUMBER) RETURN BOOLEAN
IS       
    
    codigo_prueba number;
BEGIN
    SELECT
        cod_factura
    INTO codigo_prueba
    FROM
        facturas
    WHERE
        cod_factura = cod;
    
    RETURN true;
    
EXCEPTION
    WHEN no_data_found THEN
        RETURN false;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001,'Error: ' || SQLCODE);
END existe_factura;

--Funciones y procedimientos publicos

---------------------------------PROCEDIMIENTOS
--CREAR FACTURA
    PROCEDURE crear_factura (
        cod_fact       NUMBER,
        fecha         DATE,
        descripcion   VARCHAR2
    ) IS
        existe boolean;
        errorYaExiste exception;
    BEGIN
        existe:=existe_factura(cod_fact);
        IF NOT existe THEN
            INSERT INTO facturas VALUES (
                cod_fact,
                fecha,
                descripcion
            );
    
            COMMIT;
        ELSE
            RAISE errorYaExiste;
        END IF;
    
    EXCEPTION
        WHEN errorYaExiste THEN
            RAISE_APPLICATION_ERROR(-20000, 'NO SE PUEDE INSERTAR, LA FACTURA YA EXISTE');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, 'Error: ' || SQLCODE);
        
    END crear_factura;
    
--BORRAR FACTURA
    PROCEDURE eliminar_factura (
        cod_fact NUMBER
    ) IS
        existe boolean;
        errorNoExiste exception;
    BEGIN
        existe:=existe_factura(cod_fact);
        IF existe THEN
        --Como en la constraint fk colocamos el ON DELETE CASCADE al eliminar el parent todas los registros que hacian referencias a esa factura, se eliminan;
            DELETE FROM FACTURAS WHERE cod_factura= cod_fact;
            COMMIT;
        ELSE
            RAISE errorNoExiste;
        END IF;
    
    EXCEPTION
        WHEN errorNoExiste THEN
            RAISE_APPLICATION_ERROR(-20000, 'NO SE PUEDE ELIMINAR, LA FACTURA NO EXISTE');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, 'Error: ' || SQLCODE);
        
    END eliminar_factura;

--MODIFICAR DESCRIPCION
    PROCEDURE mod_descri(cod_fact number, descrip varchar2)
    IS
        existe boolean;
        errorNoExiste exception;
    BEGIN
        existe:=existe_factura(cod_fact);
        IF existe THEN
           UPDATE FACTURAS SET descripcion=descrip WHERE cod_factura= cod_fact;
            COMMIT;
        ELSE
            RAISE errorNoExiste;
        END IF;
    
    EXCEPTION
        WHEN errorNoExiste THEN
            RAISE_APPLICATION_ERROR(-20000, 'NO SE PUEDE MODIFICAR, LA FACTURA NO EXISTE');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, 'Error: ' || SQLCODE);
        
    END mod_descri;

--MODIFICAR FECHA    
    PROCEDURE mod_fecha(cod_fact number, fechaNueva date)
    IS
        existe boolean;
        errorNoExiste exception;
    BEGIN
        existe:=existe_factura(cod_fact);
        IF existe THEN
           UPDATE FACTURAS SET fecha=fechaNueva WHERE cod_factura= cod_fact;
            COMMIT;
        ELSE
            RAISE errorNoExiste;
        END IF;
    
    EXCEPTION
        WHEN errorNoExiste THEN
            RAISE_APPLICATION_ERROR(-20000, 'NO SE PUEDE MODIFICAR, LA FACTURA NO EXISTE');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, 'Error: ' || SQLCODE);

    END mod_fecha;

------------------------------------------------------FUNCIONES

--RETORNAR EL NUMERO DE FACTURAS ENTRE UNA FECHA DETERMINADA
    FUNCTION num_factura(fecha_inicio date,fecha_fin date) return number
    IS
        numFactura number;
    BEGIN
    SELECT count(*) into numFactura FROM facturas WHERE fecha BETWEEN fecha_inicio AND fecha_fin;
    return numFactura;
    END num_factura;

--RETORNAR EL TOTAL A PAGAR DE LA FACTURA    
    FUNCTION total_factura(cod_fact number) return number
    IS
    totalAPagar number;
    BEGIN
        SELECT
            SUM(pvp * unidades)
        INTO totalAPagar
        FROM
            facturas         f,
            lineas_factura   lf
        WHERE
            f.cod_factura = lf.cod_factura
            AND f.cod_factura = cod_fact;
            
        RETURN totalAPagar;
    END total_factura;
END facturap;
/