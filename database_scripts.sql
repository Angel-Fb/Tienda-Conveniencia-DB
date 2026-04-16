/* =========================================================
   CREACIÓN DE BASE DE DATOS
   ========================================================= */

CREATE DATABASE BD_TAMBO
ON PRIMARY(
  NAME = BD_TAMBO_DATOS,
  FILENAME = 'D:\DATABASES\TAMBO\BD_TAMBO_DATOS.mdf',
  SIZE = 20MB, MAXSIZE = 150MB, FILEGROWTH = 5MB
)
LOG ON(
  NAME = BD_TAMBO_LOG,
  FILENAME = 'D:\DATABASES\TAMBO\BD_TAMBO_LOG.ldf',
  SIZE = 10MB, MAXSIZE = 100MB, FILEGROWTH = 10%
)

USE BD_TAMBO
GO

/* =========================================================
   CREACIÓN DE TABLAS
   ========================================================= */

CREATE TABLE TB_CLIENTE(
idCliente INT IDENTITY NOT NULL PRIMARY KEY,
nombre VARCHAR(50) NOT NULL,
ape_Mat VARCHAR(20) NOT NULL,
ape_Pat VARCHAR(20) NOT NULL,
direccion VARCHAR(120) NOT NULL,
telefono VARCHAR(9) CHECK (telefono LIKE '9________' OR telefono = '-' OR telefono IS NULL),
email VARCHAR(150) NOT NULL UNIQUE
)

CREATE TABLE TB_EMPLEADO(
idEmpleado INT IDENTITY NOT NULL PRIMARY KEY,
nombre VARCHAR(50) NOT NULL,
ape_Mat VARCHAR(20) NOT NULL,
ape_Pat VARCHAR(20) NOT NULL,
cargo VARCHAR(20) NOT NULL CHECK(cargo IN('CAJERO','REPONEDOR','ALMACENERO','MARKETING','RRHH','JEFE','LOGISTICA')),
turno VARCHAR(20) NOT NULL CHECK(turno IN('MAÑANA','TARDE','NOCHE')),
contacto VARCHAR(9) CHECK(contacto LIKE '9________')
)

CREATE TABLE TB_USUARIO(
idUsuario INT NOT NULL IDENTITY PRIMARY KEY,
idEmpleado INT NOT NULL REFERENCES TB_EMPLEADO,
nombreUser VARCHAR(100) NOT NULL,
contraseña VARCHAR(120) NOT NULL UNIQUE CHECK(LEN(contraseña)>8),
rol VARCHAR(20) NOT NULL CHECK(rol IN('CAJERO','MARKETING','ADMIN','LOGISTICA'))
)

CREATE TABLE TB_CATEGORIA(
idCat INT NOT NULL IDENTITY PRIMARY KEY,
nombreCat VARCHAR(50)
)

CREATE TABLE TB_PRODUCTO(
idProducto INT NOT NULL IDENTITY PRIMARY KEY,
idCat INT NOT NULL REFERENCES TB_CATEGORIA,
descripcion VARCHAR(50) NOT NULL,
pre_Uni MONEY NOT NULL,
stock INT NOT NULL CHECK(stock>0),
fec_Ven DATE NOT NULL
)

CREATE TABLE TB_VENTA(
idVenta INT IDENTITY NOT NULL PRIMARY KEY,
idCliente INT NOT NULL REFERENCES TB_CLIENTE(idCliente),
idEmpleado INT NOT NULL REFERENCES TB_EMPLEADO(idEmpleado),
fecha_hora DATETIME NOT NULL DEFAULT GETDATE(),
total MONEY NOT NULL
)

CREATE TABLE TB_DETALLE_VENTA(
id_Detalle INT NOT NULL IDENTITY PRIMARY KEY,
idVenta INT NOT NULL REFERENCES TB_VENTA,
idProducto INT NOT NULL REFERENCES TB_PRODUCTO,
canPro INT NOT NULL CHECK (canPro>0),
pre_Uni MONEY NOT NULL
)

