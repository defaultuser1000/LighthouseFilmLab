//
//  UserController.swift
//  App
//
//  Created by Андрей Закржевский on 04/05/2019.
//
import Foundation
import Vapor

final class UserController: RouteCollection {
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        usersRoute.get(use: getAllUsers)
        usersRoute.get(User.parameter, use: getOneUser)
        usersRoute.post(use: create)
        usersRoute.put(User.parameter, use: updateUser)
        usersRoute.delete(User.parameter, use: deleteUser)
    }
    
    func create(_ req: Request) throws -> Future<User> {
        return try req.content.decode(User.self).flatMap { user in
//            let dateCreated = user.
            
            return user.save(on: req)
        }
    }
    
    func getAllUsers(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).decode(User.self).all()
    }
    
    func getOneUser(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
    
    func updateUser(_ req: Request) throws -> Future<User> {
        return try flatMap(to: User.self, req.parameters.next(User.self), req.content.decode(User.self)) { (user, updatedUser) in
            user.username = updatedUser.username
            user.password = updatedUser.password
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
            
            return user.save(on: req)
        }
    }
    
    func deleteUser(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap { (user) in
            return user.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
}
