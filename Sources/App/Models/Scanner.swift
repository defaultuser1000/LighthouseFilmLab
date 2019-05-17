//
//  Scanner.swift
//  App
//
//  Created by Андрей Закржевский on 16/05/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class Scanner: PostgreSQLModel {
    var id: Int?
    var name: String
    var yearOfProduction: String
    var shortInfo: String
    var creationDate: Date?
    var modificationDate: Date?
    
    
    
    init(name: String, yearOfProduction: String, shortInfo: String, creationDate: Date?, modificationDate: Date?) {
        self.name = name
        self.yearOfProduction = yearOfProduction
        self.shortInfo = shortInfo
        self.creationDate = creationDate
        self.modificationDate = modificationDate
    }
}

extension Scanner: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.name)
        }
    }
}
extension Scanner: Content { }
extension Scanner: Parameter { }
extension Scanner {
    var orders: Children<Scanner, Order> {
        return children(\.id)
    }
    
    static func dateFromString(_ dateAsString: String?) -> Date? {
        guard let string = dateAsString else { return nil }
        
        let dateformatter = DateFormatter()
        dateformatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        let val = dateformatter.date(from: string)
        return val
    }
    
    static func dateToString(_ dateIn: Date?) -> String? {
        guard let date = dateIn else { return nil }
        let dateformatter = DateFormatter()
        dateformatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        let val = dateformatter.string(from: date)
        return val
    }
}
