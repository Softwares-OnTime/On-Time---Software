create database con_dental;

use con_dental;

create table iniciar_sesion (
	id int not null primary key auto_increment,
	users varchar(20) not null unique,
    pass varchar(255) not null
    -- rol enum("admin", "medico", "recepcionista", "mantenimiento") not null
);

create table medicos (
	id int not null primary key auto_increment,
    nombre varchar(50) not null,
    fecha_nacimiento date,
    telefono varchar(15),
    especialidad varchar(50) not null,
    email varchar(50) unique,
    usuario_id int not null,
    
    foreign key (usuario_id) references iniciar_sesion(id)
);

create table pacientes (
	id int not null primary key auto_increment,
    nombre varchar (50) not null,
    fecha_nacimiento date,
    genero enum ("M", "F") not null,
    ocupacion varchar(50),
    direccion varchar(100),
    telefono varchar(15)
);

create table servicios (
	id int not null primary key auto_increment,
    servicio varchar(50) not null,
    descripcion text,
    costo decimal(10,2) not null
);

create table diagnostico (
	id int not null primary key auto_increment,
    id_paciente int not null,
    id_medico int not null,
    diagnostico text,
    fecha timestamp default current_timestamp,
    
    foreign key (id_paciente) references pacientes(id),
    foreign key (id_medico) references medicos(id)
);

create table historial_clinico (
	id int not null primary key auto_increment,
    id_paciente int not null,
    enf_previas text,
    alergias text,
    med_actual text,
    int_quirurgica text,
    ant_familiares text,
    enf_cronicas text,
    fecha timestamp default current_timestamp,
    
    foreign key (id_paciente) references pacientes(id)
);

create table consulta(
	id int not null primary key auto_increment,
    id_paciente int not null,
    id_medico int not null,
    id_servicio int not null,
    ult_consulta date not null,
    motivo varchar(50),
    notas text,
    
    foreign key (id_paciente) references pacientes(id),
    foreign key (id_medico) references medicos(id),
    foreign key (id_servicio) references servicios(id)
);

create table ingresos (
    id int not null primary key auto_increment,
    id_servicio int not null,
    id_consulta int not null,
    id_paciente int not null,
    monto decimal(10,2) not null,
    fecha timestamp default current_timestamp,
    metodo_pago enum('Efectivo', 'Tarjeta', 'Abono', 'Transferencia') not null,
    -- descuento decimal(10,2) default 0.00,
    -- estado_pago enum('Pagado', 'Pendiente', 'Parcial') not null,
    
    foreign key (id_servicio) references servicios(id),
    foreign key (id_consulta) references consulta(id),
    foreign key (id_paciente) references pacientes(id)
);

-- Para que la primera sea Mayuscula y despues Minuscula
DELIMITER //
CREATE TRIGGER restriccion_nombre
BEFORE INSERT ON medicos
FOR EACH ROW
BEGIN
    DECLARE temp_nombre VARCHAR(255);
    DECLARE pos INT DEFAULT 1;       
    DECLARE palabra VARCHAR(255);    
    SET temp_nombre = LOWER(NEW.nombre); 
    SET NEW.nombre = '';           

    WHILE pos <= LENGTH(temp_nombre) DO
        SET palabra = SUBSTRING_INDEX(temp_nombre, ' ', 1);
        SET temp_nombre = TRIM(SUBSTRING(temp_nombre FROM LENGTH(palabra) + 2)); 

        SET palabra = CONCAT(UPPER(SUBSTRING(palabra, 1, 1)), LOWER(SUBSTRING(palabra, 2)));
        SET NEW.nombre = CONCAT(NEW.nombre, palabra, ' '); 
    END WHILE;
    SET NEW.nombre = TRIM(NEW.nombre);
END;
//
DELIMITER ;

-- Especialidad va a iniciar con la primera letra mayuscula
DELIMITER //
CREATE TRIGGER formatear_especialidad
BEFORE INSERT ON medicos
FOR EACH ROW
BEGIN
    SET NEW.especialidad = CONCAT(
        UPPER(LEFT(NEW.especialidad, 1)), 
        LOWER(SUBSTRING(NEW.especialidad, 2))
    );
END;
//
DELIMITER ;