//
//  RoleController.swift
//  App
//
//  Created by Андрей Закржевский on 17/05/2019.
//

import Foundation
import Vapor
import Crypto
import FluentPostgreSQL

final class RoleController: RouteCollection {
    func boot(router: Router) throws {
        let rolessRoute = router.grouped("api", "roles")
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenProtected = rolessRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        
        tokenProtected.get(use: getAllRoles)
        tokenProtected.get("role", Role.parameter, use: getOneRole)
        tokenProtected.put(Role.parameter, use: updateRole)
        
        tokenProtected.delete(Role.parameter, use: deleteRole)
        tokenProtected.get(Role.parameter, "users", use: getRoleUsers)
    }
    
    func renderRoles(_ req: Request) throws -> Future<View> {
        return Role.query(on: req).all().flatMap(to: View.self) { roles in
            return try req.view().render("settings/user/roles", ["roles": roles])
        }
    }
    
    func renderAddNewRole(_ req: Request) throws -> Future<View> {
        return try req.view().render("settings/user/add_new_role")
    }
    
    func renderRoleDetails(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Role.self).flatMap { role in
            return try req.view().render("settings/user/role_detail", ["role": role])
        }
    }
    
    func createNewRole(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(Role.self).flatMap { role in
            role.creationDate = Date()
            role.modificationDate = Date()
            
            return role.save(on: req).map { _ in
                return req.redirect(to: "/settings/user/roles")
            }
        }
    }
    
    func getAllRoles(_ req: Request) throws -> Future<[Role]> {
        return Role.query(on: req).decode(Role.self).all()
    }
    
    func getOneRole(_ req: Request) throws -> Future<Role> {
        return try req.parameters.next(Role.self)
    }
    
    func updateRole(_ req: Request) throws -> Future<Role> {
        return try flatMap(to: Role.self, req.parameters.next(Role.self), req.content.decode(Role.self)) { (role, updatedRole) in
            role.name = updatedRole.name
            role.modificationDate = Date()
            
            return role.save(on: req)
        }
    }
    
    func deleteRole(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Role.self).flatMap { (role) in
            return role.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
    
    func getRoleUsers(_ req: Request) throws -> Future<[User]> {
        return try req.parameters.next(Role.self).flatMap(to: [User].self) { role in
            return try role.users.query(on: req).all()
        }
    }
    
    
}
