USE EnergyBD;
GO

-- ==========================================================
-- 1. TABLA TIPO_USUARIO
-- ==========================================================
INSERT INTO Tipo_usuario (nombre_tipoUsuario) VALUES
('Administrador'),
('Cliente');
GO

-- ==========================================================
-- 2. TABLA USUARIO
-- ==========================================================
INSERT INTO Usuario (nombre_usuario, correo, contrasena, activo, id_tipoUsuario) VALUES
('Administrador', 'admin@energy.com', 'Admin1234', 1, 1),
('Ana Lopez', 'ana.lopez@gmail.com', 'Ana1234', 1, 2),
('Juan Perez', 'juan.perez@gmail.com', 'Juan1234', 1, 2),
('Maria Gomez', 'maria.gomez@gmail.com', 'Maria1234', 1, 2),
('Pedro Fernandez', 'pedro.fernandez@gmail.com', 'Pedro1234', 1, 2),
('Sofia Martinez', 'sofia.martinez@gmail.com', 'Sofia1234', 1, 2),
('Carlos Romero', 'carlos.romero@gmail.com', 'Carlos1234', 1, 2),
('Lucia Sanchez', 'lucia.sanchez@gmail.com', 'Lucia1234', 1, 2);
GO

-- ==========================================================
-- 3. TABLA TELEFONO
-- ==========================================================
INSERT INTO Telefono (nro_telefono, id_usuario) VALUES
('3794000001', 1),
('3794000002', 2),
('3794000003', 3),
('3794000004', 4),
('3794000005', 5),
('3794000006', 6),
('3794000007', 7),
('3794000008', 8);
GO

-- ==========================================================
-- 4. TABLA PROVINCIA Y CIUDAD
-- ==========================================================
INSERT INTO Provincia (nombre) VALUES
('Corrientes'),
('Chaco'),
('Misiones'),
('Santa Fe'),
('Buenos Aires'),
('Cordoba');
GO

INSERT INTO Ciudad (nombre, CP, id_provincia) VALUES
('Corrientes Capital', '3400', 1),
('Goya', '3450', 1),
('Paso de los Libres', '3230', 1),
('Resistencia', '3500', 2),
('Presidencia Roque Saenz Pena', '3700', 2),
('Posadas', '3300', 3),
('Rosario', '2000', 4),
('La Plata', '1900', 5),
('Mar del Plata', '7600', 5),
('Cordoba Capital', '5000', 6),
('Villa Carlos Paz', '5152', 6);
GO

-- ==========================================================
-- 5. TABLA DIRECCION
-- ==========================================================
INSERT INTO Direccion (calle, numero, barrio, id_usuario, id_ciudad) VALUES
('9 de Julio', '1250', 'Centro', 1, 1),
('San Martin', '830', 'Camba Cua', 2, 1),
('Av. Sarmiento', '450', 'Centro', 3, 4),
('Mitre', '210', 'Villa San Martin', 4, 4),
('Colon', '320', 'Centro', 5, 2),
('Av. Corrientes', '1500', 'Villa Sarita', 6, 6),
('Pellegrini', '640', 'Pichincha', 7, 7),
('Calle 7', '820', 'Plaza Paso', 8, 8),
('Av. Colon', '1420', 'Alberdi', 2, 10),
('Belgrano', '550', 'Centro', 3, 1);
GO

-- ==========================================================
-- 6. TABLA CATEGORIA
-- ==========================================================
INSERT INTO Categoria (nombre_categoria, descripcion, activa) VALUES
('Proteinas', 'Suplementos proteicos en polvo y barras', 1),
('Vitaminas y Minerales', 'Micronutrientes esenciales para el organismo', 1),
('Aminoacidos', 'BCAA, glutamina y otros aminoacidos', 1),
('Creatinas', 'Monohidrato de creatina y formulas avanzadas', 1),
('Pre-entrenos', 'Energizantes y potenciadores del rendimiento', 1),
('Combos', 'Packs promocionales y combos de productos', 1),
('Snacks Saludables', 'Barras, galletitas y snacks proteicos', 1),
('Accesorios', 'Shakers, toallas, cinturones y otros', 1),
('Quemadores de Grasa', 'Termogenicos y suplementos para control de peso', 1),
('Liquidacion', 'Productos en liquidacion y ofertas temporales', 0);
GO

