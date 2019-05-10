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
        tokenProtected.get("user", User.parameter, use: getOneUser)
        tokenProtected.put(User.parameter, use: updateUser)
        
        tokenProtected.delete(User.parameter, use: deleteUser)
        tokenProtected.get(User.parameter, "orders", use: getUserOrders)
        tokenProtected.get("logout", use: logout)
    }
    
    func renderRegister(_ req: Request) throws -> Future<View> {
        return try req.view().render("register")
    }
    
    func registerWeb(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(User.self).flatMap { user in
            return User.query(on: req).filter(\User.eMail, .equal, user.eMail).first().flatMap { result in
                if let _ = result {
                    return Future.map(on: req) {
                        return req.redirect(to: "/register")
                    }
                }
                user.password = try BCryptDigest().hash(user.password)
                return user.save(on: req).map { _ in
                    return req.redirect(to: "/login")
                }
            }
        }
    }
    
    func renderLogin(_ req: Request) throws -> Future<View> {
        return try req.view().render("login")
    }
    
    func renderHome(_ req: Request) throws -> Future<View> {
        return try req.view().render("home")
    }
    
    func renderOrders(_ req: Request) throws -> Future<View> {
        return Order.query(on: req).all().flatMap(to: View.self) { orders in
            return try req.view().render("orders", ["orders": orders])
        }
        
//        return try req.view().render("orders")
    }
    
    func renderAddNewOrder(_ req: Request) throws -> Future<View> {
        return try req.view().render("add_new_order")
    }
    
    func renderUsers(_ req: Request) throws -> Future<View> {
        return User.query(on: req).all().flatMap(to: View.self) { users in
            return try req.view().render("users", ["users": users])
        }
        
//        return try req.view().render("users")
    }
    
    func renderSettings(_ req: Request) throws -> Future<View> {
        return try req.view().render("settings")
    }
    
    func loginWeb(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(User.self).flatMap { user in
            return User.authenticate(
                username: user.eMail,
                password: user.password,
                using: BCryptDigest(),
                on: req
                ).map { user in
                    guard let user = user else {
                        return req.redirect(to: "/login")
                    }
                    try req.authenticateSession(user)
                    return req.redirect(to: "/home")
            }
        }
    }
    
    func renderProfile(_ req: Request) throws -> Future<View> {
        struct PageData: Content {
            var users: [User]
            var orders: [Order]
            var user: User
        }
        
        let users = User.query(on: req).all()
        let orders = Order.query(on: req).all()
        
        let user = try req.requireAuthenticated(User.self)
        
        return flatMap(to: View.self, users, orders) { users, orders in
            let context = PageData(users: users, orders: orders, user: user)
            
            return try req.view().render("profile", context)
        }
    }
    
    func logout(_ req: Request) throws -> Future<Response> {
        try req.unauthenticateSession(User.self)
        return Future.map(on: req) { return req.redirect(to: "/login") }
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
            user.modificationDate = updatedUser.modificationDate
            
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
    
//    func logout(_ req: Request) throws -> Future<HTTPResponse> {
//        let user = try req.requireAuthenticated(User.self)
//        return try Token.query(on: req).filter(\Token.userId, .equal, user.requireID()).delete().transform(to: HTTPResponse(status: .ok))
//    }
    
    func getUserOrders(_ req: Request) throws -> Future<[Order]> {
        return try req.parameters.next(User.self).flatMap(to: [Order].self) { user in
            return try user.orders.query(on: req).all()
        }
    }
}
