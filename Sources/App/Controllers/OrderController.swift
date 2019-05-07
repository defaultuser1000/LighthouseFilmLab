//
//  UserController.swift
//  App
//
//  Created by Андрей Закржевский on 04/05/2019.
//
import Foundation
import Vapor

final class OrderController {
    func index(_ req: Request) throws -> Future<[Order]> {
        return Order.query(on: req).all()
    }
    
    func create(_ req: Request) throws -> Future<Order> {
        return try req.content.decode(Order.self).flatMap { order in
            return order.save(on: req)
        }
    }
    
    func getUser(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(Order.self).flatMap(to: User.Public.self) { order in
            return order.user.get(on: req).toPublic()
        }
    }
}
