USE EnergyBD;
GO
-- =========================================================================
-- ETAPA V - TEMA TÉCNICO: TRIGGERS DE AUDITORÍA Y CONTROL DE OPERACIONES
-- Integrante: Daniela Mormina
-- Base de Datos: EnergyBD (Microsoft SQL Server 2022 Express)
--
-- GUÍA DIDÁCTICA DE CONCEPTOS:
-- 1. ¿Qué es un TRIGGER?
--    Es un bloque de código SQL que el motor ejecuta automáticamente ante un
--    evento de manipulación de datos (INSERT, UPDATE o DELETE). El usuario
--    no lo llama con "EXEC"; el motor lo dispara de forma obligatoria.
--
-- 2. ¿Qué son las tablas virtuales "INSERTED" y "DELETED"?
--    Son tablas temporales residentes en memoria que SQL Server crea durante
--    la ejecución del trigger:
--    * INSERT: La tabla 'inserted' contiene la nueva fila que se está agregando.
--              La tabla 'deleted' está vacía.
--    * DELETE: La tabla 'deleted' contiene la fila que se intenta o acaba de borrar.
--              La tabla 'inserted' está vacía.
--    * UPDATE: SQL Server lo procesa como un borrado seguido de una inserción.
--              'deleted' contiene los valores viejos (antes del cambio).
--              'inserted' contiene los valores nuevos (después del cambio).
--
-- 3. ¿Diferencia entre AFTER e INSTEAD OF?
--    * AFTER: Se ejecuta DESPUÉS de que la operación se aplicó en la tabla.
--             Ideal para AUDITORÍA (guardar historial de cambios).
--    * INSTEAD OF: Se ejecuta EN LUGAR DE la operación nativa, interceptándola.
--             Ideal para CONTROL y REGLAS DE NEGOCIO (ej. transformar un borrado
--             físico en borrado lógico o bloquear una eliminación con error).
-- =========================================================================

-- =========================================================================
-- PARTE 1: TABLA CENTRALIZADA DE AUDITORÍA
-- =========================================================================
-- En lugar de crear múltiples tablas auxiliares dispersas, se utiliza una
-- estructura centralizada que registra la trazabilidad de cualquier entidad.
IF OBJECT_ID('dbo.Auditoria_Sistema', 'U') IS NOT NULL
    DROP TABLE dbo.Auditoria_Sistema;
GO

CREATE TABLE dbo.Auditoria_Sistema (
    id_auditoria INT IDENTITY(1,1) NOT NULL,
    tabla_afectada VARCHAR(50) NOT NULL,          -- Nombre de la tabla modificada ('Producto', 'Usuario', etc.)
    operacion VARCHAR(20) NOT NULL,               -- Tipo de acción: 'INSERT', 'UPDATE', 'SOFT_DELETE'
    id_registro VARCHAR(50) NOT NULL,             -- Identificador del registro modificado (ID del producto, etc.)
    campo_modificado VARCHAR(50) NOT NULL,        -- Atributo sensible auditado ('PRECIO', 'STOCK', 'ESTADO', etc.)
    valor_anterior VARCHAR(MAX) NULL,             -- Dato histórico antes de la modificación
    valor_nuevo VARCHAR(MAX) NULL,                -- Dato nuevo posterior a la modificación
    fecha DATETIME NOT NULL DEFAULT GETDATE(),    -- Fecha y hora exacta provista por el servidor
    usuario VARCHAR(100) NOT NULL DEFAULT SYSTEM_USER, -- Usuario de base de datos que ejecutó la sentencia
    terminal VARCHAR(100) NULL DEFAULT HOST_NAME(),    -- Nombre de la PC o terminal desde donde se conectó

    CONSTRAINT PK_Auditoria_Sistema PRIMARY KEY (id_auditoria)
);
GO

