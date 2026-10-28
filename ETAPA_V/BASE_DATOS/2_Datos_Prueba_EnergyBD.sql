USE EnergyBD;
GO

-- ==========================================================
-- ENERGYBD - ETAPA V
-- DATOS DE PRUEBA
-- ==========================================================


-- ==========================================================
-- 1. TIPOS DE USUARIO
-- ==========================================================

INSERT INTO Tipo_usuario (nombre_tipoUsuario)
VALUES
('Administrador'),
('Cliente');
GO


-- ==========================================================
-- 2. CATEGORÍA
-- ==========================================================

INSERT INTO Categoria (
    nombre_categoria,
    descripcion
)
VALUES (
    'Proteinas',
    'Suplementos proteicos en polvo y barras'
);
GO


-- ==========================================================
-- 3. PROVINCIAS
-- ==========================================================

INSERT INTO Provincia (nombre)
VALUES
('Corrientes'),
('Chaco');
GO


-- ==========================================================
-- 4. CIUDAD
-- ==========================================================

INSERT INTO Ciudad (
    nombre,
    CP,
    id_provincia
)
VALUES (
    'Corrientes Capital',
    '3400',
    1
);
GO


-- ==========================================================
-- 5. USUARIO
-- ==========================================================

INSERT INTO Usuario (
    nombre_usuario,
    correo,
    contrasena,
    id_tipoUsuario
)
VALUES (
    'Ana Lopez',
    'ana.lopez@gmail.com',
    'Ana1234',
    2
);
GO


-- ==========================================================
-- 6. TELÉFONO
-- ==========================================================

INSERT INTO Telefono (
    nro_telefono,
    id_usuario
)
VALUES (
    '3794000002',
    1
);
GO


-- ==========================================================
-- 7. DIRECCIÓN
-- ==========================================================

INSERT INTO Direccion (
    calle,
    numero,
    barrio,
    id_usuario,
    id_ciudad
)
VALUES (
    'Av. 3 de Abril',
    '1250',
    'Centro',
    1,
    1
);
GO


-- ==========================================================
-- 8. PRODUCTO
-- ==========================================================

INSERT INTO Producto (
    nombre_producto,
    descripcion,
    precio,
    stock,
    destacado,
    activo,
    id_categoria
)
VALUES (
    'Whey Protein 1kg Vainilla',
    'Proteina de suero concentrada, 24g de proteina por porcion',
    45900.00,
    40,
    1,
    1,
    1
);
GO


-- ==========================================================
-- 9. CARRITO
-- ==========================================================

INSERT INTO Carrito (
    id_usuario
)
VALUES (
    1
);
GO


-- ==========================================================
-- 10. PEDIDO INICIAL
-- ==========================================================

INSERT INTO Pedido (
    total,
    fecha_pedido,
    estado,
    id_direccion,
    id_carrito
)
VALUES (
    45900.00,
    GETDATE(),
    'Pagado',
    1,
    1
);
GO


-- ==========================================================
-- 11. DETALLE DEL PEDIDO
-- ==========================================================

INSERT INTO Detalle_pedido (
    id_pedido,
    id_producto,
    cantidad,
    precioUnitario,
    subtotal
)
VALUES (
    1,
    1,
    1,
    45900.00,
    45900.00
);
GO


-- ==========================================================
-- 12. PAGO
-- ==========================================================

INSERT INTO Pago (
    comprobantePago,
    fecha_Acreditacion,
    metodoPago,
    estado,
    id_pedido
)
VALUES (
    'COMP-001',
    GETDATE(),
    'Transferencia',
    'Aprobado',
    1
);
GO


-- ==========================================================
-- 13. MENSAJE DE PRUEBA
-- ==========================================================

INSERT INTO Mensaje (
    nombre,
    correo,
    asunto,
    contenido,
    telefono,
    id_usuario
)
VALUES (
    'Ana Lopez',
    'ana.lopez@gmail.com',
    'Consulta de producto',
    'Quisiera consultar disponibilidad del producto.',
    '3794000002',
    1
);
GO


-- ==========================================================
-- VERIFICACIÓN DE LOS DATOS
-- ==========================================================

SELECT * FROM Tipo_usuario;
SELECT * FROM Categoria;
SELECT * FROM Provincia;
SELECT * FROM Ciudad;
SELECT * FROM Usuario;
SELECT * FROM Telefono;
SELECT * FROM Direccion;
SELECT * FROM Producto;
SELECT * FROM Carrito;
SELECT * FROM Pedido;
SELECT * FROM Detalle_pedido;
SELECT * FROM Pago;
SELECT * FROM Mensaje;
GO