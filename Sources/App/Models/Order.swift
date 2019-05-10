//
//  User.swift
//  App
//
//  Created by Андрей Закржевский on 04/05/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class Order: PostgreSQLModel {
    var id: Int?
    var orderNumber: Int?
    var userID: User.ID
    var scanner: String
    var skinTones: String
    var contrast: String
    var bwContrast: String
    var expressScan: String
    var special: String
    var status: String?
    var creationDate: Date?
    var modificationDate: Date?
    
    init(password: String, userID: String, scanner: String, skinTones: String, contrast: String, bwContrast: String, expressScan: String, special: String, creationDate: Date, modificationDate: Date) {
        self.userID = Int(userID) ?? 1
        self.scanner = scanner
        self.skinTones = skinTones
        self.contrast = contrast
        self.bwContrast = bwContrast
        self.expressScan = expressScan
        self.special = special
        self.creationDate = creationDate
        self.modificationDate = modificationDate
    }
}

extension Order: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.orderNumber)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}
extension Order: Content { }
extension Order: Parameter { }
extension Order {
    var user: Parent<Order, User> {
        return parent(\.userID)
    }
}
