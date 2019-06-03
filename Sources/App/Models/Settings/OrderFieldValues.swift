//
//  OrderFieldValues.swift
//  App
//
//  Created by Андрей Закржевский on 24/05/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class OrderFieldValues: PostgreSQLModel {
    var id: Int?
    var fieldID: OrderField.ID
    var fieldValue: String
    var creationDate: Date
    var modificationDate: Date
    
    init(fieldID: OrderField.ID, fieldValue: String, creationDate: Date?, modificationDate: Date?) {
        self.fieldID = fieldID
        self.fieldValue = fieldValue
        self.creationDate = creationDate ?? Date()
        self.modificationDate = modificationDate ?? Date()
    }
}
extension OrderFieldValues: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
                builder.reference(from: \.fieldID, to: \OrderField.id)
        }
    }
}
extension OrderFieldValues: Content { }
extension OrderFieldValues: Parameter { }
extension OrderFieldValues {
    var field: Parent<OrderFieldValues, OrderField> {
        return parent(\.id)!
    }
}

//Scanner
struct ScannerFieldValue1: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderField.query(on: conn).filter(\.fieldName == "Scanner").first().flatMap { field in
            let fieldValue = OrderFieldValues(fieldID: field!.id!, fieldValue: "Noritsu HS-1800", creationDate: Date(), modificationDate: Date())
            return fieldValue.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct ScannerFieldValue2: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderField.query(on: conn).filter(\.fieldName == "Scanner").first().flatMap { field in
            let fieldValue = OrderFieldValues(fieldID: field!.id!, fieldValue: "Frontier SP-3000", creationDate: Date(), modificationDate: Date())
            return fieldValue.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
//Skin Tones
struct SkinTonesFieldValue1: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderField.query(on: conn).filter(\.fieldName == "Skin Tones").first().flatMap { field in
            let fieldValue = OrderFieldValues(fieldID: field!.id!, fieldValue: "Red Tone", creationDate: Date(), modificationDate: Date())
            return fieldValue.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct SkinTonesFieldValue2: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderField.query(on: conn).filter(\.fieldName == "Skin Tones").first().flatMap { field in
            let fieldValue = OrderFieldValues(fieldID: field!.id!, fieldValue: "Yellow Tone", creationDate: Date(), modificationDate: Date())
            return fieldValue.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct SkinTonesFieldValue3: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderField.query(on: conn).filter(\.fieldName == "Skin Tones").first().flatMap { field in
            let fieldValue = OrderFieldValues(fieldID: field!.id!, fieldValue: "Neutral", creationDate: Date(), modificationDate: Date())
            return fieldValue.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
//Contrast
struct ContrastFieldValue1: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderField.query(on: conn).filter(\.fieldName == "Contrast").first().flatMap { field in
            let fieldValue = OrderFieldValues(fieldID: field!.id!, fieldValue: "High", creationDate: Date(), modificationDate: Date())
            return fieldValue.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct ContrastFieldValue2: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderField.query(on: conn).filter(\.fieldName == "Contrast").first().flatMap { field in
            let fieldValue = OrderFieldValues(fieldID: field!.id!, fieldValue: "Neutral", creationDate: Date(), modificationDate: Date())
            return fieldValue.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct ContrastFieldValue3: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderField.query(on: conn).filter(\.fieldName == "Contrast").first().flatMap { field in
            let fieldValue = OrderFieldValues(fieldID: field!.id!, fieldValue: "Low", creationDate: Date(), modificationDate: Date())
            return fieldValue.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
//B&W Contrast
struct BWContrastFieldValue1: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderField.query(on: conn).filter(\.fieldName == "B&W Contrast").first().flatMap { field in
            let fieldValue = OrderFieldValues(fieldID: field!.id!, fieldValue: "High", creationDate: Date(), modificationDate: Date())
            return fieldValue.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct BWContrastFieldValue2: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderField.query(on: conn).filter(\.fieldName == "B&W Contrast").first().flatMap { field in
            let fieldValue = OrderFieldValues(fieldID: field!.id!, fieldValue: "Neutral", creationDate: Date(), modificationDate: Date())
            return fieldValue.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct BWContrastFieldValue3: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderField.query(on: conn).filter(\.fieldName == "B&W Contrast").first().flatMap { field in
            let fieldValue = OrderFieldValues(fieldID: field!.id!, fieldValue: "Low", creationDate: Date(), modificationDate: Date())
            return fieldValue.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
//Express
struct ExpressFieldValue1: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderField.query(on: conn).filter(\.fieldName == "Express Scanning").first().flatMap { field in
            let fieldValue = OrderFieldValues(fieldID: field!.id!, fieldValue: "4-6 days + 50%", creationDate: Date(), modificationDate: Date())
            return fieldValue.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct ExpressFieldValue2: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return OrderField.query(on: conn).filter(\.fieldName == "Express Scanning").first().flatMap { field in
            let fieldValue = OrderFieldValues(fieldID: field!.id!, fieldValue: "2-4 days + 100%", creationDate: Date(), modificationDate: Date())
            return fieldValue.save(on: conn).transform(to: ())
        }
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
