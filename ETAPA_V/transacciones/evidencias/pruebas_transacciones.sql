Evidencias - EnergyBD

-- ----------------------------------------------------------
-- CASO 1: TRANSACCIÓN EXITOSA (COMMIT)
-- Probar venta con stock disponible
-- ----------------------------------------------------------
-- Verificamos stock inicial del Producto 1
SELECT id_producto, nombre_producto, stock FROM dbo.Producto WHERE id_producto = 1;

-- Ejecutamos la transacción con datos válidos y cantidad menor al stock existente
EXEC dbo.sp_ProcesarVentaConPago
    @id_usuario = 1,
    @id_direccion = 1,
    @id_carrito = 1,
    @id_producto = 1,
    @cantidad = 2,
    @precioUnitario = 1500.00,
    @metodoPago = 'Tarjeta de Crédito',
    @comprobantePago = 'COMP-998811';

-- Verificación: Comprobar que se hayan creado las filas en Pedido, Detalle_pedido, Pago y se haya descontado stock
SELECT TOP 1 * FROM dbo.Pedido ORDER BY id_pedido DESC;
SELECT TOP 1 * FROM dbo.Detalle_pedido ORDER BY id_pedido DESC;
SELECT TOP 1 * FROM dbo.Pago ORDER BY id_pago DESC;
SELECT id_producto, nombre_producto, stock FROM dbo.Producto WHERE id_producto = 1;


-- ----------------------------------------------------------
-- CASO 2: TRANSACCIÓN FALLIDA (ROLLBACK)
-- Intentar comprar más unidades que las disponibles en stock
-- ----------------------------------------------------------
-- Intentamos pedir 99999 unidades (falla la validación y entra al CATCH)
EXEC dbo.sp_ProcesarVentaConPago
    @id_usuario = 1,
    @id_direccion = 1,
    @id_carrito = 1,
    @id_producto = 1,
    @cantidad = 99999, -- Cantidad intencionalmente excesiva
    @precioUnitario = 1500.00,
    @metodoPago = 'Efectivo',
    @comprobantePago = 'COMP-000000';

-- Verificación: Demostrar que NO se insertó ningún Pedido/Pago huérfano y el stock no sufrió modificaciones
SELECT TOP 1 * FROM dbo.Pedido ORDER BY id_pedido DESC;
SELECT id_producto, nombre_producto, stock FROM dbo.Producto WHERE id_producto = 1;
