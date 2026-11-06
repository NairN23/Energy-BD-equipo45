/*
Proyecto Energy - Equipo 45 - Etapa V - Punto 4
Seguridad: usuarios, roles y permisos
SQL Server 2022 | Nair Nazer
Ejecutar en EnergyBD con permisos para crear usuarios, roles y procedimientos.
Se requieren las tablas de la Etapa III. Las pruebas no alteran registros.
*/
USE EnergyBD;
GO

-- 1) Roles: cada rol reúne permisos según la tarea.
IF DATABASE_PRINCIPAL_ID(N'rol_gestor_productos') IS NULL
    CREATE ROLE rol_gestor_productos;
IF DATABASE_PRINCIPAL_ID(N'rol_consulta_catalogo') IS NULL
    CREATE ROLE rol_consulta_catalogo;
GO

-- 2) Usuarios locales para pruebas: sin necesidad de crear logins o contraseñas.
IF DATABASE_PRINCIPAL_ID(N'usuario_gestor_energy') IS NULL
    CREATE USER usuario_gestor_energy WITHOUT LOGIN;
IF DATABASE_PRINCIPAL_ID(N'usuario_consulta_energy') IS NULL
    CREATE USER usuario_consulta_energy WITHOUT LOGIN;
GO

-- 3) Asociar cada usuario a un rol.
IF IS_ROLEMEMBER(N'rol_gestor_productos', N'usuario_gestor_energy') <> 1
    ALTER ROLE rol_gestor_productos ADD MEMBER usuario_gestor_energy;
IF IS_ROLEMEMBER(N'rol_consulta_catalogo', N'usuario_consulta_energy') <> 1
    ALTER ROLE rol_consulta_catalogo ADD MEMBER usuario_consulta_energy;
GO

-- 4) GRANT: conceder lectura y actualización al gestor.
GRANT SELECT, UPDATE ON OBJECT::dbo.Producto TO rol_gestor_productos;
-- DENY: prohibir eliminación, aunque en el futuro se otorgue otro permiso general.
DENY DELETE ON OBJECT::dbo.Producto TO rol_gestor_productos;
GO

-- 5) Procedimiento almacenado: consulta del catálogo activo de Energy.
CREATE OR ALTER PROCEDURE dbo.usp_Energy_ConsultarCatalogo
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id_producto, nombre_producto, precio, stock
    FROM dbo.Producto
    WHERE activo = 1
    ORDER BY nombre_producto;
END;
GO

-- 6) El consultor ejecuta el procedimiento, pero no necesita leer directamente Producto.
GRANT EXECUTE ON OBJECT::dbo.usp_Energy_ConsultarCatalogo TO rol_consulta_catalogo;
-- Quitar un posible permiso SELECT que hubiese quedado de una ejecución anterior.
REVOKE SELECT ON OBJECT::dbo.Producto FROM rol_consulta_catalogo;
GO

-- 7) Consultar roles y usuarios creados.
SELECT r.name AS rol, u.name AS usuario
FROM sys.database_role_members AS m
JOIN sys.database_principals AS r ON r.principal_id = m.role_principal_id
JOIN sys.database_principals AS u ON u.principal_id = m.member_principal_id
WHERE r.name IN (N'rol_gestor_productos', N'rol_consulta_catalogo');
GO

-- 8) Pruebas del gestor: SELECT/UPDATE sí; DELETE no.
-- UPDATE y DELETE usan WHERE 1=0 para no tocar productos.
EXECUTE AS USER = 'usuario_gestor_energy';
BEGIN TRY
    EXEC(N'SELECT TOP (5) id_producto, nombre_producto, precio FROM dbo.Producto;');
    PRINT 'GESTOR - SELECT: PERMITIDO';
END TRY BEGIN CATCH
    PRINT 'GESTOR - SELECT: ERROR ' + ERROR_MESSAGE();
END CATCH;
BEGIN TRY
    EXEC(N'UPDATE dbo.Producto SET precio = precio WHERE 1 = 0;');
    PRINT 'GESTOR - UPDATE: PERMITIDO (0 filas modificadas)';