-- ==========================================================
-- 7. TABLA PRODUCTO
-- ==========================================================
INSERT INTO Producto (nombre_producto, descripcion, precio, stock, destacado, activo, id_categoria) VALUES
('Whey Protein 1kg Vainilla', 'Proteina de suero concentrada, 24g de proteina por porcion', 45900.00, 40, 1, 1, 1),
('Whey Protein 1kg Chocolate', 'Proteina de suero concentrada sabor chocolate', 45900.00, 35, 1, 1, 1),
('Caseina Nocturna 900g', 'Proteina de absorcion lenta para la noche', 52300.00, 18, 0, 1, 1),
('Barra Proteica 60g', 'Barra con 20g de proteina, sabor cookies', 3200.00, 150, 0, 1, 1),
('Multivitaminico Diario 60 caps', 'Complejo de vitaminas y minerales esenciales', 18700.00, 60, 0, 1, 2),
('Vitamina C 1000mg 100 caps', 'Refuerzo del sistema inmunologico', 12400.00, 80, 0, 1, 2),
('Vitamina D3 2000UI 90 caps', 'Soporte oseo e inmunitario', 14900.00, 45, 0, 1, 2),
('BCAA 2:1:1 300g', 'Aminoacidos ramificados en polvo sabor limon', 29800.00, 25, 1, 1, 3),
('Glutamina 500g', 'L-glutamina pura para recuperacion muscular', 26500.00, 30, 0, 1, 3),
('Creatina Creapure 300g', 'Monohidrato de creatina de alta pureza', 33400.00, 50, 1, 1, 4),
('Creatina Monohidrato 1kg', 'Formato economico de creatina micronizada', 89900.00, 12, 0, 1, 4),
('Pre-Workout Explosivo 250g', 'Formula energizante con cafeina y beta-alanina', 38700.00, 22, 1, 1, 5),
('Oxido Nitrico 120 caps', 'Potenciador de la congestion muscular', 31200.00, 0, 0, 1, 5),
('Combo Iniciacion Fitness', 'Whey Protein 1kg + Creatina 300g + Multivitaminico', 92500.00, 15, 1, 1, 6),
('Combo Fuerza Total', 'Whey Protein 1kg + BCAA 300g + Pre-Workout 250g', 108400.00, 8, 1, 1, 6),
('Termogenico Clasico 60 caps', 'Producto discontinuado por el proveedor', 21000.00, 0, 0, 0, 9);
GO

-- ==========================================================
-- 8. TABLA CARRITO
-- ==========================================================
INSERT INTO Carrito (id_usuario) VALUES
(1), (2), (3), (4), (5), (6), (7), (8), (2), (3);
GO

-- ==========================================================
-- 9. TABLA PEDIDO
-- ==========================================================
INSERT INTO Pedido (total, fecha_pedido, estado, id_direccion, id_carrito) VALUES
(79300.00, '2026-09-01 10:30:00', 'Entregado',      1, 1),
(6400.00,  '2026-09-03 14:15:00', 'Entregado',      2, 2),
(92500.00, '2026-09-10 09:45:00', 'Enviado',        3, 3),
(12400.00, '2026-09-12 11:20:00', 'Pagado',         4, 4),
(108400.00,'2026-09-15 16:00:00', 'En Preparación', 5, 5),
(3200.00,  '2026-09-18 18:30:00', 'Pendiente',      6, 6),
(33400.00, '2026-09-20 08:00:00', 'Entregado',      7, 7),
(29800.00, '2026-09-22 12:10:00', 'Cancelado',      8, 8),
(18700.00, '2026-09-25 15:50:00', 'Pagado',         9, 9),
(45900.00, '2026-09-28 19:05:00', 'Pendiente',     10, 10);
GO

-- ==========================================================
-- 10. TABLA DETALLE_PEDIDO
-- ==========================================================
INSERT INTO Detalle_pedido (id_pedido, id_producto, cantidad, precioUnitario, subtotal) VALUES
(1, 1, 1, 45900.00, 45900.00), 
(1, 10, 1, 33400.00, 33400.00),
(2, 4, 2, 3200.00, 6400.00),  
(3, 14, 1, 92500.00, 92500.00),
(4, 6, 1, 12400.00, 12400.00), 
(5, 15, 1, 108400.00, 108400.00),
(6, 4, 1, 3200.00, 3200.00),  
(7, 10, 1, 33400.00, 33400.00),
(8, 8, 1, 29800.00, 29800.00), 
(9, 5, 1, 18700.00, 18700.00),
(10, 1, 1, 45900.00, 45900.00);
GO

-- ==========================================================
-- 11. TABLA PAGO
-- ==========================================================
INSERT INTO Pago (comprobantePago, fecha_Acreditacion, metodoPago, estado, id_pedido) VALUES
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
GO

-- ==========================================================
-- 12. TABLA MENSAJE
-- ==========================================================
INSERT INTO Mensaje (nombre, correo, asunto, contenido, fecha_envio, telefono, id_usuario) VALUES
('Ana Lopez', 'ana.lopez@gmail.com', 'Consulta sobre Whey Protein', 'Quisiera saber si tienen stock de sabor vainilla y fecha de vencimiento.', '2026-09-02 11:00:00', '3794000002', 2),
('Juan Perez', 'juan.perez@gmail.com', 'Demora en envio', 'Mi pedido todavia no llego, quisiera saber el numero de seguimiento.', '2026-09-11 16:30:00', '3794000003', 3),
('Carlos Romero', 'carlos.romero@gmail.com', 'Recomendacion de combo', 'Buenas tardes, que combo me recomiendan para empezar el gimnasio?', '2026-09-19 18:00:00', '3794000007', 7),
('Lucia Sanchez', 'lucia.sanchez@gmail.com', 'Problema con el pago', 'Intente pagar con transferencia pero figura rechazado.', '2026-09-23 09:15:00', '3794000008', 8),
('Martin Gomez', 'martin.gomez@gmail.com', 'Venta mayorista', 'Hacen envios al interior y precios por cantidad a gimnasios?', '2026-09-26 14:00:00', '3794112233', NULL),
('Valeria Ruiz', 'valeria.ruiz@hotmail.com', 'Consulta sobre creatina', 'La creatina Creapure viene con cuchara dosificadora?', '2026-09-29 10:45:00', '3794445566', NULL);
GO
