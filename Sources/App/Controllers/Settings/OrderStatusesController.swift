//
//  OrderStatusesController.swift
//  App
//
//  Created by Андрей Закржевский on 24/05/2019.
//

import Foundation
import Vapor
import Crypto
import FluentPostgreSQL

final class OrderStatusesController: RouteCollection {
    func boot(router: Router) throws {
        let settingsRoute = router.grouped("api", "settings")
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenProtected = settingsRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        tokenProtected.get(use: renderOrderStatuses)
    }
    
    func renderOrderStatuses(_ req: Request) throws -> Future<View> {
        return try req.view().render("settings/order/statuses")
    }
    
    func renderRolesSettings(_ req: Request) throws -> Future<View> {
        return try req.view().render("settings/user/roles")
    }
    
    func renderOrderStatusDetails(_ req: Request) throws -> Future<View> {
        return try req.view().render("settings/order/statuses/status_detail")
    }
    
    func renderAddNewStatus(_ req: Request) throws -> Future<View> {
        return try req.view().render("settings/order/statuses/add_new_status")
    }
    
    func createHandlerWeb(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(OrderStatus.self).flatMap { orderStatus in
            orderStatus.creationDate = Date()
            orderStatus.modificationDate = Date()
            
            return orderStatus.save(on: req).map { _ in
                return req.redirect(to: "/settings/order/statuses")
            }
        }
    }
    
    func updateHandlerWeb(_ req: Request) throws -> Future<Response> {
        return try flatMap(req.parameters.next(OrderStatus.self), req.content.decode(OrderStatus.self)) { orderStatus, updatedOrderStatus in
            orderStatus.code = updatedOrderStatus.code
            orderStatus.nextStatusId = updatedOrderStatus.nextStatusId
            orderStatus.modificationDate = Date()
            
            return orderStatus.save(on: req)
                .map(to: Response.self) { savedOrderStatus in
                    return req.redirect(to: "/settings/order/statuses/\(savedOrderStatus.id!)")
            }
        }
    }
    
    func deleteHandlerWeb(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(OrderStatus.self).flatMap { orderStatus in
            return OrderStatus.find(orderStatus.nextStatusId!, on: req).flatMap { updatingStatus in
                updatingStatus?.nextStatusId = nil
                updatingStatus?.save(on: req)
                return orderStatus.delete(on: req).map {_ in
                    req.redirect(to: "/settings/order/statuses")
                }
            }
        }
    }
}

