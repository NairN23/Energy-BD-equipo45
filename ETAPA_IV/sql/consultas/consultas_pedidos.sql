USE EnergyBD;
GO

-- CONSULTAS DE PEDIDOS
-- Integrante: Melina Figuerola

-- Consulta de pedidos que se encuentran pendientes

SELECT
    id_pedido,
    fecha_pedido,
    total,
    estado,
    id_direccion,
    id_carrito
FROM Pedido
WHERE estado = 'Pendiente';
GO


-- Consulta de pedidos junto con el nombre del usuario que realizo la compra

SELECT
    ped.id_pedido,
    u.nombre_usuario,
    ped.fecha_pedido,
    ped.total,
    ped.estado
FROM Pedido ped
INNER JOIN Carrito c
    ON ped.id_carrito = c.id_carrito
INNER JOIN Usuario u
    ON c.id_usuario = u.id_usuario;
GO

-- Consulta del total gastado por cada usuario

SELECT
    u.id_usuario,
    u.nombre_usuario,
    SUM(ped.total) AS total_gastado
FROM Usuario u
INNER JOIN Carrito c
    ON u.id_usuario = c.id_usuario
INNER JOIN Pedido ped
    ON c.id_carrito = ped.id_carrito
WHERE ped.estado <> 'Cancelado'
GROUP BY
    u.id_usuario,
    u.nombre_usuario
ORDER BY total_gastado DESC;
GO

-- Consulta avanzada: usuarios que realizaron mas de un pedido

SELECT
    u.id_usuario,
    u.nombre_usuario,
    COUNT(ped.id_pedido) AS cantidad_pedidos,
    SUM(ped.total) AS total_gastado
FROM Usuario u
INNER JOIN Carrito c
    ON u.id_usuario = c.id_usuario
INNER JOIN Pedido ped
    ON c.id_carrito = ped.id_carrito
WHERE ped.estado <> 'Cancelado'
GROUP BY
    u.id_usuario,
    u.nombre_usuario
HAVING COUNT(ped.id_pedido) > 1
ORDER BY cantidad_pedidos DESC;
GO

-- Comprobante de un pedido:
-- muestra encabezado, detalle, subtotal por producto y total de la compra

DECLARE @id_pedido INT = 1;

SELECT
    ped.id_pedido AS nro_pedido,
    ped.fecha_pedido,
    u.nombre_usuario AS cliente,
    ped.estado,

    p.nombre_producto,
    dp.cantidad,
    dp.precioUnitario AS precio_unitario,

    -- Subtotal de cada producto
    dp.cantidad * dp.precioUnitario AS subtotal,

    -- Total completo del pedido
    SUM(dp.cantidad * dp.precioUnitario)
        OVER (PARTITION BY ped.id_pedido) AS total_pedido

FROM Pedido ped

INNER JOIN Carrito c
    ON ped.id_carrito = c.id_carrito

INNER JOIN Usuario u
    ON c.id_usuario = u.id_usuario

INNER JOIN Detalle_pedido dp
    ON ped.id_pedido = dp.id_pedido

INNER JOIN Producto p
    ON dp.id_producto = p.id_producto

WHERE ped.id_pedido = @id_pedido

ORDER BY p.nombre_producto;
GO


-- Reporte de ventas por categoria dentro de un rango de fechas

DECLARE @fecha_desde DATE = '2026-09-01';
DECLARE @fecha_hasta DATE = '2026-09-30';

SELECT
    c.id_categoria,
    c.nombre_categoria,

    COUNT(DISTINCT ped.id_pedido) AS cantidad_pedidos,

    SUM(dp.cantidad) AS unidades_vendidas,

    SUM(dp.cantidad * dp.precioUnitario) AS total_vendido

FROM Pedido ped

INNER JOIN Detalle_pedido dp
    ON ped.id_pedido = dp.id_pedido

INNER JOIN Producto p
    ON dp.id_producto = p.id_producto

INNER JOIN Categoria c
    ON p.id_categoria = c.id_categoria

WHERE ped.fecha_pedido >= @fecha_desde
  AND ped.fecha_pedido < DATEADD(DAY, 1, @fecha_hasta)
  AND ped.estado <> 'Cancelado'

GROUP BY
    c.id_categoria,
    c.nombre_categoria

ORDER BY total_vendido DESC;
GO 