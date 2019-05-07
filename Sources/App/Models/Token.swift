//
//  Token.swift
//  App
//
//  Created by Андрей Закржевский on 05/05/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class Token: Codable {
    var id: Int?
    var token: String
    var userId: User.ID
    
    init(token: String, userId: User.ID) {
        self.token = token
        self.userId = userId
    }
}

extension Token: PostgreSQLModel { }
extension Token: Migration { }
extension Token: Content { }

extension Token {
    static func generate(for user: User) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(), userId: user.requireID())
    }
}

extension Token: Authentication.Token {
    typealias UserType = User
    
    static var userIDKey: UserIDKey {
        return \Token.userId
    }
    
    static var tokenKey: TokenKey {
        return \Token.token
    }
}

