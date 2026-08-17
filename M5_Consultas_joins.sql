USE Ventas_Tech_DB;
--Crear la tabla territorios--
CREATE TABLE dbo.territorios (
    Id_Territorio INT PRIMARY KEY IDENTITY(1,1),
    region VARCHAR(50) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    zona VARCHAR(50) NOT NULL,
    ciudad VARCHAR(50) NULL,
);

--Cargar los territorios mapeaods con las ciudades de tabla clientes--
INSERT INTO dbo.territorios (region, pais, zona, ciudad) VALUES
('Centro', 'Argentina', 'Sur', 'Buenos Aires'),
('Centro', 'Argentina', 'Centro', 'Córdoba'),
('Litoral', 'Argentina', 'Este', 'Rosario'),
('Cuyo', 'Argentina', 'Oeste', 'Mendoza'),
('NOA', 'Argentina', 'Norte', 'Tucumán');

--CONSULTA 1 - Vista base del proyecto (INNER JOIN)
SELECT 
    v.fecha_venta AS fecha,
    c.nombre AS nombre_cliente,
    c.segmento,
    t.region,
    p.nombre_producto,
    c_cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta,
    'Online' AS canal
FROM dbo.ventas v
INNER JOIN dbo.clientes c 
    ON v.id_cliente = c.id_cliente
INNER JOIN dbo.productos p 
    ON v.id_producto = p.id_producto
LEFT JOIN dbo.categorias c_cat 
    ON p.id_categoria = c_cat.id_categoria
LEFT JOIN dbo.territorios t 
    ON c.ciudad = t.ciudad;

--CONSULTA 2 - CLIENTES SIN VENTAS (LEFT JPIN)--
--Identifica clientes registrados que aún no han realizado compras (CRM).--
SELECT 
    c.nombre,
    c.email,
    c.fecha_registro
FROM dbo.clientes c
LEFT JOIN dbo.ventas v 
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

--CONSULTA 3 - Productos sin ventas (LEFT JOIN)
--Identifica productos del catálogo que no tienen ninguna venta registrada.--
SELECT 
    p.nombre_producto,
    c_cat.nombre_categoria AS categoria,
    p.precio
FROM dbo.productos p
LEFT JOIN dbo.categorias c_cat 
    ON p.id_categoria = c_cat.id_categoria
LEFT JOIN dbo.ventas v 
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;

--CONSULTA 4 - Consolidado por canal (UNION ALL Y GROUP BY)--
--Unifica ventas online y presenciales agreganod columna origen y calcula totales--
WITH VentasConsolidadas AS (
    SELECT 
        id_venta,
        cantidad,
        precio_unitario,
        (cantidad * precio_unitario) AS total_venta,
        'Online' AS canal
    FROM dbo.ventas
    WHERE id_venta % 2 <> 0

    UNION ALL

    SELECT 
        id_venta,
        cantidad,
        precio_unitario,
        (cantidad * precio_unitario) AS total_venta,
        'Presencial' AS canal
    FROM dbo.ventas
    WHERE id_venta % 2 = 0
)
SELECT 
    canal,
    COUNT(id_venta) AS total_transacciones,
    SUM(cantidad) AS unidades_vendidas,
    SUM(total_venta) AS facturacion_total
FROM VentasConsolidadas
GROUP BY canal;



