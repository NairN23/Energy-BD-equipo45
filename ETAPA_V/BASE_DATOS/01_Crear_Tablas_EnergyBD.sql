USE EnergyBD;
GO

-- ==========================================================
-- ENERGYBD - ETAPA V
-- CREACIÓN DE TABLAS
-- ==========================================================


-- ==========================================================
-- 1. TABLA TIPO_USUARIO
-- ==========================================================

CREATE TABLE Tipo_usuario (
    id_tipoUsuario INT IDENTITY(1,1) NOT NULL,
    nombre_tipoUsuario VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Tipo_usuario
        PRIMARY KEY (id_tipoUsuario),

    CONSTRAINT UQ_Tipo_usuario_nombre
        UNIQUE (nombre_tipoUsuario)
);
GO


-- ==========================================================
-- 2. TABLA CATEGORIA
-- ==========================================================

CREATE TABLE Categoria (
    id_categoria INT IDENTITY(1,1) NOT NULL,
    nombre_categoria VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    activa BIT NOT NULL
        CONSTRAINT DF_Categoria_activa DEFAULT 1,

    CONSTRAINT PK_Categoria
        PRIMARY KEY (id_categoria),

    CONSTRAINT UQ_Categoria_nombre
        UNIQUE (nombre_categoria)
);
GO


-- ==========================================================
-- 3. TABLA PROVINCIA
-- ==========================================================

CREATE TABLE Provincia (
    id_provincia INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,

    CONSTRAINT PK_Provincia
        PRIMARY KEY (id_provincia)
);
GO


-- ==========================================================
-- 4. TABLA USUARIO
-- ==========================================================

CREATE TABLE Usuario (
    id_usuario INT IDENTITY(1,1) NOT NULL,
    nombre_usuario VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    activo BIT NOT NULL
        CONSTRAINT DF_Usuario_activo DEFAULT 1,
    id_tipoUsuario INT NOT NULL,

    CONSTRAINT PK_Usuario
        PRIMARY KEY (id_usuario),

    CONSTRAINT UQ_Usuario_correo
        UNIQUE (correo),

    CONSTRAINT FK_Usuario_TipoUsuario
        FOREIGN KEY (id_tipoUsuario)
        REFERENCES Tipo_usuario(id_tipoUsuario)
);
GO


-- ==========================================================
-- 5. TABLA PRODUCTO
-- ==========================================================

CREATE TABLE Producto (
    id_producto INT IDENTITY(1,1) NOT NULL,
    nombre_producto VARCHAR(150) NOT NULL,
    descripcion VARCHAR(255) NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    destacado BIT NOT NULL
        CONSTRAINT DF_Producto_destacado DEFAULT 0,
    activo BIT NOT NULL
        CONSTRAINT DF_Producto_activo DEFAULT 1,
    id_categoria INT NOT NULL,

    CONSTRAINT PK_Producto
        PRIMARY KEY (id_producto),

    CONSTRAINT CK_Producto_precio
        CHECK (precio > 0),

    CONSTRAINT CK_Producto_stock
        CHECK (stock >= 0),

    CONSTRAINT FK_Producto_Categoria
        FOREIGN KEY (id_categoria)
        REFERENCES Categoria(id_categoria)
);
GO


-- ==========================================================
-- 6. TABLA CIUDAD
-- ==========================================================

CREATE TABLE Ciudad (
    id_ciudad INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    CP VARCHAR(20) NULL,
    id_provincia INT NOT NULL,

    CONSTRAINT PK_Ciudad
        PRIMARY KEY (id_ciudad),

    CONSTRAINT FK_Ciudad_Provincia
        FOREIGN KEY (id_provincia)
        REFERENCES Provincia(id_provincia)
);
GO


-- ==========================================================
-- 7. TABLA TELEFONO
-- ==========================================================

CREATE TABLE Telefono (
    id_telefono INT IDENTITY(1,1) NOT NULL,
    nro_telefono VARCHAR(30) NOT NULL,
    id_usuario INT NOT NULL,

    CONSTRAINT PK_Telefono
        PRIMARY KEY (id_telefono),

    CONSTRAINT FK_Telefono_Usuario
        FOREIGN KEY (id_usuario)
        REFERENCES Usuario(id_usuario)
);
GO


-- ==========================================================
-- 8. TABLA DIRECCION
-- ==========================================================

