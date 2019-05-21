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
            
            let user = User.find(order.userID, on: req)
            let scanner = Scanner.find(order.scannerID, on: req)
            
            return flatMap(user, scanner) { user, scanner in
                
                order.statusID = 1
                order.creationDate = Date()
                order.modificationDate = Date()
                
                let pdfHelper = PDFHelper()
                let pdf = pdfHelper.renderPDF(invoiceNumber: "\(order.orderNumber ?? 0)",
                    receivedDate: order.creationDate ?? Date(),
                    eMail: "\(user!.eMail)",
                    fullName: "\(user!.name ?? "n/a") \(user!.surName ?? "n/a")",
                    jobName: "\(user!.jobName ?? "n/a")",
                    special: "\(order.special)",
                    address: "\(user!.address ?? "n/a")",
                    city: "\(user!.city ?? "n/a")",
                    state: "\(user!.state ?? "n/a")",
                    zip: "\(user!.zip ?? "n/a")",
                    phone: "\(user!.phone ?? "n/a")",
                    scanner: "\(scanner!.name )",
                    skinTones: "\(order.skinTones)",
                    contrast: "\(order.contrast)",
                    bwContrast: "\(order.bwContrast)",
                    expressScanning: "\(order.expressScan)")
                
                
                return order.save(on: req).map { _ in
                    OrderPDF(orderID: order.id!,
                             pdfContent: pdf.data(using: .utf8)!,
                             creationDate: Date(),
                             modificationDate: Date())
                        .save(on: req)
                    return req.redirect(to: "/orders")
                }
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
            let orderPDF: OrderPDF
            //let nextStatus: OrderStatus
        }

        struct MyContext: Encodable {
            let title: String
            let orderTuples: [JoinResultsTuple]
        }
        
        struct PageData: Content {
            var order: Order
            var orderPDF: Data
            var currentStatus: OrderStatus
            var nextStatus: OrderStatus
            var scanners: [Scanner]
            var selectedScanner: Scanner
            var users: [User]
            var userCreated: User
            var orderOwner: User
        }
        
        return try req.parameters.next(Order.self).flatMap { order in
            
            let orderPDF = OrderPDF.query(on: req).filter(\.orderID == order.id!).first()
            let currentStatus = OrderStatus.find(order.statusID!, on: req)
            let selectedScanner = Scanner.find(order.scannerID, on: req)
            let scanners = Scanner.query(on: req).all()
            
            return flatMap(orderPDF, currentStatus, selectedScanner, scanners) { (orderPDF, currentStatus, selectedScanner, scanners) in
                
                let next = currentStatus!.nextStatusId
                let users = User.query(on: req).all()
                let userCreated = User.find(order.userCreatedID, on: req)
                let orderOwner = User.find(order.userID, on: req)
                
                return flatMap(OrderStatus.find(next!, on: req), users, userCreated, orderOwner) { nextStatus, users, userCreated, orderOwner in
                    let context = PageData(order: order,
                                           orderPDF: (orderPDF!.pdfContent),
                                           currentStatus: currentStatus!,
                                           nextStatus: nextStatus!,
                                           scanners: scanners,
                                           selectedScanner: selectedScanner!,
                                           users: users,
                                           userCreated: userCreated!,
                                           orderOwner: orderOwner!)
                    
                    return try req.view().render("orders/order_details", ["order": context])
                }
            }
        }
        
//        return Order.query(on: req).join(\OrderStatus.id, to: \Order.statusID).alsoDecode(OrderStatus.self).all().flatMap(to: View.self) { joinOrderResults in
//            var joinResultsTuples: [JoinResultsTuple] = []
//
//            for joinResult in joinOrderResults {
////                try OrderStatus.find(joinResult.1.nextStatusId!, on: req).flatMap(to: OrderStatus.self) { nextStatus in
//                    joinResultsTuples.append( JoinResultsTuple( order: joinResult.0, status: joinResult.1) )
//                print("Appended \(joinResult.0) and \(joinResult.1) to Tuple")
////                }
//            }
//            let context = MyContext(title: "order", orderTuples: joinResultsTuples)
//            print("Context: \(context)")
//
//            return try req.view().render("orders/order_details", context)
//        }
        
        
            
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
    
//    func storePDF(_ req: Request) throws -> Future<Response> {
//        return try req.content.decode(OrderPDF.self).flatMap { orderPDF in
//            orderPDF.creationDate = Date()
//            orderPDF.modificationDate = Date()
//            //let order = Order.find(orderPDF.orderID, on: req)
//            return Order.query(on: req).filter(\Order.id, .equal, orderPDF.orderID).first().flatMap { order in
//                //let pdfHelper = PDFHelper()
//                //orderPDF.pdfContent = pdfHelper.renderPDF(invoiceNumber: "\(String(describing: order?.orderNumber))").convertToData()
//
//                return orderPDF.save(on: req).map { _ in
//                    return req.redirect(to: "/orders")
//                }
//            }
//        }
//    }
}
