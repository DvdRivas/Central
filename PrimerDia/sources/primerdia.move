module primerdia::modulo {
    use std::debug::print;

    const GRAVEDAD: u8 = 10;

    public fun suma() {
        let numero: u8 = 10;
        print(&(numero + GRAVEDAD))
        
    }

    #[test]
    fun practica() {
        suma()
    }
}


