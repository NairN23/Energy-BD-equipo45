
-- Obtener los usuarios activos que son clientes

SELECT
    id_usuario,
    nombre_usuario,
    correo
FROM Usuario
WHERE activo = 1
AND id_tipoUsuario IN (
    SELECT id_tipoUsuario
    FROM Tipo_usuario
    WHERE nombre_tipoUsuario = 'Cliente'
);

-- Obtener usuarios que tienen telefono registrado

SELECT
    u.id_usuario,
    u.nombre_usuario,
    u.correo
FROM Usuario u
WHERE EXISTS (
    SELECT 1
    FROM Telefono t
    WHERE t.id_usuario = u.id_usuario
);

-- Obtener usuarios que no realizaron pedidos

SELECT
    u.id_usuario,
    u.nombre_usuario,
    u.correo
FROM Usuario u
WHERE NOT EXISTS (
    SELECT 1
    FROM Carrito c
    INNER JOIN Pedido p
        ON c.id_carrito = p.id_carrito
    WHERE c.id_usuario = u.id_usuario
);

-- Obtener clientes activos con mas de un pedido

SELECT
    u.id_usuario,
    u.nombre_usuario,
    tu.nombre_tipoUsuario,
    COUNT(p.id_pedido) AS cantidad_pedidos
FROM Usuario u
INNER JOIN Tipo_usuario tu
    ON u.id_tipoUsuario = tu.id_tipoUsuario
INNER JOIN Carrito c
    ON u.id_usuario = c.id_usuario
INNER JOIN Pedido p
    ON c.id_carrito = p.id_carrito
WHERE u.activo = 1
AND tu.nombre_tipoUsuario = 'Cliente'
GROUP BY
    u.id_usuario,
    u.nombre_usuario,
    tu.nombre_tipoUsuario
HAVING COUNT(p.id_pedido) > 1
ORDER BY cantidad_pedidos DESC;
