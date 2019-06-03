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
                let stringOrderId = String(order.id!)
                let pdf = pdfHelper.renderPDF(invoiceNumber: "\(order.orderNumber ?? 0)",
                    orderId: stringOrderId,
                    receivedDate: order.creationDate ,
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
    
    func nextStatusHandlerWeb(_ req: Request) throws -> Future<Response> {
        return try flatMap(req.parameters.next(Order.self), req.content.decode(Order.self)) { order, updatedOrder in
            order.statusID = 2
            
            return order.save(on: req)
                .map(to: Response.self) { savedOrder in
                    return req.redirect(to: "/orders/order/\(savedOrder.id!)")
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
            
            return try order.orderPDF.query(on: req).delete().flatMap { _ in
                return order.delete(on: req).map { _ in
                    return req.redirect(to: "/orders")
                }
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
        struct JoinResultsTuple: Content {
            let currentStatus: OrderStatus
            let nextStatus: OrderStatus
        }
        
        struct PageData: Content {
            var order: Order
            var orderPDF: Data
//            var statusesJoined: [JoinResultsTuple]
            var scanners: [Scanner]
            var selectedScanner: Scanner
            var users: [User]
            var userCreated: User
            var orderOwner: User
        }
        
        return try req.parameters.next(Order.self).flatMap { order in
            
            let orderPDF = OrderPDF.query(on: req).filter(\.orderID == order.id!).first()
//            let currentStatus = OrderStatus.find(order.statusID!, on: req)
            let selectedScanner = Scanner.find(order.scannerID, on: req)
            let scanners = Scanner.query(on: req).all()
            let users = User.query(on: req).all()
            
//            return OrderStatus.query(on: req).join(\OrderStatus.id, to: \OrderStatus.nextStatusId).all().flatMap(to: View.self) { joinResults in
//                var joinResultsTuples: [JoinResultsTuple] = []
//                for joinResult in joinResults {
//                    joinResultsTuples.append( JoinResultsTuple( currentStatus: joinResult.code, nextStatus: joinResult.nextStatus.query(on: req). ))
//                }
            
                return flatMap(orderPDF, selectedScanner, scanners, users) { (orderPDF, selectedScanner, scanners, users) in
                    
//                    let nextStatus = currentStatus?.nextStatus.get(on: req)
                    let userCreated = User.find(order.userCreatedID, on: req)
                    let orderOwner = User.find(order.userID, on: req)
                    
                    return flatMap(userCreated, orderOwner) { userCreated, orderOwner in
                        let context = PageData(order: order,
                                               orderPDF: (orderPDF!.pdfContent),
//                                               statusesJoined: joinResultsTuples,
                                               scanners: scanners,
                                               selectedScanner: selectedScanner!,
                                               users: users,
                                               userCreated: userCreated!,
                                               orderOwner: orderOwner!
                        )
                        
                        return try req.view().render("orders/order_details", ["order": context])
                    }
                }
//            }
        }
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
    
//    func downloadOrderForm(_ req: Request) throws -> Future<Response> {
//        return try req.parameters.next(Order.self).flatMap { order in
//            return OrderPDF.query(on: req).filter(\OrderPDF.orderID == order.id!).first().flatMap { orderPDF in
//                return NSData(contentsOf: <#T##URL#>)
//            }
//            
////            orderPDF.creationDate = Date()
////            orderPDF.modificationDate = Date()
////            //let order = Order.find(orderPDF.orderID, on: req)
////            return Order.query(on: req).filter(\Order.id, .equal, orderPDF.orderID).first().flatMap { order in
////                //let pdfHelper = PDFHelper()
////                //orderPDF.pdfContent = pdfHelper.renderPDF(invoiceNumber: "\(String(describing: order?.orderNumber))").convertToData()
////
////                return orderPDF.save(on: req).map { _ in
////                    return req.redirect(to: "/orders")
////                }
////            }
//        }
//    }
}
