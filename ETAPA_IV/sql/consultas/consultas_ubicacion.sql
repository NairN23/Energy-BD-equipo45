USE EnergyBD;
GO


-- Obtener las ciudades activas pertenecientes a una provincia específica (ejemplo: id_provincia = 1)
SELECT id_ciudad, nombre, CP 
FROM Ciudad 
WHERE id_provincia = 1;
GO


-- Obtener las direcciones completas con el nombre de su usuario, ciudad, código postal y provincia
SELECT 
    d.id_direccion,
    u.nombre_usuario,
    d.calle,
    d.numero,
    d.barrio,
    c.nombre AS ciudad,
    c.CP AS codigo_postal,
    p.nombre AS provincia
FROM Direccion d
INNER JOIN Usuario u ON d.id_usuario = u.id_usuario
INNER JOIN Ciudad c ON d.id_ciudad = c.id_ciudad
INNER JOIN Provincia p ON c.id_provincia = p.id_provincia;
GO


-- Cantidad total de direcciones registradas por cada ciudad para analizar la distribución geográfica
SELECT 
    c.nombre AS ciudad,
    p.nombre AS provincia,
    COUNT(d.id_direccion) AS total_direcciones
FROM Ciudad c
INNER JOIN Provincia p ON c.id_provincia = p.id_provincia
LEFT JOIN Direccion d ON c.id_ciudad = d.id_ciudad
GROUP BY c.id_ciudad, c.nombre, p.nombre
ORDER BY total_direcciones DESC;
GO


-- Reporte de volumen de entregas por localidad/provincia:
-- Unimos Provincia, Ciudad, Direccion y Pedido para contar la cantidad de pedidos concretados por ciudad y sumar el total facturado en cada una, filtrando solo aquellas ciudades con pedidos
SELECT 
    p.nombre AS provincia,
    c.nombre AS ciudad,
    COUNT(ped.id_pedido) AS total_pedidos_realizados,
    SUM(ped.total) AS monto_total_facturado
FROM Provincia p
INNER JOIN Ciudad c ON p.id_provincia = c.id_provincia
INNER JOIN Direccion d ON c.id_ciudad = d.id_ciudad
INNER JOIN Pedido ped ON d.id_direccion = ped.id_direccion
WHERE ped.estado NOT IN ('Cancelado')
GROUP BY p.id_provincia, p.nombre, c.id_ciudad, c.nombre
HAVING COUNT(ped.id_pedido) >= 1
ORDER BY monto_total_facturado DESC;
GO
