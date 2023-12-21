
SELECT count(*) FROM [formacion].[dbo].[estado] as estado  WHERE estado.id in (1,2,3,4,5);
GO

SELECT  [formacion].[dbo].[estado].id,  [formacion].[dbo].[estado].[estado] FROM  [formacion].[dbo].[estado];
GO
