USE EnergyBD;
GO

-- ==========================================================
-- TEMA 1 - PROCEDIMIENTOS Y FUNCIONES ALMACENADAS
-- ==========================================================


-- ==========================================================
-- 1. FUNCIÓN: TOTAL GASTADO POR UN USUARIO
-- ==========================================================

CREATE OR ALTER FUNCTION dbo.fn_TotalGastadoUsuario
(
    @id_usuario INT
)
RETURNS DECIMAL(12,2)
AS
BEGIN

    DECLARE @totalGastado DECIMAL(12,2);

    SELECT @totalGastado = ISNULL(SUM(p.total), 0)
    FROM Pedido AS p
    INNER JOIN Carrito AS c
        ON p.id_carrito = c.id_carrito
    WHERE c.id_usuario = @id_usuario
      AND p.estado <> 'Cancelado';

    RETURN @totalGastado;

END;
GO


-- ==========================================================
-- 2. PROCEDIMIENTO: REGISTRAR UN PEDIDO
-- ==========================================================

CREATE OR ALTER PROCEDURE dbo.sp_RegistrarPedido
    @id_carrito INT,
    @id_direccion INT,
    @id_producto INT,
    @cantidad INT
AS
BEGIN

    DECLARE @precio DECIMAL(10,2);
    DECLARE @stock INT;
    DECLARE @total DECIMAL(10,2);
    DECLARE @id_pedido INT;

    SELECT
        @precio = precio,
        @stock = stock
    FROM Producto
    WHERE id_producto = @id_producto;

    -- Validar existencia del producto
    IF @precio IS NULL
    BEGIN
        PRINT 'El producto no existe.';
        RETURN;
    END;

    -- Validar cantidad
    IF @cantidad <= 0
    BEGIN
        PRINT 'La cantidad debe ser mayor a cero.';
        RETURN;
    END;

    -- Validar stock
    IF @stock < @cantidad
    BEGIN
        PRINT 'Stock insuficiente.';
        RETURN;
    END;

    -- Calcular total
    SET @total = @precio * @cantidad;

    -- Registrar pedido
    INSERT INTO Pedido (
        total,
        fecha_pedido,
        estado,
        id_direccion,
        id_carrito
    )
    VALUES (
        @total,
        GETDATE(),
        'Pendiente',
        @id_direccion,
        @id_carrito
    );

    SET @id_pedido = SCOPE_IDENTITY();

    -- Registrar detalle
    INSERT INTO Detalle_pedido (
        id_pedido,
        id_producto,
        cantidad,
        precioUnitario,
        subtotal
    )
    VALUES (
        @id_pedido,
        @id_producto,
        @cantidad,
        @precio,
        @total
    );

    -- Actualizar stock
    UPDATE Producto
    SET stock = stock - @cantidad
    WHERE id_producto = @id_producto;

    PRINT 'Pedido registrado correctamente.';

END;
GO


-- ==========================================================
-- 3. PRUEBA DE LA FUNCIÓN
-- ==========================================================

SELECT dbo.fn_TotalGastadoUsuario(1) AS TotalGastado;
GO


-- ==========================================================
-- 4. PRUEBA EXITOSA DEL PROCEDIMIENTO
-- ==========================================================

EXEC dbo.sp_RegistrarPedido
    @id_carrito = 1,
    @id_direccion = 1,
    @id_producto = 1,
    @cantidad = 2;
GO


-- Verificación del resultado
SELECT * FROM Pedido;
SELECT * FROM Detalle_pedido;
SELECT * FROM Producto;
GO


-- ==========================================================
-- 5. PRUEBA FALLIDA: PRODUCTO INEXISTENTE
-- ==========================================================

EXEC dbo.sp_RegistrarPedido
    @id_carrito = 1,
    @id_direccion = 1,
    @id_producto = 999,
    @cantidad = 2;
GO


-- ==========================================================
-- 6. PRUEBA FALLIDA: CANTIDAD INVÁLIDA
-- ==========================================================

EXEC dbo.sp_RegistrarPedido
    @id_carrito = 1,
    @id_direccion = 1,
    @id_producto = 1,
    @cantidad = 0;
GO


-- ==========================================================
-- 7. PRUEBA FALLIDA: STOCK INSUFICIENTE
-- ==========================================================

EXEC dbo.sp_RegistrarPedido
    @id_carrito = 1,
    @id_direccion = 1,
    @id_producto = 1,
    @cantidad = 100;
GO