CREATE TABLE TB_PAGO(
idPago INT IDENTITY NOT NULL PRIMARY KEY,
idVenta INT NOT NULL REFERENCES TB_VENTA,
monto MONEY NOT NULL,
metodoPago VARCHAR(10) DEFAULT('EFECTIVO') CHECK (metodoPago IN ('EFECTIVO','DEBITO','CREDITO')),
fecPago DATETIME NOT NULL DEFAULT GETDATE()
)

CREATE TABLE TB_HISTORIAL_INGRESO(
idIngreso INT NOT NULL IDENTITY PRIMARY KEY,
idProducto INT NOT NULL REFERENCES TB_PRODUCTO,
canIngresada INT NOT NULL CHECK (CanIngresada>0),
fecIngreso DATE NOT NULL
)

/* =========================================================
   INSERT DE DATOS
   ========================================================= */

-- Clientes
INSERT INTO TB_CLIENTE (nombre, ape_Mat, ape_Pat, direccion, telefono, email) VALUES
('Luis','Ramirez','Salazar','Av. Grau 123','912345678','luis.ramirez@example.com'),
('Ana','Flores','Lopez','Jr. Ayacucho 456','913456789','ana.flores@example.com'),
('Pedro','Gomez','Perez','Av. La Marina 789','914567890','pedro.gomez@example.com'),
('Julia','Torres','Vega','Jr. Misti 500','915123456','julia.torres@example.com'),
('Marco','Lopez','Gomez','Jr. Moquegua 321','916987654','marco.lopez@example.com');

-- Empleados
INSERT INTO TB_EMPLEADO (nombre, ape_Mat, ape_Pat, cargo, turno, contacto) VALUES
('Andrea','Sanchez','Lopez','CAJERO','MAÑANA','955111222'),
('Carlos','Quispe','Fernandez','LOGISTICA','TARDE','956222333'),
('María','Torres','Alvarez','MARKETING','NOCHE','957333444');

-- Categorías
INSERT INTO TB_CATEGORIA (nombreCat) VALUES
('Lácteos'),
('Bebidas'),
('Abarrotes'),
('Snacks');

-- Productos
INSERT INTO TB_PRODUCTO (idCat, descripcion, pre_Uni, stock, fec_Ven) VALUES
(1,'Leche Gloria 1L',4.50,100,'2025-12-31'),
(2,'Coca-Cola 500ml',3.50,200,'2025-10-10'),
(3,'Arroz Costeño 5kg',15.00,80,'2026-01-01');

/* =========================================================
   CONSULTAS
   ========================================================= */

SELECT * FROM TB_CLIENTE
SELECT * FROM TB_EMPLEADO

/* =========================================================
   PROCEDIMIENTOS ALMACENADOS
   ========================================================= */

-- Ventas Diarias
CREATE OR ALTER PROCEDURE USP_VENTAS_DIARIAS(@fecha DATE = NULL)
AS
BEGIN
SET NOCOUNT ON;

IF @fecha IS NULL
SET @fecha = CONVERT(DATE, GETDATE());

SELECT 
V.idVenta,
C.nombre + ' ' + C.ape_Pat + ' ' + C.ape_Mat AS cliente,
V.fecha_hora,
P.descripcion,
DV.canPro,
DV.pre_Uni
FROM TB_VENTA V
INNER JOIN TB_CLIENTE C ON V.idCliente = C.idCliente
INNER JOIN TB_DETALLE_VENTA DV ON V.idVenta = DV.idVenta
INNER JOIN TB_PRODUCTO P ON DV.idProducto = P.idProducto

END

/* =========================================================
   BACKUP
   ========================================================= */

BACKUP DATABASE BD_TAMBO
TO DISK = 'D:\BACKUPS\BD_TAMBO.bak'

/* =========================================================
   FIN DEL SCRIPT
   ========================================================= */
