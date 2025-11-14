module basededatos::basededatos {
    use sui::vec_map::{VecMap, Self};
    use std::string::{utf8, String,};



    public struct Informacion has key, store, copy {
        id:UID,
        nombre: String,
        usuarios:VecMap<String, Usuario>
    }

    public struct Usuario has store, copy, drop {
        nombre: String, 
        edad: u8,
        tipo: TipoUsuario
    }

    public enum TipoUsuario, has store, copy, drop {
        Basico(Basico),
        Pro(Pro),
    }

    public struct Basico has store {
        mensaje: String,
    }

    public struct Pro has store {
        mensaje: String,
    }

    #[error]
    const ERROR_NOMBRE_EXISTE: vector<u8> = b"ERROR, EL NOMBRE DE USUARIO YA EXISTE EN LA BASE DE DATOS, INTENTA CON OTRO NUEVO";
    const ERROR_USUARIO_NO_EXISTE: u16 = 404;

    public fun crear_bd(nombre: String, ctx: &mut TxContext) {
        base = Informacion {
            id: new::object(ctx),
            nombre,
            usuarios: vec_map::empty()
        };

        transfer::transfer(base, tx_context::sender(ctx));
    }


    public fun crear_usuario(informacion: &mut Informacion, nombre: String, edad: u8, tipo: u8) {
        assert!(!informacion.contains(&nombre), ERROR_NOMBRE_EXISTE);

        let tipo_usuario = 
        if (tipo == 0) {
            TipoUsuario::Basico(Basico { mensaje: string::utf8(b"Usuario Basico") })
        } else {
            TipoUsuario::Pro(Pro { mensaje: string::utf8(b"Usuario Pro") })
        };

        usuario = Usuario {
            nombre, 
            edad, 
            tipo: tipo_usuario
        };

        informacion.insert(nombre, usuario);
    }
}