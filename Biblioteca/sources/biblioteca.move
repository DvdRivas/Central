module biblioteca::biblioteca {
    // Importamos las librerías necesarias para manejar String y VecMap
    use std::string::String;
    use sui::vec_map::{Self, VecMap};


    // Códigos de error para control de duplicados o inexistentes
    const TITULO_YA_EXISTE: u64 = 1;
    const TITULO_NO_EXISTE: u64 = 2;

    // Estructura principal que representa la biblioteca
    public struct Biblioteca has key, store {
        id: UID,
        nombre: String,                  // Nombre de la biblioteca
        libros: VecMap<String, Libro>,  // Mapa de libros con clave String
    }

    // Estructura del libro con datos básicos
    public struct Libro has copy, drop, store {
        autor: String,
        publicado: u16,
        disponible: bool,
    }

    // Función para crear la biblioteca con un nombre 
    public fun crear_biblioteca(nombre: String, ctx: &mut TxContext) {
        let libros = vec_map::empty<String, Libro>();
        let biblioteca = Biblioteca {
            id: object::new(ctx),
            nombre,
            libros,
        };
        transfer::transfer(biblioteca, tx_context::sender(ctx));
    }

    // Función para agregar un libro nuevo (clave es título)
    public fun agregar_libro(biblioteca: &mut Biblioteca, titulo: String, autor: String, publicado: u16, disponible: bool) {
        assert!(!biblioteca.libros.contains(&titulo), TITULO_YA_EXISTE);
        let libro = Libro { autor, publicado, disponible };
        biblioteca.libros.insert(titulo, libro);
    }

    // Función para actualizar la disponibilidad de un libro
    public fun actualizar_disponibilidad(biblioteca: &mut Biblioteca, titulo: String, disponible: bool) {
        assert!(biblioteca.libros.contains(&titulo), TITULO_NO_EXISTE);
        let libro_actual = biblioteca.libros.get_mut(&titulo);
        libro_actual.disponible = disponible;
    }

    // Función para eliminar un libro por título
    public fun borrar_libro(biblioteca: &mut Biblioteca, titulo: String) {
        assert!(biblioteca.libros.contains(&titulo), TITULO_NO_EXISTE);
        biblioteca.libros.remove(&titulo);
    }
}