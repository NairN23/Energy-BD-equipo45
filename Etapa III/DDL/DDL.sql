CREATE DATABASE EnergyBD;
GO

USE EnergyBD;
GO

-- =========================================================
-- TABLA TIPO_USUARIO
-- =========================================================
CREATE TABLE Tipo_usuario (
    id_tipoUsuario INT IDENTITY(1,1) NOT NULL,
    nombre_tipoUsuario VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Tipo_usuario PRIMARY KEY (id_tipoUsuario),
    CONSTRAINT UQ_Tipo_usuario_nombre UNIQUE (nombre_tipoUsuario)
);

-- =========================================================
-- TABLA USUARIO
-- =========================================================
CREATE TABLE Usuario (
    id_usuario INT IDENTITY(1,1) NOT NULL,
    nombre_usuario VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    contrasenia VARCHAR(100) NOT NULL,
    activo INT NOT NULL,
    id_tipoUsuario INT NOT NULL,

    CONSTRAINT PK_Usuario PRIMARY KEY (id_usuario),
    CONSTRAINT UQ_Usuario_correo UNIQUE (correo),
    CONSTRAINT CK_Usuario_activo CHECK (activo IN (0,1)),
    CONSTRAINT FK_Usuario_TipoUsuario FOREIGN KEY (id_tipoUsuario) REFERENCES Tipo_usuario(id_tipoUsuario)
);

ALTER TABLE Usuario
ADD CONSTRAINT DF_Usuario_activo DEFAULT 1 FOR activo;

