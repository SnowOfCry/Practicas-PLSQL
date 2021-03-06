/*
    DDL PRACTICA 1
*/
--------------------------------------------------------
--  DDL for Table LINEAS_FACTURA
--------------------------------------------------------

  CREATE TABLE "HR"."LINEAS_FACTURA" 
   (	"COD_FACTURA" NUMBER, 
	"COD_PRODUCTO" NUMBER, 
	"PVP" NUMBER, 
	"UNIDADES" NUMBER, 
	"FECHA" DATE
   ) SEGMENT CREATION IMMEDIATE --Sirve para que la tabla no ocupe memoria hasta que se haga el primer el insert
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
--------------------------------------------------------
--  DDL for Table FACTURAS
--------------------------------------------------------

  CREATE TABLE "HR"."FACTURAS" 
   (	"COD_FACTURA" NUMBER(5,0), 
	"FECHA" DATE, 
	"DESCRIPCION" VARCHAR2(100 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
--------------------------------------------------------
--  DDL for Table PRODUCTOS
--------------------------------------------------------

  CREATE TABLE "HR"."PRODUCTOS" 
   (	"COD_PRODUCTO" NUMBER, 
	"NOMBRE_PRODUCTO" VARCHAR2(50 BYTE), 
	"PVP" NUMBER, 
	"TOTAL_VENDIDOS" NUMBER
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
--------------------------------------------------------
--  DDL for Table CONTROL_LOG
--------------------------------------------------------

  CREATE TABLE "HR"."CONTROL_LOG" 
   (	"COD_EMPLEADO" VARCHAR2(50), 
	"FECHA" DATE, 
	"TABLA" VARCHAR2(20 BYTE), 
	"COD_OPERACION" CHAR(1 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
REM INSERTING into HR.LINEAS_FACTURA
SET DEFINE OFF;
--------------------------------------------------------
--  DDL for Index LINEAS_FACTURA_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "HR"."LINEAS_FACTURA_PK" ON "HR"."LINEAS_FACTURA" ("COD_FACTURA", "COD_PRODUCTO") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
----

--------------------------------------------------------
--  Constraints 
--------------------------------------------------------

  ALTER TABLE "HR"."LINEAS_FACTURA" ADD CONSTRAINT "LINEAS_FACTURA_PK" PRIMARY KEY ("COD_FACTURA", "COD_PRODUCTO")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"  ENABLE;
  ALTER TABLE "HR"."LINEAS_FACTURA" MODIFY ("COD_PRODUCTO" NOT NULL ENABLE);
  ALTER TABLE "HR"."LINEAS_FACTURA" MODIFY ("COD_FACTURA" NOT NULL ENABLE);
  
  ALTER TABLE PRODUCTOS ADD CONSTRAINT PRODUCTOS_PK PRIMARY KEY (COD_PRODUCTO)
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"  ENABLE;
  
  ALTER TABLE FACTURAS  ADD CONSTRAINT FACTURAS_PK PRIMARY KEY(COD_FACTURA)
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"  ENABLE;
  
  ALTER TABLE HR.LINEAS_FACTURA
  ADD CONSTRAINT fk_lineas_factura 
  FOREIGN KEY (COD_PRODUCTO) 
  REFERENCES PRODUCTOS(COD_PRODUCTO) 
  ON DELETE CASCADE;
  
  ALTER TABLE HR.LINEAS_FACTURA
  ADD CONSTRAINT fk_factura
  FOREIGN KEY (COD_FACTURA)
  REFERENCES FACTURAS(COD_FACTURA)
  ON DELETE CASCADE;
  
SET DEFINE OFF;
Insert into HR.PRODUCTOS (COD_PRODUCTO,NOMBRE_PRODUCTO,PVP,TOTAL_VENDIDOS) values ('1','TORNILLO','1',null);
Insert into HR.PRODUCTOS (COD_PRODUCTO,NOMBRE_PRODUCTO,PVP,TOTAL_VENDIDOS) values ('2','TUERCA','5',null);
Insert into HR.PRODUCTOS (COD_PRODUCTO,NOMBRE_PRODUCTO,PVP,TOTAL_VENDIDOS) values ('3','ARANDELA','4',null);
Insert into HR.PRODUCTOS (COD_PRODUCTO,NOMBRE_PRODUCTO,PVP,TOTAL_VENDIDOS) values ('4','MARTILLO','40',null);
Insert into HR.PRODUCTOS (COD_PRODUCTO,NOMBRE_PRODUCTO,PVP,TOTAL_VENDIDOS) values ('5','CLAVO','1',null);
commit;

