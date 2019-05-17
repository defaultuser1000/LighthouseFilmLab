//
//  UserController.swift
//  App
//
//  Created by Андрей Закржевский on 04/05/2019.
//
import Foundation
import Vapor
import Crypto
import FluentPostgreSQL

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
            order.statusID = 1
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
            order.scannerID = updatedOrder.scannerID
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
            order.scannerID = updatedOrder.scannerID
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
        struct JoinResultsTuple: Encodable {
            let order: Order
            let status: OrderStatus
        }
        
        struct MyContext: Encodable {
            let title: String
            let orders: [JoinResultsTuple]
        }
        
        return Order.query(on: req).join(\OrderStatus.id, to: \Order.statusID).alsoDecode(OrderStatus.self).all().flatMap(to: View.self) { joinResults in
            var joinResultsTuples: [JoinResultsTuple] = []
            for joinResult in joinResults {
                joinResultsTuples.append( JoinResultsTuple( order: joinResult.0, status: joinResult.1) )
            }
            let context = MyContext(title: "orders", orders: joinResultsTuples)
            return try req.view().render("orders/orders", context)
        }
    }
    
    func renderOrderDetails(_ req: Request) throws -> Future<View> {
        struct JoinResultsTuple: Encodable {
            let order: Order
            let status: OrderStatus
            //let nextStatus: OrderStatus
        }

        struct MyContext: Encodable {
            let title: String
            let orderTuples: [JoinResultsTuple]
        }
        
        return Order.query(on: req).join(\OrderStatus.id, to: \Order.statusID).alsoDecode(OrderStatus.self).all().flatMap(to: View.self) { joinOrderResults in
            var joinResultsTuples: [JoinResultsTuple] = []
            
            for joinResult in joinOrderResults {
//                try OrderStatus.find(joinResult.1.nextStatusId!, on: req).flatMap(to: OrderStatus.self) { nextStatus in
                    joinResultsTuples.append( JoinResultsTuple( order: joinResult.0, status: joinResult.1) )
//                }
            }
            let context = MyContext(title: "order", orderTuples: joinResultsTuples)
            
            return try req.view().render("orders/order_details", context)
        }
            
//            return OrderStatus.query(on: req).join(\OrderStatus.id, to: \OrderStatus.nextStatusId).join(\Order., to: \Order.statusID).alsoDecode(OrderStatus.self).filter(\OrderStatus.id == order.statusID).all().flatMap(to: View.self) { joinResults in
//
//                var joinResultsTuples: [JoinResultsTuple] = []
//                for joinResult in joinResults {
//                    joinResultsTuples.append( JoinResultsTuple( status: joinResult.0, nextStatus: joinResult.1))
//                }
//
//                let order = Order.find(order.id!, on: req)
//                let context = MyContext(order: order, statusTuples: joinResultsTuples)
//
//                return try req.view().render("order_details", context)
//            }
            
            //return try req.view().render("order_details", ["order": order])
//        }
    }
    
    func renderAddNewOrder(_ req: Request) throws -> Future<View> {
        struct PageData: Content {
            var maxOrderNumber: Int
            var users: [User]
            var scanners: [Scanner]
        }
        let maxOrderNumber = Order.query(on: req).max(\.orderNumber)
        let users = User.query(on: req).all()
        let scanners = Scanner.query(on: req).all()

        return flatMap(to: View.self, maxOrderNumber, users, scanners) { maxOrderNumber, users, scanners in
            let context = PageData(maxOrderNumber: maxOrderNumber ?? 0, users: users, scanners: scanners)
            return try req.view().render("orders/add_new_order", context)
        }
    }
    
//    func printPDF(_ req: Request) throws -> String {
//        return try req.parameters.next(Order.self).flatMap { order in
//            return PDFHelper.renderPDF(invoiceNumber: order.orderNumber)
//        }
//    }
}
