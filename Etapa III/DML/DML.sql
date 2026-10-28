USE EnergyBD;
GO

-- =========================================================
-- 1. INSERTAR TIPO_USUARIO
-- =========================================================
INSERT INTO Tipo_usuario (nombre_tipoUsuario)
VALUES
('Administrador'),
('Cliente');

SELECT * FROM Tipo_usuario;

-- =========================================================
-- 2. INSERTAR USUARIO
-- =========================================================
INSERT INTO Usuario (nombre_usuario, correo, contrasenia, id_tipoUsuario)
VALUES
('Administrador', 'admin@energy.com', 'Admin1234', 1),
('Ana Lopez', 'ana.lopez@gmail.com', 'Ana1234', 2),
('Juan Perez', 'juan.perez@gmail.com', 'Juan1234', 2),
('Maria Gomez', 'maria.gomez@gmail.com', 'Maria1234', 2),
('Pedro Fernandez', 'pedro.fernandez@gmail.com', 'Pedro1234', 2),
('Sofia Martinez', 'sofia.martinez@gmail.com', 'Sofia1234', 2),
('Carlos Romero', 'carlos.romero@gmail.com', 'Carlos1234', 2),
('Lucia Sanchez', 'lucia.sanchez@gmail.com', 'Lucia1234', 2);

SELECT * FROM Usuario;

-- =========================================================
-- 3. INSERTAR TELEFONO
-- =========================================================
INSERT INTO Telefono (nro_telefono, id_usuario)
VALUES
('3794000001', 1),
('3794000002', 2),
('3794000003', 3),
('3794000004', 4),
('3794000005', 5),
('3794000006', 6),
('3794000007', 7),
('3794000008', 8);

SELECT * FROM Telefono;

-- =========================================================
-- 4. INSERTAR MENSAJE
-- =========================================================
INSERT INTO Mensaje (nombre, correo, asunto, contenido, fecha_envio, telefono, id_usuario)
VALUES
('Ana Lopez', 'ana.lopez@gmail.com', 'Consulta de producto',
'Quisiera saber si tienen stock disponible.', '2026-09-29 18:10:00', '3794000002', 2),

('Juan Perez', 'juan.perez@gmail.com', 'Consulta de pedido',
'Quisiera conocer el estado de mi pedido.', '2026-09-29 18:20:00', '3794000003', 3),

('Maria Gomez', 'maria.gomez@gmail.com', 'Forma de pago',
'Quisiera consultar las formas de pago disponibles.', '2026-09-29 18:30:00', '3794000004', 4),

('Pedro Fernandez', 'pedro.fernandez@gmail.com', 'Envio',
'Quisiera saber cuanto demora el envio.', '2026-09-29 18:40:00', '3794000005', 5),

('Sofia Martinez', 'sofia.martinez@gmail.com', 'Stock',
'Quisiera consultar por un producto.', '2026-09-29 18:50:00', '3794000006', 6),

('Carlos Romero', 'carlos.romero@gmail.com', 'Comprobante',
'Necesito consultar sobre mi comprobante.', '2026-09-29 19:00:00', '3794000007', 7),

('Martin Diaz', 'martin@gmail.com', 'Consulta general',
'Quisiera recibir informacion sobre los productos.', '2026-09-29 19:10:00', '3794111111', NULL),

('Laura Garcia', 'laura@gmail.com', 'Envios',
'Quisiera consultar por los envios disponibles.', '2026-09-29 19:20:00', '3794222222', NULL);

SELECT * FROM Mensaje;

-- =========================================================
-- 5. INSERTAR CATEGORIA
-- =========================================================
INSERT INTO Categoria (nombre_categoria, descripcion)
VALUES
('Proteinas', 'Suplementos proteicos en polvo y barras'),
('Vitaminas', 'Complejos multivitaminicos y minerales'),
('Aminoacidos', 'BCAA, glutamina y aminoacidos esenciales'),
('Creatinas', 'Monohidrato de creatina y derivados'),
('Pre-entrenamiento', 'Energizantes y potenciadores de rendimiento'),
('Combos', 'Packs promocionales de varios productos'),
('Ganadores de peso', 'Suplementos hipercaloricos para aumento de masa'),
('Colagenos', 'Colageno hidrolizado y suplementos articulares'),
('Accesorios', 'Shakers, dosificadores y articulos de entrenamiento');

