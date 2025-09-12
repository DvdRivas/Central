module veterinaria::registro_veterinaria {
    use std::string::{String, utf8};
    use std::vector;
    use sui::vec_map::{Self, VecMap};
    use sui::object::{Self as object, UID};
    use sui::tx_context::{Self as tx_context, TxContext};
    use sui::transfer;

    // -------------------------------
    // NUEVO: Enum para la edad
    // -------------------------------
    public enum Edad has store, drop, copy {
        Cachorro, // 0-1 años
        Adulto,   // 2-7 años
        Senior,   // 8+ años
    }

    /// Convierte un número (años) al Enum de Edad.
    fun edad_desde_u8(anios: u8): Edad {
        if (anios <= 1) {
            Edad::Cachorro
        } else if (anios <= 7) {
            Edad::Adulto
        } else {
            Edad::Senior
        }
    }

    // Objeto principal Veterinaria que almacena su nombre y un VecMap del dueño ID al Cliente
    public struct Veterinaria has key, store {
        id: UID,
        nombre_veterinaria: String,
        clientes: VecMap<u64, Cliente>,
    }

    // Estructura Cliente que tiene nombre y un vector de Mascotas
    public struct Cliente has copy, drop, store {
        nombre_dueno: String,
        mascotas: vector<Mascota>,
    }

    // Enum para las mascotas: Perro o Gato
    public enum Mascota has store, drop, copy {
        Perro(Perro),
        Gato(Gato),
    }

    // Estructura Perro con nombre, raza y **edad como Enum**
    public struct Perro has copy, drop, store {
        nombre: String,
        raza: String,
        edad: Edad, // <--- CAMBIO: antes u8, ahora Enum
    }

    // Estructura Gato con nombre, raza y **edad como Enum**
    public struct Gato has copy, drop, store {
        nombre: String,
        raza: String,
        edad: Edad, // <--- CAMBIO: antes u8, ahora Enum
    }

    #[error]
    const ID_YA_EXISTE: vector<u8> = b"ERROR el id ya existe";
    #[error]
    const ID_NO_EXISTE: vector<u8> = b"ERROR el id no existe";

    public fun crear_veterinaria(nombre: String, ctx: &mut TxContext) {
        let veterinaria = Veterinaria {
            id: object::new(ctx),
            nombre_veterinaria: nombre,
            clientes: vec_map::empty()
        };
        transfer::transfer(veterinaria, tx_context::sender(ctx));
    }

    public fun agregar_cliente(veterinaria: &mut Veterinaria, id_dueno: u64, nombre_dueno: String) {
        assert!(!veterinaria.clientes.contains(&id_dueno), ID_YA_EXISTE);

        let cliente = Cliente {
            nombre_dueno,
            mascotas: vector[]
        };

        veterinaria.clientes.insert(id_dueno, cliente);
    }

    // Firma igual que antes (edad u8), pero se convierte internamente al Enum.
    public fun agregar_perro(
        veterinaria: &mut Veterinaria,
        id_dueno: u64,
        nombre: String,
        raza: String,
        edad: u8
    ) {
        assert!(veterinaria.clientes.contains(&id_dueno), ID_NO_EXISTE);

        let edad_enum = edad_desde_u8(edad);
        let nueva_mascota = Mascota::Perro(Perro { nombre, raza, edad: edad_enum });

        let cliente_ref = veterinaria.clientes.get_mut(&id_dueno);
        // según estilo original:
        cliente_ref.mascotas.push_back(nueva_mascota);
        // (alternativa canónica: vector::push_back(&mut cliente_ref.mascotas, nueva_mascota);)
    }

    // Igual que arriba, convierte u8 -> Enum.
    public fun agregar_gato(
        veterinaria: &mut Veterinaria,
        id_dueno: u64,
        nombre: String,
        raza: String,
        edad: u8
    ) {
        assert!(veterinaria.clientes.contains(&id_dueno), ID_NO_EXISTE);

        let edad_enum = edad_desde_u8(edad);
        let nueva_mascota = Mascota::Gato(Gato { nombre, raza, edad: edad_enum });

        let cliente_ref = veterinaria.clientes.get_mut(&id_dueno);
        cliente_ref.mascotas.push_back(nueva_mascota);
    }

    // Mantiene la misma firma (nueva_edad u8), pero guarda el Enum.
    public fun modificar_mascota(
        veterinaria: &mut Veterinaria,
        id_dueno: u64,
        indice_mascota: u64,
        nuevo_nombre: String,
        nueva_raza: String,
        nueva_edad: u8
    ) {
        // Verificar que el cliente exista
        assert!(veterinaria.clientes.contains(&id_dueno), ID_NO_EXISTE);

        // Obtener referencia mutable al cliente
        let cliente_ref = veterinaria.clientes.get_mut(&id_dueno);

        // Verificar que el índice de la mascota sea válido
        assert!(indice_mascota < vector::length(&cliente_ref.mascotas), ID_NO_EXISTE);

        let mascota_ref = cliente_ref.mascotas.borrow_mut(indice_mascota);
        let edad_enum = edad_desde_u8(nueva_edad);

        match (mascota_ref) {
            Mascota::Perro(perro) => {
                perro.nombre = nuevo_nombre;
                perro.raza = nueva_raza;
                perro.edad = edad_enum;
            },
            Mascota::Gato(gato) => {
                gato.nombre = nuevo_nombre;
                gato.raza = nueva_raza;
                gato.edad = edad_enum;
            }
        }
    }
}