-- =========================================================
-- TABLA TELEFONO
-- =========================================================
CREATE TABLE Telefono (
    id_telefono INT IDENTITY(1,1) NOT NULL,
    nro_telefono VARCHAR(20) NOT NULL,
    id_usuario INT NOT NULL,

    CONSTRAINT PK_Telefono PRIMARY KEY (id_telefono),
    CONSTRAINT UQ_Telefono_numero UNIQUE (nro_telefono),
    CONSTRAINT FK_Telefono_Usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

-- =========================================================
-- TABLA MENSAJE
-- =========================================================
CREATE TABLE Mensaje (
    id_mensaje INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    asunto VARCHAR(100) NOT NULL,
    contenido VARCHAR(1000) NOT NULL,
    leido INT NOT NULL,
    fecha_envio DATETIME NOT NULL,
    telefono VARCHAR(20) NULL,
    id_usuario INT NULL,

    CONSTRAINT PK_Mensaje PRIMARY KEY (id_mensaje),
    CONSTRAINT CK_Mensaje_leido CHECK (leido IN (0,1)),
    CONSTRAINT FK_Mensaje_Usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

ALTER TABLE Mensaje
ADD CONSTRAINT DF_Mensaje_leido DEFAULT 0 FOR leido;

-- =========================================================
-- TABLA CATEGORIA
-- =========================================================
CREATE TABLE Categoria (
    id_categoria INT IDENTITY(1,1) NOT NULL,
    nombre_categoria VARCHAR(60) NOT NULL,
    descripcion VARCHAR(200) NULL,
    activa INT NOT NULL,

    CONSTRAINT PK_Categoria PRIMARY KEY (id_categoria),
    CONSTRAINT UQ_Categoria_nombre UNIQUE (nombre_categoria),
    CONSTRAINT CK_Categoria_activa CHECK (activa IN (0,1))
);

ALTER TABLE Categoria
ADD CONSTRAINT DF_Categoria_activa DEFAULT 1 FOR activa;

-- =========================================================
-- TABLA PRODUCTO
-- =========================================================
CREATE TABLE Producto (
    id_producto INT IDENTITY(1,1) NOT NULL,
    nombre_producto VARCHAR(120) NOT NULL,
    descripcion VARCHAR(500) NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    destacado INT NOT NULL,
    activo INT NOT NULL,
    id_categoria INT NOT NULL,

    CONSTRAINT PK_Producto PRIMARY KEY (id_producto),
    CONSTRAINT UQ_Producto_nombre UNIQUE (nombre_producto),
    CONSTRAINT CK_Producto_stock CHECK (stock >= 0),
    CONSTRAINT CK_Producto_precio CHECK (precio > 0),
    CONSTRAINT CK_Producto_destacado CHECK (destacado IN (0,1)),
    CONSTRAINT CK_Producto_activo CHECK (activo IN (0,1)),
    CONSTRAINT FK_Producto_Categoria FOREIGN KEY (id_categoria)
        REFERENCES Categoria(id_categoria)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);

ALTER TABLE Producto
ADD CONSTRAINT DF_Producto_stock DEFAULT 0 FOR stock;

ALTER TABLE Producto
ADD CONSTRAINT DF_Producto_destacado DEFAULT 0 FOR destacado;

ALTER TABLE Producto
ADD CONSTRAINT DF_Producto_activo DEFAULT 1 FOR activo;

-- =========================================================
-- TABLA PROVINCIA Y CIUDAD
-- =========================================================
CREATE TABLE Provincia (
    id_provincia INT IDENTITY(1,1) NOT NULL, 
    nombre VARCHAR(100) NOT NULL, 
    CONSTRAINT PK_Provincia PRIMARY KEY (id_provincia) 
); 

CREATE TABLE Ciudad ( 
    id_ciudad INT IDENTITY(1,1) NOT NULL, 
    nombre VARCHAR(100) NOT NULL, 
    CP VARCHAR(10) NOT NULL, 
    id_provincia INT NOT NULL, 

    CONSTRAINT PK_Ciudad PRIMARY KEY (id_ciudad), 
    CONSTRAINT FK_Ciudad_Provincia FOREIGN KEY (id_provincia) 
        REFERENCES Provincia(id_provincia)
        ON UPDATE CASCADE 
        ON DELETE CASCADE 
); 

-- =========================================================
-- TABLA DIRECCION
-- =========================================================
CREATE TABLE Direccion (
    id_direccion INT IDENTITY(1,1) NOT NULL,
    calle VARCHAR(150) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    barrio VARCHAR(100) NULL,
    id_usuario INT NOT NULL,
    id_ciudad INT NOT NULL,

    CONSTRAINT PK_Direccion PRIMARY KEY (id_direccion),
    CONSTRAINT FK_Direccion_Ciudad FOREIGN KEY (id_ciudad) 
        REFERENCES Ciudad(id_ciudad)
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
    CONSTRAINT FK_Direccion_Usuario FOREIGN KEY (id_usuario) 
        REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE 
        ON DELETE CASCADE
);

-- =========================================================
-- TABLA CARRITO
-- =========================================================
CREATE TABLE Carrito (
    id_carrito INT IDENTITY(1,1) NOT NULL,
    id_usuario INT NOT NULL,

    CONSTRAINT PK_Carrito PRIMARY KEY (id_carrito),
    CONSTRAINT FK_Carrito_Usuario FOREIGN KEY (id_usuario) 
        REFERENCES Usuario(id_usuario)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- =========================================================
-- TABLA PEDIDO
-- =========================================================
CREATE TABLE Pedido (
    id_pedido INT IDENTITY(1,1) NOT NULL,
    total DECIMAL(12,2) NOT NULL,
    fecha_pedido DATETIME NOT NULL CONSTRAINT DF_Pedido_fecha DEFAULT GETDATE(),
    estado VARCHAR(30) NOT NULL CONSTRAINT DF_Pedido_estado DEFAULT 'Pendiente',
    id_direccion INT NOT NULL,
    id_carrito INT NOT NULL,

    CONSTRAINT PK_Pedido PRIMARY KEY (id_pedido),
    CONSTRAINT UQ_Pedido_Carrito UNIQUE (id_carrito),
    CONSTRAINT CK_Pedido_Total CHECK (total >= 0.00),
    CONSTRAINT CK_Pedido_Estado CHECK (
        estado IN ('Pendiente', 'Pagado', 'En Preparación', 'Enviado', 'Entregado', 'Cancelado')
    ),
    CONSTRAINT FK_Pedido_Direccion FOREIGN KEY (id_direccion) 
        REFERENCES Direccion(id_direccion)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT FK_Pedido_Carrito FOREIGN KEY (id_carrito) 
        REFERENCES Carrito(id_carrito)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);

-- =========================================================
-- TABLA DETALLE_PEDIDO
-- =========================================================
CREATE TABLE Detalle_pedido ( 
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precioUnitario DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_Detalle_pedido PRIMARY KEY (id_pedido, id_producto),
    CONSTRAINT FK_Detalle_Pedido FOREIGN KEY (id_pedido) 
        REFERENCES Pedido(id_pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_Detalle_Producto FOREIGN KEY (id_producto) 
        REFERENCES Producto(id_producto)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT CK_Detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT CK_Detalle_precioUnitario CHECK (precioUnitario > 0.00)
);

-- =========================================================
-- TABLA PAGO
-- =========================================================
CREATE TABLE Pago (
    id_pago INT IDENTITY(1,1) NOT NULL,
    comprobante_pago VARCHAR(50) NOT NULL,
    fecha_acreditacion DATETIME NOT NULL, 
    metodoPago VARCHAR(30) NOT NULL, 
    estado VARCHAR(30) NOT NULL,
    id_pedido INT NOT NULL,

    CONSTRAINT PK_Pago PRIMARY KEY (id_pago),
    CONSTRAINT UQ_Pago_comprobante UNIQUE (comprobante_pago),
    CONSTRAINT FK_Pago_Pedido FOREIGN KEY (id_pedido) 
        REFERENCES Pedido(id_pedido)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT CK_Pago_Estado CHECK (
        estado IN ('Aprobado', 'Pendiente', 'Rechazado', 'Reembolsado')
    ),
    CONSTRAINT CK_Pago_Metodo CHECK (
        metodoPago IN ('Tarjeta Credito', 'Tarjeta Debito', 'Transferencia', 'Efectivo', 'Mercado Pago')
    )
);

ALTER TABLE Pago
ADD CONSTRAINT DF_Pago_fecha DEFAULT GETDATE() FOR fecha_acreditacion;