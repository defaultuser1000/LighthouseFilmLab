//
//  User+Testable.swift
//  AppTests
//
//  Created by Андрей Закржевский on 05/05/2019.
//

@testable import App
import FluentPostgreSQL
import Crypto

extension User {
    static func create(username: String, password: String, eMail: String, name: String, surName: String, jobName: String, zip: String, country: String, state: String, city: String, address: String, phone: String, acceptedTermsAndConditions: Bool, tutorial: String, registrationDate: Date, lastOnlineDate: String, on conn: PostgreSQLConnection) throws -> User {
        let password = try BCrypt.hash(password)
        let user = User(username: username, password: password, eMail: eMail, name: name, surName: surName, jobName: jobName, zip: zip, country: country, state: state, city: city, address: address, phone: phone, acceptedTermsAndConditions: acceptedTermsAndConditions, tutorial: tutorial, registrationDate: registrationDate, lastOnlineDate: lastOnlineDate)
        return try user.save(on: conn).wait()
    }
}