-- =========================================================================
-- PARTE 2: TRIGGERS DE AUDITORÍA DE MODIFICACIONES (AFTER INSERT, UPDATE)
-- =========================================================================
-- Justificación técnica:
-- Se utiliza la función IF UPDATE(columna) para evaluar mapas de bits en memoria.
-- Esto evita "sobre-auditar" columnas no críticas (como descripciones largas)
-- y protege el rendimiento del motor (I/O en disco), auditando solo atributos
-- con impacto financiero o logístico directo.

-- -------------------------------------------------------------------------
-- 2.1 TRIGGER EN PRODUCTO: Alta de catálogo y variaciones de Precio/Stock
-- -------------------------------------------------------------------------
CREATE OR ALTER TRIGGER dbo.trg_Auditoria_Producto_InsertUpdate
ON dbo.Producto
AFTER INSERT, UPDATE
AS
BEGIN
    -- SET NOCOUNT ON evita que se envíen mensajes de recuento de filas al cliente, mejorando la velocidad
    SET NOCOUNT ON;
    -- A) CASO INSERT: Si la tabla 'deleted' está vacía, se trata de una inserción pura
    IF NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.Auditoria_Sistema (
            tabla_afectada, operacion, id_registro, campo_modificado,
            valor_anterior, valor_nuevo, fecha, usuario, terminal
        )
        SELECT 
            'Producto',
            'INSERT',
            CAST(i.id_producto AS VARCHAR(50)),
            'ALTA_PRODUCTO',
            NULL,
            CONCAT('Nombre: ', i.nombre_producto, ' | Precio: $', i.precio, ' | Stock: ', i.stock, ' | Activo: ', i.activo),
            GETDATE(),
            SYSTEM_USER,
            HOST_NAME()
        FROM inserted i;

        RETURN; -- Finaliza el trigger para el caso INSERT
    END;
    -- B) CASO UPDATE EN PRECIO: Evalúa si la columna 'precio' fue modificada
    IF UPDATE(precio)
    BEGIN
        INSERT INTO dbo.Auditoria_Sistema (
            tabla_afectada, operacion, id_registro, campo_modificado,
            valor_anterior, valor_nuevo, fecha, usuario, terminal
        )
        SELECT 
            'Producto',
            'UPDATE',
            CAST(i.id_producto AS VARCHAR(50)),
            'PRECIO',
            CONCAT('$', CAST(d.precio AS VARCHAR(20))),  -- Valor que tenía antes (desde deleted)
            CONCAT('$', CAST(i.precio AS VARCHAR(20))),  -- Valor nuevo modificado (desde inserted)
            GETDATE(),
            SYSTEM_USER,
            HOST_NAME()
        FROM inserted i
        INNER JOIN deleted d ON i.id_producto = d.id_producto
        WHERE i.precio <> d.precio; -- Filtro de seguridad: solo si hubo un cambio numérico real
    END;
    -- C) CASO UPDATE EN STOCK: Evalúa si variaron las existencias físicas
    IF UPDATE(stock)
    BEGIN
        INSERT INTO dbo.Auditoria_Sistema (
            tabla_afectada, operacion, id_registro, campo_modificado,
            valor_anterior, valor_nuevo, fecha, usuario, terminal
        )
        SELECT 
            'Producto',
            'UPDATE',
            CAST(i.id_producto AS VARCHAR(50)),
            'STOCK',
            CAST(d.stock AS VARCHAR(20)),
            CAST(i.stock AS VARCHAR(20)),
            GETDATE(),
            SYSTEM_USER,
            HOST_NAME()
        FROM inserted i
        INNER JOIN deleted d ON i.id_producto = d.id_producto
        WHERE i.stock <> d.stock;
    END;
END;
GO