CREATE TABLE Direccion (
    id_direccion INT IDENTITY(1,1) NOT NULL,
    calle VARCHAR(150) NOT NULL,
    numero VARCHAR(20) NULL,
    barrio VARCHAR(100) NULL,
    id_usuario INT NOT NULL,
    id_ciudad INT NOT NULL,

    CONSTRAINT PK_Direccion
        PRIMARY KEY (id_direccion),

    CONSTRAINT FK_Direccion_Usuario
        FOREIGN KEY (id_usuario)
        REFERENCES Usuario(id_usuario),

    CONSTRAINT FK_Direccion_Ciudad
        FOREIGN KEY (id_ciudad)
        REFERENCES Ciudad(id_ciudad)
);
GO


-- ==========================================================
-- 9. TABLA CARRITO
-- ==========================================================

CREATE TABLE Carrito (
    id_carrito INT IDENTITY(1,1) NOT NULL,
    id_usuario INT NOT NULL,

    CONSTRAINT PK_Carrito
        PRIMARY KEY (id_carrito),

    CONSTRAINT FK_Carrito_Usuario
        FOREIGN KEY (id_usuario)
        REFERENCES Usuario(id_usuario)
);
GO


-- ==========================================================
-- 10. TABLA MENSAJE
-- ==========================================================

CREATE TABLE Mensaje (
    id_mensaje INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NULL,
    correo VARCHAR(150) NULL,
    asunto VARCHAR(150) NULL,
    contenido VARCHAR(1000) NULL,
    leido BIT NOT NULL
        CONSTRAINT DF_Mensaje_leido DEFAULT 0,
    fecha_envio DATETIME NOT NULL
        CONSTRAINT DF_Mensaje_fecha DEFAULT GETDATE(),
    telefono VARCHAR(30) NULL,
    id_usuario INT NULL,

    CONSTRAINT PK_Mensaje
        PRIMARY KEY (id_mensaje),

    CONSTRAINT FK_Mensaje_Usuario
        FOREIGN KEY (id_usuario)
        REFERENCES Usuario(id_usuario)
);
GO


-- ==========================================================
-- 11. TABLA PEDIDO
-- ==========================================================

CREATE TABLE Pedido (
    id_pedido INT IDENTITY(1,1) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    fecha_pedido DATETIME NOT NULL
        CONSTRAINT DF_Pedido_fecha DEFAULT GETDATE(),
    estado VARCHAR(50) NOT NULL,
    id_direccion INT NOT NULL,
    id_carrito INT NOT NULL,

    CONSTRAINT PK_Pedido
        PRIMARY KEY (id_pedido),

    CONSTRAINT CK_Pedido_total
        CHECK (total >= 0),

    CONSTRAINT FK_Pedido_Direccion
        FOREIGN KEY (id_direccion)
        REFERENCES Direccion(id_direccion),

    CONSTRAINT FK_Pedido_Carrito
        FOREIGN KEY (id_carrito)
        REFERENCES Carrito(id_carrito)
);
GO


-- ==========================================================
-- 12. TABLA DETALLE_PEDIDO
-- ==========================================================

CREATE TABLE Detalle_pedido (
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precioUnitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_Detalle_pedido
        PRIMARY KEY (id_pedido, id_producto),

    CONSTRAINT CK_Detalle_cantidad
        CHECK (cantidad > 0),

    CONSTRAINT CK_Detalle_precio
        CHECK (precioUnitario > 0),

    CONSTRAINT CK_Detalle_subtotal
        CHECK (subtotal >= 0),

    CONSTRAINT FK_Detalle_Pedido
        FOREIGN KEY (id_pedido)
        REFERENCES Pedido(id_pedido),

    CONSTRAINT FK_Detalle_Producto
        FOREIGN KEY (id_producto)
        REFERENCES Producto(id_producto)
);
GO


-- ==========================================================
-- 13. TABLA PAGO
-- ==========================================================

CREATE TABLE Pago (
    id_pago INT IDENTITY(1,1) NOT NULL,
    comprobantePago VARCHAR(100) NULL,
    fecha_Acreditacion DATETIME NULL,
    metodoPago VARCHAR(50) NOT NULL,
    estado VARCHAR(50) NOT NULL,
    id_pedido INT NOT NULL,

    CONSTRAINT PK_Pago
        PRIMARY KEY (id_pago),

    CONSTRAINT UQ_Pago_comprobante
        UNIQUE (comprobantePago),

    CONSTRAINT FK_Pago_Pedido
        FOREIGN KEY (id_pedido)
        REFERENCES Pedido(id_pedido)
);
GO


-- ==========================================================
-- VERIFICACIÓN DE LAS TABLAS CREADAS
-- ==========================================================

SELECT name
FROM sys.tables
ORDER BY name;
GO