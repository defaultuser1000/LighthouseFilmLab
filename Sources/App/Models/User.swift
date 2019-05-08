//
//  User.swift
//  App
//
//  Created by Андрей Закржевский on 04/05/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class User: PostgreSQLModel {
    var id: Int?
    var password: String
    var eMail: String
    var name: String?
    var surName: String?
    var jobName: String?
    var zip: String?
    var country: String?
    var state: String?
    var city: String?
    var address: String?
    var phone: String?
    var acceptedTermsAndConditions: Bool?
    var tutorial: String?
    var registrationDate: Date?
    var modificationDate: Date?
    var lastOnlineDate: Date?
    
    init(password: String, eMail: String, name: String, surName: String, jobName: String, zip: String, country: String, state: String, city: String, address: String, phone: String, acceptedTermsAndConditions: Bool, tutorial: String, registrationDate: Date, modificationDate: Date, lastOnlineDate: Date) {
        self.password = password
        self.eMail = eMail
        self.name = name
        self.surName = surName
        self.jobName = jobName
        self.zip = zip
        self.country = country
        self.state = state
        self.city = city
        self.address = address
        self.phone = phone
        self.acceptedTermsAndConditions = acceptedTermsAndConditions
        self.tutorial = tutorial
        self.registrationDate = registrationDate
        self.modificationDate = modificationDate
        self.lastOnlineDate = lastOnlineDate
    }
    
    final class Public: PostgreSQLModel {
        var id: Int?
        var name: String
        
        init(id: Int?, name: String) {
            self.id = id
            self.name = name
        }
    }
}

extension User: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.eMail)
            builder.unique(on: \.phone)
        }
    }
}
extension User: Content { }
extension User.Public: Content { }
extension User: Parameter { }

extension User {
    func toPublic() -> User.Public {
        return User.Public(id: id, name: name!)
    }
    
    var orders: Children<User, Order> {
        return children(\.userID)
    }
}

extension Future where T: User {
    func toPublic() -> Future<User.Public> {
        return map(to: User.Public.self) { (user) in
            return user.toPublic()
        }
    }
}

extension User: BasicAuthenticatable {
    static var usernameKey: WritableKeyPath<User, String> {
        return \User.eMail
    }
    
    static var passwordKey: PasswordKey {
        return \User.password
    }
}

extension User: PasswordAuthenticatable {
    static var usernameKeyP: WritableKeyPath<User, String> {
        return \User.eMail
    }
    static var passwordKeyP: WritableKeyPath<User, String> {
        return \User.password
    }
}

extension User: SessionAuthenticatable { }

struct AdminUser: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        let password = try? BCrypt.hash("password")
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }
        
        let user = User(password: hashedPassword, eMail: "admin@lighthouse.com", name: "Admin", surName: "Admin", jobName: "Lighthouse Film Lab", zip: "107045", country: "Russia", state: "", city: "Moscow", address: "Pechatnikov pereulok, 22", phone: "", acceptedTermsAndConditions: true, tutorial: "Not Needed", registrationDate: Date(), modificationDate: Date(), lastOnlineDate: Date())
        return user.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}
