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
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let basicProtected = usersRoute.grouped(basicAuthMiddleware, guardAuthMiddleware)
        basicProtected.post(use: create)
        basicProtected.post("login", use: login)
        usersRoute.get(use: getAllUsers)
        usersRoute.get(User.parameter, use: getOneUser)
        usersRoute.put(User.parameter, use: updateUser)
        usersRoute.delete(User.parameter, use: deleteUser)
    }
    
    func create(_ req: Request) throws -> Future<User.Public> {
        return try req.content.decode(User.self).flatMap { user in
            user.password = try BCrypt.hash(user.password)
//            user.registrationDate = try
            let date = Date()
            if #available(OSX 10.12, *) {
                let formatter = ISO8601DateFormatter()
                if #available(OSX 10.13, *) {
                    formatter.formatOptions.insert(.withFractionalSeconds)
                    user.registrationDate = formatter.date(from: formatter.string(from: date))
                } else {
                    // Fallback on earlier versions
                }
            } else {
                // Fallback on earlier versions
            }
            
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
}
