USE master;
GO

CREATE DATABASE formacion ON
(NAME = formacion_dat,
    FILENAME = '/var/opt/mssql/data/formacion.mdf',
    SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5)
LOG ON
(NAME = formacion_log,
    FILENAME = '/var/opt/mssql/data/formacion.ldf',
    SIZE = 5 MB,
    MAXSIZE = 25 MB,
    FILEGROWTH = 5 MB);
GO