-- -------------------------------------------------------------------------
-- 2.2 TRIGGER EN PEDIDO: Ciclo de vida de la orden (Estado y Monto Total)
-- -------------------------------------------------------------------------
CREATE OR ALTER TRIGGER dbo.trg_Auditoria_Pedido_Update
ON dbo.Pedido
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- A) Auditar transición de estados ('Pendiente' -> 'Pagado' -> 'Enviado', etc.)
    IF UPDATE(estado)
    BEGIN
        INSERT INTO dbo.Auditoria_Sistema (
            tabla_afectada, operacion, id_registro, campo_modificado,
            valor_anterior, valor_nuevo, fecha, usuario, terminal
        )
        SELECT 
            'Pedido',
            'UPDATE',
            CAST(i.id_pedido AS VARCHAR(50)),
            'ESTADO_PEDIDO',
            d.estado,
            i.estado,
            GETDATE(),
            SYSTEM_USER,
            HOST_NAME()
        FROM inserted i
        INNER JOIN deleted d ON i.id_pedido = d.id_pedido
        WHERE i.estado <> d.estado;
    END;
    -- B) Auditar variaciones en el monto total de la venta
    IF UPDATE(total)
    BEGIN
        INSERT INTO dbo.Auditoria_Sistema (
            tabla_afectada, operacion, id_registro, campo_modificado,
            valor_anterior, valor_nuevo, fecha, usuario, terminal
        )
        SELECT 
            'Pedido',
            'UPDATE',
            CAST(i.id_pedido AS VARCHAR(50)),
            'TOTAL_PEDIDO',
            CONCAT('$', CAST(d.total AS VARCHAR(20))),
            CONCAT('$', CAST(i.total AS VARCHAR(20))),
            GETDATE(),
            SYSTEM_USER,
            HOST_NAME()
        FROM inserted i
        INNER JOIN deleted d ON i.id_pedido = d.id_pedido
        WHERE i.total <> d.total;
    END;
END;
GO

-- -------------------------------------------------------------------------
-- 2.3 TRIGGER EN USUARIO: Modificación de correo o perfil de acceso
-- -------------------------------------------------------------------------
CREATE OR ALTER TRIGGER dbo.trg_Auditoria_Usuario_Update
ON dbo.Usuario
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- A) Auditar cambio de correo electrónico (identificador principal de acceso)
    IF UPDATE(correo)
    BEGIN
        INSERT INTO dbo.Auditoria_Sistema (
            tabla_afectada, operacion, id_registro, campo_modificado,
            valor_anterior, valor_nuevo, fecha, usuario, terminal
        )
        SELECT 
            'Usuario',
            'UPDATE',
            CAST(i.id_usuario AS VARCHAR(50)),
            'CORREO_ELECTRONICO',
            d.correo,
            i.correo,
            GETDATE(),
            SYSTEM_USER,
            HOST_NAME()
        FROM inserted i
        INNER JOIN deleted d ON i.id_usuario = d.id_usuario
        WHERE i.correo <> d.correo;
    END;
    -- B) Auditar cambio de rol o tipo de usuario (ej. Cliente -> Administrador)
    IF UPDATE(id_tipoUsuario)
    BEGIN
        INSERT INTO dbo.Auditoria_Sistema (
            tabla_afectada, operacion, id_registro, campo_modificado,
            valor_anterior, valor_nuevo, fecha, usuario, terminal
        )
        SELECT 
            'Usuario',
            'UPDATE',
            CAST(i.id_usuario AS VARCHAR(50)),
            'TIPO_USUARIO',
            CAST(d.id_tipoUsuario AS VARCHAR(10)),
            CAST(i.id_tipoUsuario AS VARCHAR(10)),
            GETDATE(),
            SYSTEM_USER,
            HOST_NAME()
        FROM inserted i
        INNER JOIN deleted d ON i.id_usuario = d.id_usuario
        WHERE i.id_tipoUsuario <> d.id_tipoUsuario;
    END;
END;
GO