-- Categoria inactiva
INSERT INTO Categoria (nombre_categoria, descripcion, activa)
VALUES ('Quemadores', 'Linea discontinuada', 0);

SELECT * FROM Categoria;

-- =========================================================
-- 6. INSERTAR PRODUCTO
-- =========================================================
INSERT INTO Producto (nombre_producto, descripcion, precio, stock, destacado, id_categoria)
VALUES
('Whey Protein 1kg Vainilla', 'Proteina de suero concentrada, 24g de proteina por porcion', 45900.00, 40, 1, 1),
('Whey Protein 1kg Chocolate', 'Proteina de suero concentrada sabor chocolate', 45900.00, 35, 1, 1),
('Caseina Nocturna 900g', 'Proteina de absorcion lenta para la noche', 52300.00, 18, 0, 1),
('Barra Proteica 60g', 'Barra con 20g de proteina, sabor cookies', 3200.00, 150, 0, 1),
('Multivitaminico Diario 60 caps', 'Complejo de vitaminas y minerales esenciales', 18700.00, 60, 0, 2),
('Vitamina C 1000mg 100 caps', 'Refuerzo del sistema inmunologico', 12400.00, 80, 0, 2),
('Vitamina D3 2000UI 90 caps', 'Soporte oseo e inmunitario', 14900.00, 45, 0, 2),
('BCAA 2:1:1 300g', 'Aminoacidos ramificados en polvo sabor limon', 29800.00, 25, 1, 3),
('Glutamina 500g', 'L-glutamina pura para recuperacion muscular', 26500.00, 30, 0, 3),
('Creatina Monohidrato 300g', 'Creatina micronizada sin sabor', 33400.00, 50, 1, 4),
('Creatina Monohidrato 1kg', 'Formato economico de creatina micronizada', 89900.00, 12, 0, 4),
('Pre-Workout Explosivo 250g', 'Formula energizante con cafeina y beta-alanina', 38700.00, 22, 1, 5),
('Oxido Nitrico 120 caps', 'Potenciador de la congestion muscular', 31200.00, 0, 0, 5),
('Combo Iniciacion Fitness', 'Whey Protein 1kg + Creatina 300g + Multivitaminico', 92500.00, 15, 1, 6),
('Combo Fuerza Total', 'Whey Protein 1kg + BCAA 300g + Pre-Workout 250g', 108400.00, 8, 1, 6);

-- Producto inactivo
INSERT INTO Producto (nombre_producto, descripcion, precio, stock, activo, id_categoria)
VALUES
('Termogenico Clasico 60 caps', 'Producto discontinuado por el proveedor', 21000.00, 0, 0, 10);

SELECT * FROM Producto;

-- =========================================================
-- 7. INSERTAR PROVINCIA, CIUDAD, DIRECCION
-- =========================================================
INSERT INTO Provincia (nombre)
VALUES
('Corrientes'),
('Chaco'),
('Misiones'),
('Buenos Aires'),
('Santa Fe'),
('Cordoba');

INSERT INTO Ciudad (nombre, CP, id_provincia)
VALUES
('Corrientes Capital', '3400', 1),
('Goya', '3450', 1),
('Paso de los Libres', '3230', 1),
('Resistencia', '3500', 2),
('Presidencia Roque Saenz Pena', '3700', 2),
('Posadas', '3300', 3),
('Puerto Iguazu', '3370', 3),
('La Plata', '1900', 4),
('Mar del Plata', '7600', 4),
('Rosario', '2000', 5),
('Cordoba Capital', '5000', 6);

