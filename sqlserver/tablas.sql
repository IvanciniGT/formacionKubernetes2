use formacion;
go

drop table dbo.expediente;
GO
create table dbo.estado(
    id int identity(1,1) primary key,
    estado varchar(50) not null,
);
GO
create table dbo.tipo(
    id int identity(1,1) primary key,
    tipo varchar(50) not null,
);
GO
create table dbo.expediente(
    id int identity(1,1) primary key,
    nombre varchar(50) not null,
    dni_cliente varchar(50) not null,
    descripcion varchar(50) not null,
    fecha date not null,
    cantidad int not null,
    estado int not null,
    tipo int not null,
    foreign key (estado) references dbo.estado(id),
    foreign key (tipo) references dbo.tipo(id)
);
GO
SELECT * FROM dbo.expediente;
GO

create unique index ui_expediente on dbo.expediente(id);
GO
create fulltext catalog formacion  with ACCENT_SENSIVITY=OFF as default;
GO
--ALTER fulltext catalog formacion REBUILD with ACCENT_SENSIVITY=OFF as default;
GO
create fulltext index on dbo.expediente(descripcion)
    key index ui_expediente
    with stoplist = system;
GO

SELECT id   
FROM expediente
WHERE CONTAINS(descripcion, 'hola');
GO