/*
    Triggers para practica.
*/


--TRIGGER PARA CONTROL DE FACTURAS
CREATE OR REPLACE TRIGGER control_facturas
BEFORE INSERT OR UPDATE OR DELETE ON FACTURAS
DECLARE
    operacion char(1);
BEGIN
    IF INSERTING THEN
        operacion:='I';
    ELSIF UPDATING THEN
        operacion:='U';
    ELSIF DELETING THEN
        operacion:='D';
    END IF;
    INSERT INTO CONTROL_LOG VALUES(USER,SYSDATE,'FACTURAS',operacion);
END;
/
--TRIGGER PARA CONTROL DE LINEAS_FACTURAS
CREATE OR REPLACE TRIGGER control_lineas_facturas
BEFORE INSERT OR UPDATE OR DELETE ON LINEAS_FACTURA
BEGIN
    IF INSERTING THEN
        operacion:='I';
    ELSIF UPDATING THEN
        operacion:='U';
    ELSIF DELETING THEN
        operacion:='D';
    END IF;
    INSERT INTO CONTROL_LOG VALUES(USER,SYSDATE,'LINEAS_FACTURAS',operacion);

END;
/
--TRIGGER PARA CONTROLAR LA COLUMNA TOTAL_VENDIDOS DE LA TABLA PRODUCTOS DEPENDIENDO DE LO QUE OCURRA EN LA TABLA LINEAS_VENTAS
CREATE OR REPLACE TRIGGER control_total_vendidos
BEFORE UPDATE OR INSERT OR DELETE ON lineas_factura
FOR EACH ROW
DECLARE
    --Variable a ocupar en caso de actualizacion
    total_update number:=0;
BEGIN
    IF INSERTING THEN
        UPDATE PRODUCTOS SET TOTAL_VENDIDOS= NVL(TOTAL_VENDIDOS,0)+(:new.pvp*:new.unidades)
        WHERE cod_producto = :new.cod_producto;
    ELSIF UPDATING THEN
        total_update:= (:old.pvp*:old.unidades)-(:new.pvp*:new.unidades);
        UPDATE PRODUCTOS SET TOTAL_VENDIDOS= NVL(TOTAL_VENDIDOS,0)+total_update
        WHERE cod_producto = :new.cod_producto;
    ELSIF DELETING THEN
        UPDATE PRODUCTOS SET TOTAL_VENDIDOS= NVL(TOTAL_VENDIDOS,0)-(:old.pvp*:old.unidades)
        WHERE cod_producto = :new.cod_producto;
    END IF;
        
END control_total_vendidos;
/
