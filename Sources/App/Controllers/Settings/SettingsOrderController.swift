//
//  SettingsOrderController.swift
//  App
//
//  Created by Андрей Закржевский on 24/05/2019.
//

import Foundation
import Vapor
import Crypto
import FluentPostgreSQL

final class SettingsOrderController: RouteCollection {
    func boot(router: Router) throws {
        let settingsRoute = router.grouped("api", "settings")
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenProtected = settingsRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        tokenProtected.get(use: renderOrderSettings)
    }
    
    func renderOrderSettings(_ req: Request) throws -> Future<View> {
        return try req.view().render("settings/order")
    }
    
    func renderRolesSettings(_ req: Request) throws -> Future<View> {
        return try req.view().render("settings/user/roles")
    }
    
    func renderRoleDetailSettings(_ req: Request) throws -> Future<View> {
        return try req.view().render("settings/user/role_detail")
    }
    
    func renderAddNewRoleSettings(_ req: Request) throws -> Future<View> {
        return try req.view().render("settings/user/add_new_role")
    }
}