-- =========================================================================
-- PARTE 3: ESTRATEGIA DUAL ANTE EL EVENTO DELETE
-- =========================================================================
-- En un sistema relacional maduro, la eliminación de datos no se maneja
-- de forma genérica. Se divide estrictamente en dos comportamientos:
--
-- GRUPO A: Tablas con atributo 'activo/a' (Producto, Usuario, Categoria)
--          Regla de Negocio: Conservar datos maestros. El DELETE se intercepta
--          mediante INSTEAD OF y se transforma en UPDATE activo = 0 (Soft Delete).
--
-- GRUPO B: Tablas transaccionales sin 'activo' (Pedido, Pago, Detalle_pedido)
--          Regla de Negocio: Inmutabilidad contable. El DELETE físico se bloquea
--          con error y se fuerza un ROLLBACK TRANSACTION para abortar la acción.

-- -------------------------------------------------------------------------
-- 3.1 TABLAS CON BORRADO LÓGICO (INSTEAD OF DELETE -> SOFT DELETE)
-- -------------------------------------------------------------------------
-- A) PRODUCTO: Si intentan borrar un producto, pasa a activo = 0
CREATE OR ALTER TRIGGER dbo.trg_Producto_SoftDelete
ON dbo.Producto
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- 1. Actualizamos la tabla física aplicando el borrado lógico
    UPDATE p
    SET p.activo = 0
    FROM dbo.Producto p
    INNER JOIN deleted d ON p.id_producto = d.id_producto;
    -- 2. Registramos la baja lógica en la auditoría del sistema
    INSERT INTO dbo.Auditoria_Sistema (
        tabla_afectada, operacion, id_registro, campo_modificado,
        valor_anterior, valor_nuevo, fecha, usuario, terminal
    )
    SELECT 
        'Producto',
        'SOFT_DELETE',
        CAST(d.id_producto AS VARCHAR(50)),
        'ESTADO_ACTIVO',
        CONCAT('activo = ', CAST(d.activo AS VARCHAR(5))),
        'activo = 0',
        GETDATE(),
        SYSTEM_USER,
        HOST_NAME()
    FROM deleted d;

    PRINT 'Aviso: La tabla Producto opera con borrado lógico. El/los registros fueron desactivados (activo = 0) y el evento fue auditado con éxito.';
END;
GO
-- B) USUARIO: Si intentan borrar un usuario, pasa a activo = 0 (cumple RN01 Punto 4)
CREATE OR ALTER TRIGGER dbo.trg_Usuario_SoftDelete
ON dbo.Usuario
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- 1. Actualizamos a activo = 0 para preservar la integridad de pedidos y carritos
    UPDATE u
    SET u.activo = 0
    FROM dbo.Usuario u
    INNER JOIN deleted d ON u.id_usuario = d.id_usuario;
    -- 2. Auditamos la desactivación de la cuenta
    INSERT INTO dbo.Auditoria_Sistema (
        tabla_afectada, operacion, id_registro, campo_modificado,
        valor_anterior, valor_nuevo, fecha, usuario, terminal
    )
    SELECT 
        'Usuario',
        'SOFT_DELETE',
        CAST(d.id_usuario AS VARCHAR(50)),
        'ESTADO_ACTIVO',
        CONCAT('activo = ', CAST(d.activo AS VARCHAR(5))),
        'activo = 0',
        GETDATE(),
        SYSTEM_USER,
        HOST_NAME()
    FROM deleted d;

    PRINT 'Aviso: La tabla Usuario opera con borrado lógico para preservar el historial de compras. La cuenta fue desactivada (activo = 0) y auditada.';
