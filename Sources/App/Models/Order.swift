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
    var scannerID: Scanner.ID
    var skinTones: String
    var contrast: String
    var bwContrast: String
    var expressScan: String
    var special: String
    var statusID: OrderStatus.ID?
    var creationDate: Date?
    var modificationDate: Date?
    
    init(password: String, userID: String, scannerID: Scanner.ID, skinTones: String, contrast: String, bwContrast: String, expressScan: String, special: String, statusID: OrderStatus.ID?, creationDate: Date, modificationDate: Date) {
        self.userID = Int(userID) ?? 1
        self.scannerID = scannerID
        self.skinTones = skinTones
        self.contrast = contrast
        self.bwContrast = bwContrast
        self.expressScan = expressScan
        self.special = special
        self.statusID = statusID ?? 1
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
            builder.reference(from: \.scannerID, to: \Scanner.id)
            builder.reference(from: \.statusID, to: \OrderStatus.id)
        }
    }
}
extension Order: Content { }
extension Order: Parameter { }
extension Order {
    var user: Parent<Order, User> {
        return parent(\.userID)
    }
    var status: Parent<Order, OrderStatus> {
        return parent(\.statusID)!
    }
    var films: Children<Order, OrderFilm> {
        return children(\.id)
    }
    var scanner: Parent<Order, Scanner> {
        return parent(\.scannerID)
    }
}
