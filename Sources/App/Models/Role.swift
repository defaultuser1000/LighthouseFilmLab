//
//  Role.swift
//  App
//
//  Created by Андрей Закржевский on 17/05/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class Role: PostgreSQLModel {
    var id: Int?
    var name: String
    var roleType: String
    var creationDate: Date?
    var modificationDate: Date?
    
    init(name: String, roleType: String, creationDate: Date?, modificationDate: Date?) {
        self.name = name
        self.roleType = roleType
        self.creationDate = creationDate
        self.modificationDate = modificationDate
    }
}

extension Role: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.name)
        }
    }
}
extension Role: Content { }
extension Role: Parameter { }
extension Role {
    var users: Children<Role, User> {
        return children(\.id)
    }
}

struct AdminRole: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        
        let role = Role(name: "Admin", roleType: "SYSTEM", creationDate: Date(), modificationDate: Date())
        return role.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}

struct TestRole: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        
        let role = Role(name: "Test", roleType: "SYSTEM", creationDate: Date(), modificationDate: Date())
        return role.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}

struct EmployeRole: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        
        let role = Role(name: "Employe", roleType: "WORK", creationDate: Date(), modificationDate: Date())
        return role.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}

struct EmployerRole: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        
        let role = Role(name: "Employer", roleType: "WORK", creationDate: Date(), modificationDate: Date())
        return role.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}

struct ClientRole: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        
        let role = Role(name: "Client", roleType: "WORK", creationDate: Date(), modificationDate: Date())
        return role.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
