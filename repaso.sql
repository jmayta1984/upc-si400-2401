/*
articulos: codigo (codigo_autor)
autores: nombre (codigo)
*/

select nombre, count(ar.codigo) as cantidad
from articulos as ar
	inner join autores as au on ar.codigo_autor = au.codigo
group by nombre
go

/*
eventos: nombre	(codigo)	
participantes: codigo_usuario (codigo_evento)
*/
/*
fil 1025 1 
fil 1026 1
fil 1028 1
fie 1025 0
fie 1030 1
*/
select nombre, 	count(codigo_usuario) as inscritos,
				sum(asistencia) as asistentes,
				sum(asistencia) / count(codigo_usuario) as porcentaje_asistencia
from eventos as e
	inner join participantes as p on e.codigo = p.codigo_evento
group by nombre
go


/*
eventos: nombre, year(fecha) (codigo)	
participantes: codigo_usuario (codigo_evento)
*/
create function f_cantidad_inscrios_por_evento_por_anho(@anho int) returns table
as
return
	select nombre, count(codigo_usuario) as cantidad
	from eventos as e
		inner join participantes as p on e.codigo = p.codigo_evento
	where year(fecha) = @anho
	group by nombre
go

/* temporal -> select max(cantidad) from temporal
nombre	cantidad
fie 	28
fil 	40
fis 	15
*/

create function f_eventos_con_mas_participantets_por_anho(@anho int) returns table
as
return
	select * from dbo.f_cantidad_inscrios_por_evento_por_anho(@anho)
	where cantidad = (	select max(cantidad)
						from dbo.f_cantidad_inscrios_por_evento_por_anho(@anho))
go

/*
*/

(select codigo, nombre, 'A' as tipo
from autores)
union
(select codigo, nombre, 'E' as tipo
from expositores)
union
(select codigo, nombre, 'U' as tipo
from usuarios)

/*
*/
create procedure sp_insertar_articulo
	@tendencia int,
	@titulo varchar(100),
	@contenido varchar(max),
	@autor int
as
begin

	begin try
		begin transaction t_insert
		insert into articulos (codigo_tendencia, titulo, contenido,
			fecha_publicacion, codigo_autor)
			values (@tendencia, @titulo, @contenido, getdate(), @autor)
		commit transaction
		print ('Nuevo artículo ingresado')
	end try
	begin catch
		if (@@trancount > 0)
		begin
			rollback transaction
			print ('No se pudo ingresar el artículo')
		end

	end catch
end