//
//  NetworkError.swift
//  ArticlesNYT
//
//  Created by Rafael Aviles Puebla on 14/04/26.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidDay
    case noInternetConnection
    case requestTimedOut
    case serverUnavailable
    case invalidResponse
    case decodingFailed
    case unexpected

    var errorDescription: String? {
        switch self {
        case .invalidDay:
            return "Selecciona un rango valido de dias: 1, 7 o 30."
        case .noInternetConnection:
            return "No hay conexion a internet. Intenta nuevamente."
        case .requestTimedOut:
            return "El servidor no respondio a tiempo. Intenta nuevamente."
        case .serverUnavailable:
            return "El servidor no esta disponible en este momento."
        case .invalidResponse:
            return "La respuesta del servidor no es valida."
        case .decodingFailed:
            return "No fue posible procesar la informacion recibida."
        case .unexpected:
            return "Ocurrio un error inesperado al obtener los articulos."
        }
    }
}
