//
//  OrderPDF.swift
//  App
//
//  Created by Андрей Закржевский on 20/05/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class OrderPDF: PostgreSQLModel {
    var id: Int?
    var orderID: Order.ID
    var pdfContent: Data
    var creationDate: Date?
    var modificationDate: Date?
    
    init(orderID: Order.ID, pdfContent: Data, creationDate: Date, modificationDate: Date) {
        self.orderID = orderID
        self.pdfContent = pdfContent
        self.creationDate = creationDate
        self.modificationDate = modificationDate
    }
}

extension OrderPDF: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.orderID, to: \Order.id, onUpdate: .cascade, onDelete: .cascade)
        }
    }
}

extension OrderPDF: Content { }
extension OrderPDF: Parameter { }

extension OrderPDF {
    var order: Parent<OrderPDF, Order> {
        return parent(\.orderID)
    }
}
