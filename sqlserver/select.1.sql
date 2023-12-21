SELECT 
    expediente.[id], 
    expediente.[descripcion], 
    expediente.[nombre],
    expediente.[dni_cliente],
    expediente.[fecha],
    expediente.[cantidad],
    expediente.[estado],
    expediente.[tipo] 
FROM 
    [formacion].[dbo].[expediente] AS expediente
WHERE
CONTAINS( expediente.[descripcion], 'descripción');

GO

select * FROM  [formacion].[dbo].[estado];

GO

SELECT count(estado.id) FROM [formacion].[dbo].[estado] as estado WHERE estado.id in (1,2,3,4,5);
GO;