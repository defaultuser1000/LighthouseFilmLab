//
//  OrderStatus.swift
//  App
//
//  Created by Андрей Закржевский on 15/05/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class OrderStatus: PostgreSQLModel {
    
    var id: Int?
    var code: String?
    var nextStatusId: OrderStatus.ID?
    
    init(code: String, nextStatusId: OrderStatus.ID?) {
        self.code = code
        self.nextStatusId = nextStatusId
    }
}

extension OrderStatus: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.code)
            builder.reference(from: \.nextStatusId, to: \OrderStatus.id)
        }
    }
}
extension OrderStatus: Content { }
extension OrderStatus: Parameter { }
extension OrderStatus {
    var orders: Children<OrderStatus, Order> {
        return children(\.statusID)
    }
    var nextStatus: Parent<OrderStatus, OrderStatus> {
        return parent(\.nextStatusId)!
    }
}
struct NewStatus: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        let status = OrderStatus(code: "New", nextStatusId: nil)
        return status.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct ConfirmedStatus: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        let status = OrderStatus(code: "Confirmed", nextStatusId: nil)
        return status.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct SentStatus: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        let status = OrderStatus(code: "Sent", nextStatusId: nil)
        return status.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct ArrivedStatus: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        let status = OrderStatus(code: "Arrived", nextStatusId: nil)
        return status.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct DevelopedStatus: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        let status = OrderStatus(code: "Developed", nextStatusId: nil)
        return status.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct ScannedStatus: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        let status = OrderStatus(code: "Scanned", nextStatusId: nil)
        return status.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct ProcessedStatus: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        let status = OrderStatus(code: "Processed", nextStatusId: nil)
        return status.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct ReadyStatus: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        let status = OrderStatus(code: "Ready", nextStatusId: nil)
        return status.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
