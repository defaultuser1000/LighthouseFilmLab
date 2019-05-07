//
//  OrderFilmController.swift
//  App
//
//  Created by Андрей Закржевский on 07/05/2019.
//

import Foundation
import Vapor

final class OrderFilmController {
    func index(_ req: Request) throws -> Future<[Order]> {
        return Order.query(on: req).all()
    }
    
    func create(_ req: Request) throws -> Future<Order> {
        return try req.content.decode(Order.self).flatMap { order in
            return order.save(on: req)
        }
    }
    
    func getOrder(_ req: Request) throws -> Future<Order> {
        return try req.parameters.next(OrderFilm.self).flatMap(to: Order.self) { film in
            return film.order.get(on: req)
        }
    }
}

extension OrderController { }