END TRY BEGIN CATCH
    PRINT 'GESTOR - UPDATE: ERROR ' + ERROR_MESSAGE();
END CATCH;
BEGIN TRY
    EXEC(N'DELETE FROM dbo.Producto WHERE 1 = 0;');
    PRINT 'GESTOR - DELETE: INESPERADAMENTE PERMITIDO';
END TRY BEGIN CATCH
    PRINT 'GESTOR - DELETE: BLOQUEADO - ' + ERROR_MESSAGE();
END CATCH;
REVERT;
GO

-- 9) Prueba explícita de la teoría: GRANT seguido de REVOKE.
-- Se concede TEMPORALMENTE SELECT al rol consultor.
GRANT SELECT ON OBJECT::dbo.Producto TO rol_consulta_catalogo;
GO
EXECUTE AS USER = 'usuario_consulta_energy';
BEGIN TRY
    EXEC(N'SELECT TOP (5) id_producto, nombre_producto FROM dbo.Producto;');
    PRINT 'CONSULTOR - GRANT SELECT: PERMITIDO';
END TRY BEGIN CATCH
    PRINT 'CONSULTOR - GRANT SELECT: ERROR ' + ERROR_MESSAGE();
END CATCH;
REVERT;
GO

-- Se retira el mismo permiso. El consultor vuelve a no tener SELECT directo.
REVOKE SELECT ON OBJECT::dbo.Producto FROM rol_consulta_catalogo;
GO
EXECUTE AS USER = 'usuario_consulta_energy';
BEGIN TRY
    EXEC(N'SELECT TOP (5) id_producto, nombre_producto FROM dbo.Producto;');
    PRINT 'CONSULTOR - REVOKE SELECT: INESPERADAMENTE PERMITIDO';
END TRY BEGIN CATCH
    PRINT 'CONSULTOR - REVOKE SELECT: BLOQUEADO - ' + ERROR_MESSAGE();
END CATCH;
REVERT;
GO

-- 10) El consultor sí puede ejecutar el procedimiento, pero no eliminar productos.
EXECUTE AS USER = 'usuario_consulta_energy';
BEGIN TRY
    EXEC dbo.usp_Energy_ConsultarCatalogo;
    PRINT 'CONSULTOR - EXECUTE: PERMITIDO';
END TRY BEGIN CATCH
    PRINT 'CONSULTOR - EXECUTE: ERROR ' + ERROR_MESSAGE();
END CATCH;
BEGIN TRY
    EXEC(N'DELETE FROM dbo.Producto WHERE 1 = 0;');
    PRINT 'CONSULTOR - DELETE: INESPERADAMENTE PERMITIDO';
END TRY BEGIN CATCH
    PRINT 'CONSULTOR - DELETE: BLOQUEADO - ' + ERROR_MESSAGE();
END CATCH;
REVERT;
GO

-- 11) Resumen de permisos efectivos: 1=permitido; 0=no permitido.
EXECUTE AS USER = 'usuario_gestor_energy';
SELECT USER_NAME() AS usuario,
       HAS_PERMS_BY_NAME(N'dbo.Producto', N'OBJECT', N'SELECT') AS puede_select,
       HAS_PERMS_BY_NAME(N'dbo.Producto', N'OBJECT', N'UPDATE') AS puede_update,
       HAS_PERMS_BY_NAME(N'dbo.Producto', N'OBJECT', N'DELETE') AS puede_delete;
REVERT;
GO
EXECUTE AS USER = 'usuario_consulta_energy';
SELECT USER_NAME() AS usuario,
       HAS_PERMS_BY_NAME(N'dbo.Producto', N'OBJECT', N'SELECT') AS puede_select_directo,
       HAS_PERMS_BY_NAME(N'dbo.usp_Energy_ConsultarCatalogo', N'OBJECT', N'EXECUTE') AS puede_ejecutar_procedimiento;
REVERT;
GO
