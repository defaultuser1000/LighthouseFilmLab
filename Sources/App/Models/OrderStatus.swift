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
    var creationDate: Date?
    var modificationDate: Date?
    
    init(code: String, nextStatusId: OrderStatus.ID?, creationDate: Date?, modificationDate: Date?) {
        self.code = code
        self.nextStatusId = nextStatusId
        self.creationDate = creationDate ?? Date()
        self.modificationDate = modificationDate ?? Date()
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
        return OrderStatus.query(on: conn).filter(\.code == "Confirmed").first().flatMap { nextStatus in
            let status = OrderStatus(code: "New", nextStatusId: nextStatus!.id!, creationDate: Date(), modificationDate: Date())
            return status.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct ConfirmedStatus: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderStatus.query(on: conn).filter(\.code == "Sent").first().flatMap { nextStatus in
            let status = OrderStatus(code: "Confirmed", nextStatusId: nextStatus!.id!, creationDate: Date(), modificationDate: Date())
            return status.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct SentStatus: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderStatus.query(on: conn).filter(\.code == "Arrived").first().flatMap { nextStatus in
            let status = OrderStatus(code: "Sent", nextStatusId: nextStatus!.id!, creationDate: Date(), modificationDate: Date())
            return status.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct ArrivedStatus: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderStatus.query(on: conn).filter(\.code == "Developed").first().flatMap { nextStatus in
            let status = OrderStatus(code: "Arrived", nextStatusId: nextStatus!.id!, creationDate: Date(), modificationDate: Date())
            return status.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct DevelopedStatus: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderStatus.query(on: conn).filter(\.code == "Scanned").first().flatMap { nextStatus in
            let status = OrderStatus(code: "Developed", nextStatusId: nextStatus!.id!, creationDate: Date(), modificationDate: Date())
            return status.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct ScannedStatus: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderStatus.query(on: conn).filter(\.code == "Processed").first().flatMap { nextStatus in
            let status = OrderStatus(code: "Scanned", nextStatusId: nextStatus!.id!, creationDate: Date(), modificationDate: Date())
            return status.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct ProcessedStatus: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderStatus.query(on: conn).filter(\.code == "Ready").first().flatMap { nextStatus in
            let status = OrderStatus(code: "Processed", nextStatusId: nextStatus!.id!, creationDate: Date(), modificationDate: Date())
            return status.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct ReadyStatus: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        let status = OrderStatus(code: "Ready", nextStatusId: nil, creationDate: Date(), modificationDate: Date())
        return status.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
