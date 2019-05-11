//
//  UserController.swift
//  App
//
//  Created by Андрей Закржевский on 04/05/2019.
//
import Foundation
import Vapor
import Crypto

final class OrderController: RouteCollection {
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
        tokenProtected.get(Order.parameter, "user", use: getUserHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Order]> {
        return Order.query(on: req).decode(Order.self).all()
    }
    
    func getOneHandler(_ req: Request) throws -> Future<Order> {
        return try req.parameters.next(Order.self)
    }
    
    func createHandler(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(Order.self).flatMap { order in
            order.status = "New"
            order.creationDate = Date()
            order.modificationDate = Date()
            
            return order.save(on: req).map { _ in
                return req.redirect(to: "/orders")
            }
        }
    }
    
    func updateHandler(_ req: Request) throws -> Future<Order> {
        return try flatMap(to: Order.self, req.parameters.next(Order.self), req.content.decode(Order.self)) { (order, updatedOrder) in
            order.userID = updatedOrder.userID
            order.scanner = updatedOrder.scanner
            order.skinTones = updatedOrder.skinTones
            order.contrast = updatedOrder.contrast
            order.bwContrast = updatedOrder.bwContrast
            order.expressScan = updatedOrder.expressScan
            order.special = updatedOrder.special
            order.modificationDate = Date()

            return order.save(on: req)
        }
    }
    
    func updateHandlerWeb(_ req: Request) throws -> Future<Response> {
        return try flatMap(req.parameters.next(Order.self), req.content.decode(Order.self)) { order, updatedOrder in
            order.userID = updatedOrder.userID
            order.scanner = updatedOrder.scanner
            order.skinTones = updatedOrder.skinTones
            order.contrast = updatedOrder.contrast
            order.bwContrast = updatedOrder.bwContrast
            order.expressScan = updatedOrder.expressScan
            order.special = updatedOrder.special
            order.modificationDate = Date()
            
            return order.save(on: req)
                .map(to: Response.self) { savedOrder in
                    return req.redirect(to: "/orders/order/\(savedOrder.id!)")
            }
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Order.self).flatMap { order in
            return order.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
    
    func deleteHandlerWeb(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Order.self).flatMap { order in
            return order.delete(on: req).map {_ in
                req.redirect(to: "/orders")
            }
        }
    }
    
    func getUserHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(Order.self).flatMap(to: User.Public.self) { order in
            return order.user.get(on: req).toPublic()
        }
    }
    
    func renderOrders(_ req: Request) throws -> Future<View> {
        return Order.query(on: req).all().flatMap(to: View.self) { orders in
            return try req.view().render("orders", ["orders": orders])
        }
        
        //        return try req.view().render("orders")
    }
    
    func renderOrderDetails(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Order.self).flatMap { order in
            return try req.view().render("order_details", ["order": order])
        }
    }
    
    func renderOrderEdit(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Order.self).flatMap { order in
            return try req.view().render("order_edit", ["order": order])
        }
    }
    
    func renderAddNewOrder(_ req: Request) throws -> Future<View> {
        let maxOrderNumber = Order.query(on: req).max(\.orderNumber)
        
        return try req.view().render("add_new_order", ["maxOrderNumber": maxOrderNumber])
    }
}
