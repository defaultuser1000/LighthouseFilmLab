//
//  SettingsOrderFields.swift
//  App
//
//  Created by Андрей Закржевский on 24/05/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class OrderField: PostgreSQLModel {
    var id: Int?
    var fieldName: String
    var fieldType: String
    var creationDate: Date
    var modificationDate: Date
    
    init(fieldName: String, fieldType: String, creationDate: Date?, modificationDate: Date?) {
        self.fieldName = fieldName
        self.fieldType = fieldType
        self.creationDate = creationDate ?? Date()
        self.modificationDate = modificationDate ?? Date()
    }
}
extension OrderField: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
                builder.unique(on: \.fieldName)
        }
    }
}
extension OrderField: Content { }
extension OrderField: Parameter { }
extension OrderField {
    var fieldValues: Children<OrderField, OrderFieldValues> {
        return children(\.id)
    }
}
struct UserField: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        
        let field = OrderField(fieldName: "User", fieldType: "SELECT", creationDate: Date(), modificationDate: Date())
        return field.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct ScannerField: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        
        let field = OrderField(fieldName: "Scanner", fieldType: "SELECT", creationDate: Date(), modificationDate: Date())
        return field.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct SkinTonesField: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        
        let field = OrderField(fieldName: "Skin Tones", fieldType: "SELECT", creationDate: Date(), modificationDate: Date())
        return field.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct ContrastField: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        
        let field = OrderField(fieldName: "Contrast", fieldType: "SELECT", creationDate: Date(), modificationDate: Date())
        return field.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct BWContrastField: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        
        let field = OrderField(fieldName: "B&W Contrast", fieldType: "SELECT", creationDate: Date(), modificationDate: Date())
        return field.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
struct ExpressField: Migration {
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        
        let field = OrderField(fieldName: "Express Scanning", fieldType: "SELECT", creationDate: Date(), modificationDate: Date())
        return field.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> Future<Void> {
        return .done(on: conn)
    }
}
