/*  
    Uso de records con querys.
    
    SCHEMA usado: HR
    
*/

SET SERVEROUTPUT ON
/*
    Creando tu propio record, en este caso se ocupa el campo datos como %rowtype para demostrar
    que un  record puede tener otro record como campo.
    
    Ventajas: puedes tener solo la data que necesitas
    Desventaja: si el modelo de tu BD cambia o necesitas obtener mas datos, tienes que agregar mas campos a tu record
*/
DECLARE
    TYPE empleado IS RECORD (
        nombre    VARCHAR2(100),
        salario   NUMBER,
        fecha     employees.hire_date%TYPE,
        datos     employees%rowtype
    );
    
    --siempre se crea la variable del record que acabamos de crear
    emple1 empleado;
BEGIN
    SELECT
        *
    INTO emple1.datos
    FROM
        employees
    WHERE
        employee_id = 100;

    emple1.nombre := emple1.datos.first_name
                     || ' '
                     || emple1.datos.last_name;

    emple1.salario := emple1.datos.salary;
    emple1.fecha := emple1.datos.hire_date;
    dbms_output.put_line(emple1.nombre);
    dbms_output.put_line(emple1.salario);
    dbms_output.put_line(emple1.fecha);
    dbms_output.put_line(emple1.datos.first_name);
END;
/

/*INSERTS CON RECORDS
    Solo se necesita enviar el record (en caso que sea declarado como rowtype) ya que en este caso ya tiene la estructura
    de la tabla a la que vamos a hacer el insert
*/

DECLARE
    reg1 regions%rowtype;
BEGIN
    SELECT
        *
    INTO reg1
    FROM
        regions
    WHERE
        region_id = 1;

    reg1.region_name := 'Africa';
    reg1.region_id := 5;

-- INSERT
    INSERT INTO regions VALUES reg1;

END;
/
/*UPDATES CON RECORDS

Aca se utiliza la palabra clave ROW para indicarle que vamos a actualizar con los datos de nuestro record
*/
DECLARE
    reg1 regions%rowtype;
BEGIN
    reg1.region_id := 5;
    reg1.region_name := 'Australia';
    --UPDATE
    UPDATE regions
    SET
        row = reg1
    WHERE
        region_id = reg1.region_id;

END;
/

/*
 *Eliminar un fila usando un record
 */
SET SERVEROUTPUT ON;
DECLARE
    rec_employee RETIRED_EMPLOYEES%ROWTYPE;
BEGIN
    SELECT *
    INTO rec_employee
    FROM RETIRED_EMPLOYEES
    WHERE employee_id = 100;
    
    -- Eliminar no cambia en absoluto, porque siempre borra la fila entera
    DELETE FROM RETIRED_EMPLOYEES WHERE employee_id = rec_employee.employee_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Row deleted successfully');
END;