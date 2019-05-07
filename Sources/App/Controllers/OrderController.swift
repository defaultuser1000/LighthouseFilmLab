//
//  UserController.swift
//  App
//
//  Created by Андрей Закржевский on 04/05/2019.
//
import Foundation
import Vapor
import Crypto

final class OrderController {
    func boot(router: Router) throws {
        let ordersRoute = router.grouped("api", "orders")
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenProtected = ordersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenProtected.get(use: getAllHandler)
        tokenProtected.get(Order.parameter, use: getOneHandler)
        tokenProtected.post(use: createHandler)
        tokenProtected.put(Order.parameter, use: updateHandler)
        tokenProtected.delete(Order.parameter, use: deleteHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Order]> {
        return Order.query(on: req).decode(Order.self).all()
    }
    
    func getOneHandler(_ req: Request) throws -> Future<Order> {
        return try req.parameters.next(Order.self)
    }
    
    func createHandler(_ req: Request) throws -> Future<Order> {
        return try req.content.decode(Order.self).flatMap { order in
            return order.save(on: req)
        }
    }
    
    func updateHandler(_ req: Request) throws -> Future<Order> {
        return try flatMap(to: Order.self, req.parameters.next(Order.self), req.content.decode(Order.self)) { (order, updatedOrder) in
            order.scanner = updatedOrder.scanner
            order.skinTones = updatedOrder.skinTones
            order.contrast = updatedOrder.contrast
            order.bwContrast = updatedOrder.bwContrast
            order.expressScan = updatedOrder.expressScan
            order.special = updatedOrder.special
            order.status = updatedOrder.status
            order.modificationDate = Date()
            
            return order.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Order.self).flatMap { order in
            return order.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
}
