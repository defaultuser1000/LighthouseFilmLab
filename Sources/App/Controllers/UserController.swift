//
//  UserController.swift
//  App
//
//  Created by Андрей Закржевский on 04/05/2019.
//
import Foundation
import Vapor
import Crypto

final class UserController: RouteCollection {
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        usersRoute.post("register", use: register)
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let guardAuthMiddleware = User.guardAuthMiddleware()
        
        let basicProtected = usersRoute.grouped(basicAuthMiddleware, guardAuthMiddleware)
        basicProtected.post("login", use: login)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenProtected = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenProtected.get(use: getAllUsers)
        tokenProtected.get(User.parameter, use: getOneUser)
        tokenProtected.put(User.parameter, use: updateUser)
        
        tokenProtected.delete(User.parameter, use: deleteUser)
        tokenProtected.get(User.parameter, use: getUserOrders)
        tokenProtected.get("logout", use: logout)
    }
    
    func register(_ req: Request) throws -> Future<User.Public> {
        return try req.content.decode(User.self).flatMap { user in
            user.password = try BCrypt.hash(user.password)
            user.registrationDate = Date()
            
            return user.save(on: req).toPublic()
        }
    }
    
    func getAllUsers(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(User.Public.self).all()
    }
    
    func getOneUser(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).toPublic()
    }
    
    func updateUser(_ req: Request) throws -> Future<User.Public> {
        return try flatMap(to: User.Public.self, req.parameters.next(User.self), req.content.decode(User.self)) { (user, updatedUser) in
            user.username = updatedUser.username
            user.password = try BCrypt.hash(updatedUser.password)
            user.eMail = updatedUser.eMail
            user.name = updatedUser.name
            user.surName = updatedUser.surName
            user.jobName = updatedUser.jobName
            user.zip = updatedUser.zip
            user.country = updatedUser.country
            user.state = updatedUser.state
            user.city = updatedUser.city
            user.address = updatedUser.address
            user.phone = updatedUser.phone
            user.acceptedTermsAndConditions = updatedUser.acceptedTermsAndConditions
            user.tutorial = updatedUser.tutorial
            user.registrationDate = updatedUser.registrationDate
            user.lastOnlineDate = updatedUser.lastOnlineDate
            
            return user.save(on: req).toPublic()
        }
    }
    
    func deleteUser(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap { (user) in
            return user.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
    
    func login(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
    
    func logout(_ req: Request) throws -> Future<HTTPResponse> {
        let user = try req.requireAuthenticated(User.self)
        return try Token.query(on: req).filter(\Token.userId, .equal, user.requireID()).delete().transform(to: HTTPResponse(status: .ok))
    }
    
    func getUserOrders(_ req: Request) throws -> Future<[Order]> {
        return try req.parameters.next(User.self).flatMap(to: [Order].self) { user in
            return try user.orders.query(on: req).all()
        }
    }
}