INSERT INTO Direccion (calle, numero, barrio, id_usuario, id_ciudad)
VALUES
('Av. 3 de Abril', '1250', 'Centro', 1, 1),
('Junin', '850', 'Deportes', 1, 1),
('Av. Sarmiento', '450', 'Villa San Martin', 2, 4),
('Felix de Azara', '1620', 'Centro', 3, 6),
('Calle 7', '820', 'Plaza Paso', 2, 8),
('Av. Colon', '1420', 'Alberdi', 3, 11);

-- =========================================================
-- 8. INSERTAR CARRITO
-- =========================================================
INSERT INTO Carrito (id_usuario) VALUES
(1),  -- Carrito 1
(2),  -- Carrito 2
(3),  -- Carrito 3
(4),  -- Carrito 4
(5),  -- Carrito 5
(6),  -- Carrito 6
(7),  -- Carrito 7
(8),  -- Carrito 8
(2),  -- Carrito 9
(3);  -- Carrito 10

SELECT * FROM Carrito;

-- =========================================================
-- 9. INSERTAR PEDIDO
-- =========================================================
INSERT INTO Pedido (total, fecha_pedido, estado, id_direccion, id_carrito) VALUES
(15400.50, '2026-09-01 10:30:00', 'Entregado',      1, 1),
(8500.00,  '2026-09-03 14:15:00', 'Entregado',      2, 2),
(23100.00, '2026-09-10 09:45:00', 'Enviado',        3, 3),
(4200.75,  '2026-09-12 11:20:00', 'Pagado',         4, 4),
(99900.00, '2026-09-15 16:00:00', 'En Preparación', 5, 5),
(1250.00,  '2026-09-18 18:30:00', 'Pendiente',      6, 6),
(34000.00, '2026-09-20 08:00:00', 'Entregado',      1, 7),
(6700.00,  '2026-09-22 12:10:00', 'Cancelado',      2, 8),
(18900.25, '2026-09-25 15:50:00', 'Pagado',         3, 9),
(51200.00, '2026-09-28 19:05:00', 'Pendiente',      4, 10);

SELECT * FROM Pedido;

-- =========================================================
-- 10. INSERTAR DETALLE_PEDIDO
-- =========================================================
INSERT INTO Detalle_pedido (id_pedido, id_producto, cantidad, precioUnitario) VALUES
(1, 1, 1, 45900.00), 
(1, 10, 1, 33400.00),
(2, 4, 2, 3200.00),  
(3, 14, 1, 92500.00),
(4, 6, 1, 12400.00), 
(5, 15, 1, 108400.00),
(6, 4, 1, 3200.00),  
(7, 10, 1, 33400.00),
(8, 8, 1, 29800.00), 
(9, 5, 1, 18700.00); 

SELECT * FROM Detalle_pedido;

-- =========================================================
-- 11. INSERTAR PAGO
-- =========================================================
INSERT INTO Pago (comprobante_pago, fecha_acreditacion, metodoPago, estado, id_pedido) VALUES
('CMP-20260901-001', '2026-09-01 10:35:00', 'Tarjeta Credito', 'Aprobado', 1),
('CMP-20260903-002', '2026-09-03 14:20:00', 'Transferencia',   'Aprobado', 2),
('CMP-20260910-003', '2026-09-10 09:50:00', 'Mercado Pago',    'Aprobado', 3),
('CMP-20260912-004', '2026-09-12 11:25:00', 'Tarjeta Debito',  'Aprobado', 4),
('CMP-20260915-005', '2026-09-15 16:10:00', 'Transferencia',   'Aprobado', 5),
('CMP-20260918-006', '2026-09-18 18:35:00', 'Mercado Pago',    'Pendiente', 6),
('CMP-20260920-007', '2026-09-20 08:05:00', 'Tarjeta Credito', 'Aprobado', 7),
('CMP-20260922-008', '2026-09-22 12:15:00', 'Efectivo',        'Rechazado', 8),
('CMP-20260925-009', '2026-09-25 15:55:00', 'Tarjeta Credito', 'Aprobado', 9),
('CMP-20260928-010', '2026-09-28 19:10:00', 'Transferencia',   'Pendiente', 10);

SELECT * FROM Pago;