//
//  UserTests.swift
//  AppTests
//
//  Created by Андрей Закржевский on 05/05/2019.
//

@testable import App
import Vapor
import FluentPostgreSQL
import XCTest

final class UserTests: XCTestCase {
    let usersName = "Test"
    let usersEMail = "test@test.test"
    let usersSurName = "Test"
    let usersJobName = "Test"
    let usersZip = "Zip"
    let usersCountry = "Test"
    let usersState = "Test"
    let usersCity = "Test"
    let usersAddress = "Test"
    let usersPhone = "Test"
    let usersAcceptedTermsAndConditions = true
    let usersTutorial = "Test"
    let usersRegistrationDate = Date()
    let usersLastOnlineDate = ""
    let usersURI = "api/users/"
    var app: Application!
    var conn: PostgreSQLConnection!
    
    override func setUp() {
        super.setUp()
        
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }
    
    override func tearDown() {
        super.tearDown()
        
        conn.close()
    }
    
    func testUserCanBeSaved() throws {
        let user = User(password: "password", eMail: usersEMail, name: usersName, surName: usersSurName, jobName: usersJobName, zip: usersZip, country: usersCountry, state: usersState, city: usersCity, address: usersAddress, phone: usersPhone, acceptedTermsAndConditions: usersAcceptedTermsAndConditions, tutorial: usersTutorial, registrationDate: usersRegistrationDate, lastOnlineDate: usersLastOnlineDate)
        let createUserResponse = try app.sendRequest(to: usersURI, method: .POST, body: user, isLoggedInRequest: true)
        let receivedUser = try createUserResponse.content.decode([User.Public].self).wait()
        
        XCTAssertEqual(receivedUser.count, 1)
        
        let body: EmptyBody? = nil
        let getUsersResponse = try app.sendRequest(to: usersURI, method: .GET, body: body, isLoggedInRequest: true)
        let receivedUsers = try getUsersResponse.content.decode([User.Public].self).wait()
        
        XCTAssertEqual(receivedUsers.count, 2)
    }
    
    func testSingleUserCanBeRetrieved() throws {
        let user = try User.create(password: "password", eMail: usersEMail, name: usersName, surName: usersSurName, jobName: usersJobName, zip: usersZip, country: usersCountry, state: usersState, city: usersCity, address: usersAddress, phone: usersPhone, acceptedTermsAndConditions: usersAcceptedTermsAndConditions, tutorial: usersTutorial, registrationDate: usersRegistrationDate, lastOnlineDate: usersLastOnlineDate, on: conn)
        let body: EmptyBody? = nil
        let response = try app.sendRequest(to: "\(usersURI)/\(user.id!)", method: .GET, body: body, isLoggedInRequest: true)
        let receivedUser = try response.content.decode(User.Public.self).wait()
        
        XCTAssertEqual(receivedUser.id, user.id)
    }
}
