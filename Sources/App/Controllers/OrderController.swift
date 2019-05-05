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
}
