//
//  User.swift
//  App
//
//  Created by Андрей Закржевский on 04/05/2019.
//

import Foundation
import Vapor
import FluentPostgreSQL

final class User: PostgreSQLModel {
    var id: Int?
    var username: String
    var password: String
    var eMail: String
    var name: String?
    var surName: String?
    var jobName: String?
    var zip: String?
    var country: String?
    var state: String?
    var city: String?
    var address: String?
    var phone: String?
    var acceptedTermsAndConditions: Bool?
    var tutorial: String?
    var registrationDate: String?
    var lastOnlineDate: String?
    
    init(username: String, password: String, eMail: String, name: String, surName: String, jobName: String, zip: String, country: String, state: String, city: String, address: String, phone: String, acceptedTermsAndConditions: Bool, tutorial: String, registrationDate: String, lastOnlineDate: String) {
        self.username = username
        self.password = password
        self.eMail = eMail
        self.name = name
        self.surName = surName
        self.jobName = jobName
        self.zip = zip
        self.country = country
        self.state = state
        self.city = city
        self.address = address
        self.phone = phone
        self.acceptedTermsAndConditions = acceptedTermsAndConditions
        self.tutorial = tutorial
        self.registrationDate = registrationDate
        self.lastOnlineDate = lastOnlineDate
    }
}

extension User: Migration { }
extension User: Content { }
extension User: Parameter { }

