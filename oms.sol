// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
pragma experimental ABIEncoderV2;

contract OMS_COVID {
    // Direccion de la OMS -> Owner del contrato
    address public OMS;

    // Constructoe del contrato
    constructor() {
        OMS = msg.sender;
    }

    // Mappin para elacionbar los centros de salud (direccion / address) con la validez del sistema de salud

    mapping(address => bool) public validacion_centros_salud;

    // Relacionar una direccion de un centro de salud con su contrato inteligente
    mapping(address => address) public centros_salud_contrato;

    // Ejemplo 1: 0x3961C9f6A071EFB5cB27ddC87085BA7149e54628 -> true = TIENE PERMISOS PARA CREAR SU SMART CONTRACT
    // Ejemplo 2: 0x98B6533c41dbE6218D35c3a273D1C42713595f9b -> false = NO TIENE PERMISOS PARA CREAR SU SMART CONTRACT

    // Array de direcciones que almacene los contratos de los centros de salud que han sido validados
    address[] public direcciones_centros_salud_validados;
    address[] solicitudes;

    // Eventos a emitir
    event SolicitudAcceso(address);
    event NuevoContratoValidado(address);
    event NuevoContrato(address, address);

    // Modificador que permita unicamente a la OMS ejecutar la funcion
    modifier onlyOMS(address _direccion) {
        require( _direccion == OMS, "No tienes permiso para ejecutar esta funcion");
        _;
    }

    // Funcion para solicitar acceso al sistema medico
    function SolicitarAcceso() public {
        // Almacenar la direccion del centro de salud que solicita acceso en el array de solicitudes
        solicitudes.push(msg.sender);
        emit SolicitudAcceso(msg.sender);
    }

    // Funcion que permita visualizar las solicitudes de acceso al sistema medico
    function VerSolicitudes() public view onlyOMS(msg.sender) returns(address[] memory) {
        return solicitudes;
    }

    // Funcion que permita validar nuevos centro de salud que pueden autogestionarse -> solo la OMS puede ejecutar esta funcion
    function CentroSalud(address _centro_salud) public onlyOMS(msg.sender) {

        // Asignar el estado a la direccion del centro de salud
        validacion_centros_salud[_centro_salud] = true;
        emit NuevoContratoValidado(_centro_salud);
    }

    // Funcion que permita crear un nuevo contrato inteligente para un centro de salud
    function FactoryCentroSalud() public {
        // Validar que el centro de salud tenga permisos para crear su contrato inteligente
        require(validacion_centros_salud[msg.sender] == true, "No tienes permiso para crear un contrato inteligente");
        // Crear el contrato inteligente ->generar su direccion
        address direccion_contrato = address(new ContratoCentroSalud(msg.sender));
        // Almacenar direccion del contrato en el array
        direcciones_centros_salud_validados.push(direccion_contrato);
        // Relacion entre el centro de salud y su contrato inteligente
        centros_salud_contrato[msg.sender] = direccion_contrato;
        // Emitir evento
        emit NuevoContrato(direccion_contrato, msg.sender);
    }

}

////////////////////////////  Contrato autogestionable Centro de Salud ///////////////////////////////
contract ContratoCentroSalud {
    // Direcciones iniciales
    address public direccion_centro_salud;
    address public direccion_contrato;
    constructor(address _direccion) {
        // Asignar la direccion del centro de salud
        direccion_centro_salud = _direccion;
        direccion_contrato = address(this);
    }
}