END;
GO
-- C) CATEGORIA: Si intentan borrar una categoría, pasa a activa = 0 (cumple RN02 Punto 5)
CREATE OR ALTER TRIGGER dbo.trg_Categoria_SoftDelete
ON dbo.Categoria
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- 1. Actualizamos a activa = 0
    UPDATE c
    SET c.activa = 0
    FROM dbo.Categoria c
    INNER JOIN deleted d ON c.id_categoria = d.id_categoria;
    -- 2. Auditamos la desactivación de la categoría
    INSERT INTO dbo.Auditoria_Sistema (
        tabla_afectada, operacion, id_registro, campo_modificado,
        valor_anterior, valor_nuevo, fecha, usuario, terminal
    )
    SELECT 
        'Categoria',
        'SOFT_DELETE',
        CAST(d.id_categoria AS VARCHAR(50)),
        'ESTADO_ACTIVA',
        CONCAT('activa = ', CAST(d.activa AS VARCHAR(5))),
        'activa = 0',
        GETDATE(),
        SYSTEM_USER,
        HOST_NAME()
    FROM deleted d;

    PRINT 'Aviso: La tabla Categoria opera con borrado lógico. La categoría fue desactivada (activa = 0) y auditada con éxito.';
END;
GO

-- -------------------------------------------------------------------------
-- 3.2 TABLAS TRANSACCIONALES SIN BORRADO LÓGICO (INSTEAD OF DELETE -> BLOQUEO Y ROLLBACK)
-- -------------------------------------------------------------------------
-- A) PEDIDO: Se prohíbe terminantemente la eliminación física de comprobantes de venta
CREATE OR ALTER TRIGGER dbo.trg_Pedido_PrevenirEliminacion
ON dbo.Pedido
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- RAISERROR emite el mensaje de error personalizado con nivel de severidad 16 (error de usuario)
    RAISERROR (
        'Operación cancelada: No está permitida la eliminación física de registros en la tabla Pedido por motivos de integridad transaccional y contable. Para anular una venta debe actualizarse su estado a ''Cancelado''.',
        16,
        1
    );
    -- Aborta la transacción actual para que ninguna instrucción del lote tenga efecto
    ROLLBACK TRANSACTION;
END;
GO
-- B) PAGO: Se prohíbe eliminar registros de transacciones bancarias o pasarelas de pago
CREATE OR ALTER TRIGGER dbo.trg_Pago_PrevenirEliminacion
ON dbo.Pago
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    RAISERROR (
        'Operación cancelada: No está permitida la eliminación física de comprobantes en la tabla Pago. Los registros de transacciones financieras son inmutables por normativa contable.',
        16,
        1
    );
    ROLLBACK TRANSACTION;
END;
GO

-- =========================================================================
-- PARTE 4: CASOS DE PRUEBA Y EVIDENCIAS
-- =========================================================================

-- -------------------------------------------------------------------------
-- CASO 1: ALTA DE PRODUCTO (INSERT)
-- Objetivo: Comprobar que el trigger registra automáticamente el nuevo producto.
-- -------------------------------------------------------------------------
INSERT INTO dbo.Producto (nombre_producto, descripcion, precio, stock, destacado, activo, id_categoria)
VALUES ('Shaker Pro 700ml', 'Vaso mezclador con compartimento para suplementos', 8500.00, 50, 0, 1, 8);
GO

-- Verificación en la tabla de auditoría:
SELECT * FROM dbo.Auditoria_Sistema WHERE campo_modificado = 'ALTA_PRODUCTO';
GO

-- -------------------------------------------------------------------------
-- CASO 2: MODIFICACIÓN SENSIBLE DE PRECIO Y STOCK (UPDATE)
-- Objetivo: Comprobar que solo se auditan los campos que cambiaron realmente,
-- guardando el valor anterior ($8500 -> $9200) y stock (50 -> 45).
-- -------------------------------------------------------------------------
UPDATE dbo.Producto
SET precio = 9200.00, stock = 45
WHERE nombre_producto = 'Shaker Pro 700ml';
GO

-- Verificación: Deben aparecer dos registros (uno para PRECIO y otro para STOCK)
SELECT * FROM dbo.Auditoria_Sistema 
WHERE id_registro IN (SELECT CAST(id_producto AS VARCHAR) FROM dbo.Producto WHERE nombre_producto = 'Shaker Pro 700ml')
  AND operacion = 'UPDATE';
GO

-- -------------------------------------------------------------------------
-- CASO 3: INTENTO DE BORRADO EN TABLA CON 'ACTIVO' (SOFT DELETE AUTOMÁTICO)
-- Objetivo: Comprobar que al ejecutar DELETE sobre Producto y Usuario,
-- las filas NO se borran, sino que pasan a activo = 0 y se auditan como SOFT_DELETE.
-- -------------------------------------------------------------------------
-- A) Sobre Producto:
DELETE FROM dbo.Producto
WHERE nombre_producto = 'Shaker Pro 700ml';
GO

-- Comprobamos que sigue existiendo en Producto pero con activo = 0:
SELECT id_producto, nombre_producto, precio, stock, activo
FROM dbo.Producto
WHERE nombre_producto = 'Shaker Pro 700ml';
GO

-- B) Sobre Usuario (desactivación lógica de cuenta):
DELETE FROM dbo.Usuario
WHERE id_usuario = 8; -- Usuario Lucia Sanchez
GO

-- Comprobamos que sigue existiendo en Usuario pero con activo = 0:
SELECT id_usuario, nombre_usuario, correo, activo
FROM dbo.Usuario
WHERE id_usuario = 8;
GO

-- Verificación de ambos eventos en Auditoria_Sistema:
SELECT * FROM dbo.Auditoria_Sistema WHERE operacion = 'SOFT_DELETE';
GO

-- -------------------------------------------------------------------------
-- CASO 4: INTENTO DE BORRADO EN TABLA SIN 'ACTIVO' (BLOQUEO Y ROLLBACK)
-- Objetivo: Comprobar que el trigger intercepta el DELETE sobre Pedido y Pago,
-- emite el mensaje de error formal y cancela la transacción.
-- -------------------------------------------------------------------------
-- A) Intento sobre Pedido:
DELETE FROM dbo.Pedido WHERE id_pedido = 1;
GO

-- Comprobación: El pedido 1 sigue existiendo exactamente igual que antes:
SELECT id_pedido, total, estado, id_carrito
FROM dbo.Pedido
WHERE id_pedido = 1;
GO

-- B) Intento sobre Pago:
DELETE FROM dbo.Pago WHERE id_pago = 1;
GO

-- Comprobación: El pago 1 sigue existiendo:
SELECT id_pago, comprobantePago, metodoPago, estado
FROM dbo.Pago
WHERE id_pago = 1;
GO

-- -------------------------------------------------------------------------
-- CASO 5: ACTUALIZACIÓN DE ESTADO EN PEDIDO (UPDATE)
-- Objetivo: Comprobar la trazabilidad de transiciones de estado de compra.
-- -------------------------------------------------------------------------
UPDATE dbo.Pedido
SET estado = 'Pagado'
WHERE id_pedido = 6; -- Estaba 'Pendiente'
GO

-- Verificación en auditoría:
SELECT * FROM dbo.Auditoria_Sistema WHERE tabla_afectada = 'Pedido';
GO

-- -------------------------------------------------------------------------
-- CONSULTA GENERAL DE CONSOLIDACIÓN (REPORTE DE TRAZABILIDAD COMPLETO)
-- -------------------------------------------------------------------------
SELECT 
    id_auditoria AS [ID],
    tabla_afectada AS [Tabla],
    operacion AS [Operación],
    id_registro AS [ID Reg],
    campo_modificado AS [Campo Afectado],
    valor_anterior AS [Valor Anterior],
    valor_nuevo AS [Valor Nuevo],
    CONVERT(VARCHAR(19), fecha, 120) AS [Fecha y Hora],
    usuario AS [Usuario],
    terminal AS [Terminal]
FROM dbo.Auditoria_Sistema
ORDER BY id_auditoria ASC;
GO
