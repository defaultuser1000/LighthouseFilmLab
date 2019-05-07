//
//  OrderFilm.swift
//  App
//
//  Created by Андрей Закржевский on 07/05/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class OrderFilm: PostgreSQLModel {
    var id: Int?
    var orderID: Order.ID
    var filmNumber: Int
    var quantity: Int
    var process: String
    var filmSize: String
    var pushPull: Int
    var scanSize: String
    var creationDate: String
    var modificationDate: String
    
    init(orderID: Order.ID, filmNumber: Int, quantity: Int, process: String, filmSize: String, pushPull: Int, scanSize: String, creationDate: String, modificationDate: String) {
        self.orderID = orderID
        self.filmNumber = filmNumber
        self.quantity = quantity
        self.process = process
        self.filmSize = filmSize
        self.pushPull = pushPull
        self.scanSize = scanSize
        self.creationDate = creationDate
        self.modificationDate = modificationDate
    }
}

extension OrderFilm: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.orderID, to: \Order.id)
        }
    }
}
extension OrderFilm: Content { }
extension OrderFilm: Parameter { }
extension OrderFilm {
    var order: Parent<OrderFilm, Order> {
        return parent(\.orderID)
    }
}

