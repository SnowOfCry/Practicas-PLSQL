/*
    Paquetas para la linea_facturas
*/

CREATE OR REPLACE PACKAGE linea_facturap AS 
--Procedimientos
    PROCEDURE crear_linea (
        cod_fact    NUMBER,
        cod_produ   NUMBER,
        unid        NUMBER,
        fechac      DATE
    );

    PROCEDURE eliminar_linea (
        cod_fact    NUMBER,
        cod_produ   NUMBER
    );

    PROCEDURE mod_produc (
        cod_fact    NUMBER,
        cod_produ   NUMBER,
        unid        NUMBER
    );

    PROCEDURE mod_produc (
        cod_fact    NUMBER,
        cod_produ   NUMBER,
        fechac      DATE
    );

--Funciones

    FUNCTION num_lineas (
        cod_fact NUMBER
    ) RETURN NUMBER;

END linea_facturap;

CREATE OR REPLACE PACKAGE BODY linea_facturap AS
--Privados
/**Si bien las constraints creadas no permiten que se introduzcan valores duplicados,
Se hace esta funcion por motivos de practica de funciones, ya que en la vida real se deja
que la constraint maneje ese error, y en todo caso si se quiere mostrar un mensaje personalizado
Se edita la excepcion no predefinida con pragma y exec_init


**/

    FUNCTION existe_factura (
        cod_fact    NUMBER,
        cod_produ   NUMBER
    ) RETURN BOOLEAN IS
        codigo_prueba NUMBER;
    BEGIN
        SELECT
            f.cod_factura
        INTO codigo_prueba
        FROM
            lineas_factura   lf,
            productos        p,
            facturas         f
        WHERE
            lf.cod_producto = p.cod_producto
            AND lf.cod_factura = f.cod_factura
            AND f.cod_factura = cod_fact
            AND p.cod_producto = cod_produ;

        IF SQL%rowcount = 0 THEN
            RETURN false;
        ELSE
            RETURN true;
        END IF;
    EXCEPTION
        WHEN no_data_found THEN
            RETURN false;
        WHEN OTHERS THEN
            raise_application_error(-20001, 'Error: ' || sqlerrm);
    END existe_factura;

--PUBLICOS
--CREAR LINEA DE FACTURA

    PROCEDURE crear_linea (
        cod_fact    NUMBER,
        cod_produ   NUMBER,
        unid        NUMBER,
        fechac      DATE
    ) AS
        existe   BOOLEAN;
        erroryaexiste EXCEPTION;
        precio   productos.pvp%TYPE;
    BEGIN
        existe := existe_factura(cod_fact, cod_produ);
        IF NOT existe THEN
            SELECT
                pvp
            INTO precio
            FROM
                productos
            WHERE
                cod_producto = cod_produ;

            INSERT INTO lineas_factura (
                cod_factura,
                cod_producto,
                pvp,
                unidades,
                fecha
            ) VALUES (
                cod_fact,
                cod_produ,
                precio,
                unid,
                fechac
            );

            COMMIT;
        ELSE
            RAISE erroryaexiste;
        END IF;

    EXCEPTION
        WHEN erroryaexiste THEN
            raise_application_error(-20000, 'NO SE PUEDE INSERTAR, LA FACTURA O PRODUCTO YA EXISTE');
        --ESTA EXCEPCION SE PUEDE DAR CUANDO TRAEMOS EL PVP DE LA TABLA PRODUCTOS
        WHEN no_data_found THEN
            raise_application_error(-20001, 'EL PRODUCTO NO EXISTE');
        WHEN OTHERS THEN
            raise_application_error(-20002, 'Error: ' || sqlerrm);
    END crear_linea;
  
  
--ELIMINAR LINEA DE FACTURA

    PROCEDURE eliminar_linea (
        cod_fact    NUMBER,
        cod_produ   NUMBER
    ) AS
        existe BOOLEAN;
        erroryaexiste EXCEPTION;
    BEGIN
        existe := existe_factura(cod_fact, cod_produ);
        IF existe THEN
            DELETE FROM lineas_factura
            WHERE
                cod_factura = cod_fact
                AND cod_producto = cod_produ;

            COMMIT;
        ELSE
            RAISE erroryaexiste;
        END IF;

    EXCEPTION
        WHEN erroryaexiste THEN
            raise_application_error(-20000, 'NO SE PUEDE ELIMINAR, LA FACTURA O PRODUCTO NO EXISTE');
        WHEN OTHERS THEN
            raise_application_error(-20001, 'Error: ' || sqlcode);
    END eliminar_linea;
  
--MODIFICAR LINEA DE FACTURA CON SOBRECARGA DE METODOS

    PROCEDURE mod_produc (
        cod_fact    NUMBER,
        cod_produ   NUMBER,
        unid        NUMBER
    ) AS
        existe BOOLEAN;
        erroryaexiste EXCEPTION;
    BEGIN
        existe := existe_factura(cod_fact, cod_produ);
        IF existe THEN
            UPDATE lineas_factura
            SET
                unidades = unid
            WHERE
                cod_factura = cod_fact
                AND cod_producto = cod_produ;

            COMMIT;
        ELSE
            RAISE erroryaexiste;
        END IF;

    EXCEPTION
        WHEN erroryaexiste THEN
            raise_application_error(-20000, 'NO SE PUEDE ACTUALIZAR, LA FACTURA O PRODUCTO NO EXISTE');
        WHEN OTHERS THEN
            raise_application_error(-20001, 'Error: ' || sqlcode);
    END mod_produc;

    PROCEDURE mod_produc (
        cod_fact    NUMBER,
        cod_produ   NUMBER,
        fechac      DATE
    ) AS
        existe BOOLEAN;
        erroryaexiste EXCEPTION;
    BEGIN
        existe := existe_factura(cod_fact, cod_produ);
        IF existe THEN
            UPDATE lineas_factura
            SET
                fecha = fechac
            WHERE
                cod_producto = cod_fact
                AND cod_producto = cod_produ;

            COMMIT;
        ELSE
            RAISE erroryaexiste;
        END IF;

    EXCEPTION
        WHEN erroryaexiste THEN
            raise_application_error(-20000, 'NO SE PUEDE ACTUALIZAR, LA FACTURA O PRODUCTO NO EXISTE');
        WHEN OTHERS THEN
            raise_application_error(-20001, 'Error: ' || sqlcode);
    END mod_produc;

--FUNCION

    FUNCTION num_lineas (
        cod_fact NUMBER
    ) RETURN NUMBER AS
        numer_lineas NUMBER;
    BEGIN
    --Como count si no encuentra ningun valor nos retorna 0, no se maneja la excepcion.
        SELECT
            COUNT(*)
        INTO numer_lineas
        FROM
            lineas_factura
        WHERE
            cod_factura = cod_fact;

        RETURN numer_lineas;
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20001, 'Error: ' || sqlcode);
    END num_lineas;

END linea_facturap;