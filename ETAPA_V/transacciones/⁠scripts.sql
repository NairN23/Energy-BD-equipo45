
USE EnergyBD;
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProcesarVentaConPago
    @id_usuario INT,
    @id_direccion INT,
    @id_carrito INT,
    @id_producto INT,
    @cantidad INT,
    @precioUnitario DECIMAL(10,2),
    @metodoPago VARCHAR(50),
    @comprobantePago VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @stockActual INT;
        SELECT @stockActual = stock FROM dbo.Producto WHERE id_producto = @id_producto;

        IF @stockActual IS NULL
            THROW 50001, 'El producto especificado no existe.', 1;

        IF @stockActual < @cantidad
            THROW 50002, 'Stock insuficiente para concretar la venta.', 1;

        DECLARE @id_pedido_generado INT;
        DECLARE @montoTotal DECIMAL(10,2) = @cantidad * @precioUnitario;

        INSERT INTO dbo.Pedido (total, fecha_pedido, estado, id_direccion, id_carrito)
        VALUES (@montoTotal, GETDATE(), 'Completado', @id_direccion, @id_carrito);

        SET @id_pedido_generado = SCOPE_IDENTITY();

        INSERT INTO dbo.Detalle_pedido (id_pedido, id_producto, cantidad, precioUnitario, subtotal)
        VALUES (@id_pedido_generado, @id_producto, @cantidad, @precioUnitario, @montoTotal);

        UPDATE dbo.Producto
        SET stock = stock - @cantidad
        WHERE id_producto = @id_producto;

        INSERT INTO dbo.Pago (comprobantePago, fecha_Acreditacion, metodoPago, estado, id_pedido)
        VALUES (@comprobantePago, GETDATE(), @metodoPago, 'Aprobado', @id_pedido_generado);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO
