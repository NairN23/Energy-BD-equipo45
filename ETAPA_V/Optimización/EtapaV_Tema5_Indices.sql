-- =========================================================================
-- ETAPA V - TEMA 5: OPTIMIZACIÓN DE CONSULTAS MEDIANTE ÍNDICES
-- Base de Datos: EnergyBD
-- Motor: Microsoft SQL Server
-- Integrante: Juan María Mancedo
-- =========================================================================

USE EnergyBD;
GO

SET NOCOUNT ON;
GO

-- Validar que existan la tabla y las columnas necesarias
IF OBJECT_ID(N'dbo.Pedido', N'U') IS NULL
BEGIN
    THROW 50001, 'No existe la tabla dbo.Pedido en la base EnergyBD.', 1;
END;
GO

IF COL_LENGTH(N'dbo.Pedido', N'estado') IS NULL
   OR COL_LENGTH(N'dbo.Pedido', N'fecha_pedido') IS NULL
BEGIN
    THROW 50002, 'La tabla dbo.Pedido debe contener las columnas estado y fecha_pedido.', 1;
END;
GO

-- Mostrar la cantidad total de pedidos disponibles
PRINT '============================================================';
PRINT 'CANTIDAD TOTAL DE PEDIDOS';
PRINT '============================================================';
SELECT COUNT_BIG(*) AS TotalPedidos FROM dbo.Pedido;
GO

-- Eliminar únicamente el índice de prueba si ya existe
IF EXISTS(
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Pedido_Estado_Fecha'
      AND object_id = OBJECT_ID(N'dbo.Pedido'))
BEGIN
    DROP INDEX IX_Pedido_Estado_Fecha ON dbo.Pedido;
    PRINT 'Se eliminó el índice de prueba para realizar la medición inicial.';
END
ELSE
BEGIN
    PRINT 'El índice de prueba no existía. Se continúa con la medición inicial.';
END;
GO

-- Preparación del período de análisis utilizando una tabla temporal de sesión (#PeriodoAnalisis)
IF OBJECT_ID('tempdb..#PeriodoAnalisis') IS NOT NULL
    DROP TABLE #PeriodoAnalisis;

CREATE TABLE #PeriodoAnalisis(
    FechaDesde DATETIME NOT NULL,
    FechaHasta DATETIME NOT NULL
);

-- Rango dinámico basado en la fecha máxima registrada en la tabla para asegurar resultados
INSERT INTO #PeriodoAnalisis (FechaDesde, FechaHasta)
SELECT DATEADD(DAY, -30, MAX(fecha_pedido)), DATEADD(DAY, 1, MAX(fecha_pedido))
FROM dbo.Pedido;
GO

-- MEDICIÓN 1: Consulta SIN el índice de prueba
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

PRINT '============================================================';
PRINT 'MEDICIÓN 1: CONSULTA SIN EL ÍNDICE DE PRUEBA';
PRINT '============================================================';

SELECT COUNT_BIG(*) AS CantidadPedidosEntregados_SinIndice
FROM dbo.Pedido
CROSS JOIN #PeriodoAnalisis AS P1
WHERE dbo.Pedido.estado = 'Entregado'
  AND dbo.Pedido.fecha_pedido >= P1.FechaDesde
  AND dbo.Pedido.fecha_pedido < P1.FechaHasta
OPTION (RECOMPILE);

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- Crear el índice NONCLUSTERED (estado, fecha_pedido) con INCLUDE para el total
IF NOT EXISTS(
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Pedido_Estado_Fecha'
      AND object_id = OBJECT_ID(N'dbo.Pedido'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Pedido_Estado_Fecha
    ON dbo.Pedido (estado, fecha_pedido)
    INCLUDE (total);

    PRINT 'Índice IX_Pedido_Estado_Fecha creado correctamente.';
END
ELSE
BEGIN
    PRINT 'El índice IX_Pedido_Estado_Fecha ya existe.';
END;
GO

-- Actualizar estadísticas del índice
UPDATE STATISTICS dbo.Pedido IX_Pedido_Estado_Fecha;
GO

-- MEDICIÓN 2: Consulta CON el índice activo
IF OBJECT_ID('tempdb..#PeriodoAnalisis') IS NULL
BEGIN
    CREATE TABLE #PeriodoAnalisis(FechaDesde DATETIME NOT NULL, FechaHasta DATETIME NOT NULL);
    INSERT INTO #PeriodoAnalisis (FechaDesde, FechaHasta)
    SELECT DATEADD(DAY, -30, MAX(fecha_pedido)), DATEADD(DAY, 1, MAX(fecha_pedido))
    FROM dbo.Pedido;
END;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

PRINT '============================================================';
PRINT 'MEDICIÓN 2: CONSULTA CON EL ÍNDICE';
PRINT '============================================================';

SELECT COUNT_BIG(*) AS CantidadPedidosEntregados_ConIndice
FROM dbo.Pedido
CROSS JOIN #PeriodoAnalisis AS P2
WHERE dbo.Pedido.estado = 'Entregado'
  AND dbo.Pedido.fecha_pedido >= P2.FechaDesde
  AND dbo.Pedido.fecha_pedido < P2.FechaHasta
OPTION (RECOMPILE);

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- Verificar índices actuales de la tabla dbo.Pedido
PRINT '============================================================';
PRINT 'ÍNDICES ACTUALES DE dbo.Pedido';
PRINT '============================================================';

SELECT
    I.name AS NombreIndice,
    I.type_desc AS TipoIndice,
    I.is_unique AS EsUnico,
    I.is_primary_key AS EsClavePrimaria,
    IC.key_ordinal AS OrdenColumna,
    C.name AS Columna
FROM sys.indexes AS I
INNER JOIN sys.index_columns AS IC
    ON I.object_id = IC.object_id
   AND I.index_id = IC.index_id
INNER JOIN sys.columns AS C
    ON IC.object_id = C.object_id
   AND IC.column_id = C.column_id
WHERE I.object_id = OBJECT_ID(N'dbo.Pedido')
  AND I.index_id > 0
ORDER BY I.name, IC.key_ordinal, IC.index_column_id;
GO

-- Limpieza de la tabla temporal de sesión
IF OBJECT_ID('tempdb..#PeriodoAnalisis') IS NOT NULL
    DROP TABLE #PeriodoAnalisis;
GO
