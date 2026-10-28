USE EnergyBD;

-- =========================================================================
-- CONSULTAS DE MENSAJES Y PAGOS
-- =========================================================================

-- Mensajes pendientes de lectura (leido = 0)
-- Distingue si el remitente es un usuario registrado o un visitante externo
SELECT 
    m.id_mensaje,
    m.fecha_envio,
    m.nombre AS remitente,
    m.correo,
    ISNULL(m.telefono, 'Sin telefono') AS telefono_contacto,
    m.asunto,
    m.contenido,
    CASE 
        WHEN m.id_usuario IS NOT NULL THEN 'Cliente Registrado'
        ELSE 'Visitante Externo'
    END AS tipo_remitente
FROM Mensaje m
WHERE m.leido = 0
ORDER BY m.fecha_envio ASC;

-- Volumen de consultas recibidas segun perfil de usuario en un rango de fechas
DECLARE @fecha_inicio DATETIME = '2026-09-01 00:00:00';
DECLARE @fecha_fin    DATETIME = '2026-09-30 23:59:59';

SELECT 
    ISNULL(tu.nombre_tipoUsuario, 'Visitante no registrado') AS perfil_remitente,
    COUNT(m.id_mensaje) AS total_mensajes,
    SUM(CASE WHEN m.leido = 0 THEN 1 ELSE 0 END) AS pendientes_lectura,
    SUM(CASE WHEN m.leido = 1 THEN 1 ELSE 0 END) AS respondidos_leidos
FROM Mensaje m
    LEFT JOIN Usuario u         ON m.id_usuario = u.id_usuario
    LEFT JOIN Tipo_usuario tu   ON u.id_tipoUsuario = tu.id_tipoUsuario
WHERE
    m.fecha_envio >= @fecha_inicio AND
    m.fecha_envio <= @fecha_fin
GROUP BY tu.nombre_tipoUsuario
ORDER BY total_mensajes DESC;

-- Prioridad de Atencion Post-Venta
-- Obtiene los clientes activos que tienen mensajes sin leer y que registran pedidos no cancelados,
-- mostrando la cantidad de compras y el monto acumulado para priorizar su atencion.
SELECT 
    u.id_usuario,
    u.nombre_usuario AS cliente,
    u.correo,
    COUNT(DISTINCT m.id_mensaje) AS mensajes_sin_leer,
    COUNT(DISTINCT ped.id_pedido) AS pedidos_realizados,
    SUM(ped.total) AS monto_historico_comprado
FROM Mensaje m
    INNER JOIN Usuario u    ON m.id_usuario = u.id_usuario AND u.activo = 1
    INNER JOIN Carrito c    ON u.id_usuario = c.id_usuario
    INNER JOIN Pedido ped   ON c.id_carrito = ped.id_carrito AND ped.estado <> 'Cancelado'
WHERE
    m.leido = 0
GROUP BY 
    u.id_usuario,
    u.nombre_usuario,
    u.correo
HAVING COUNT(DISTINCT ped.id_pedido) >= 1
ORDER BY monto_historico_comprado DESC;

-- Pagos pendientes o rechazados con datos y telefono del cliente
SELECT 
    pag.id_pago,
    pag.comprobante_pago,
    pag.metodoPago AS metodo_pago,
    pag.estado AS estado_pago,
    ped.id_pedido,
    ped.fecha_pedido,
    ped.estado AS estado_pedido,
    ped.total AS monto_operacion,
    u.nombre_usuario AS cliente,
    u.correo,
    t.nro_telefono AS telefono_registrado
FROM Pago pag
    INNER JOIN Pedido ped   ON pag.id_pedido = ped.id_pedido
    INNER JOIN Carrito c    ON ped.id_carrito = c.id_carrito
    INNER JOIN Usuario u    ON c.id_usuario = u.id_usuario
    LEFT JOIN Telefono t    ON u.id_usuario = t.id_usuario
WHERE 
    pag.estado IN ('Pendiente', 'Rechazado')
ORDER BY ped.fecha_pedido DESC;

-- Reporte Agregado de Recaudacion por Metodo de Pago en un rango de fechas:
DECLARE @desde DATE = '2026-09-01';
DECLARE @hasta DATE = '2026-09-30';

SELECT 
    pag.metodoPago AS metodo_pago,
    COUNT(DISTINCT pag.id_pago) AS cantidad_pagos_aprobados,
    SUM(dp.cantidad) AS unidades_abonadas,
    SUM(dp.cantidad * dp.precioUnitario) AS total_recaudado,
    CAST(AVG(dp.cantidad * dp.precioUnitario) AS DECIMAL(12,2)) AS promedio_por_renglon
FROM Pago pag
    INNER JOIN Pedido ped         ON pag.id_pedido = ped.id_pedido    AND ped.estado <> 'Cancelado'
    INNER JOIN Detalle_pedido dp  ON ped.id_pedido = dp.id_pedido
WHERE
    pag.estado = 'Aprobado' AND
    pag.fecha_acreditacion >= @desde AND
    pag.fecha_acreditacion < DATEADD(DAY, 1, @hasta)
GROUP BY pag.metodoPago
HAVING SUM(dp.cantidad * dp.precioUnitario) > 0
ORDER BY total_recaudado DESC;

-- Listar pedidos cuyos pagos estan pendientes/rechazados o cuyos clientes
-- enviaron mensajes consultando por pagos, comprobantes o estado de su pedido.
SELECT 
    u.id_usuario,
    u.nombre_usuario AS cliente,
    u.correo,
    ped.id_pedido,
    ped.estado AS estado_pedido,
    pag.comprobante_pago,
    pag.metodoPago AS metodo_pago,
    pag.estado AS estado_pago,
    ped.total AS monto_pedido
FROM Pago pag
    INNER JOIN Pedido ped   ON pag.id_pedido = ped.id_pedido
    INNER JOIN Carrito c    ON ped.id_carrito = c.id_carrito
    INNER JOIN Usuario u    ON c.id_usuario = u.id_usuario
WHERE
    pag.estado IN ('Pendiente', 'Rechazado') OR
    EXISTS (
        SELECT 1 
        FROM Mensaje m 
        WHERE
            m.id_usuario = u.id_usuario AND
            m.leido = 0 AND
            (
                m.asunto LIKE '%pago%' OR
                m.asunto LIKE '%Comprobante%' OR
                m.asunto LIKE '%pedido%'
            )
    )
ORDER BY ped.fecha_pedido DESC;
