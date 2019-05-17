//
//  ScannerController.swift
//  App
//
//  Created by Андрей Закржевский on 17/05/2019.
//

import Foundation
import Vapor
import Crypto
import FluentPostgreSQL

final class ScannerController: RouteCollection {
    func boot(router: Router) throws {
        let scannerRoute = router.grouped("api", "settings", "scanners")
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenProtected = scannerRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenProtected.get(use: getAllHandler)
        tokenProtected.get(Scanner.parameter, use: getOneHandler)
        tokenProtected.post(use: createHandler)
        tokenProtected.put(Scanner.parameter, use: updateHandler)
        tokenProtected.delete(Scanner.parameter, use: deleteHandler)
        tokenProtected.get(Scanner.parameter, "orders", use: getScannerOrders)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Scanner]> {
        return Scanner.query(on: req).decode(Scanner.self).all()
    }
    
    func createHandler(_ req: Request) throws -> Future<Response> {
        return try req.content.decode(Scanner.self).flatMap { scanner in
            scanner.creationDate = Date()
            scanner.modificationDate = Date()
            
            return scanner.save(on: req).map { _ in
                return req.redirect(to: "/settings/scanners")
            }
        }
    }
    
    func getOneHandler(_ req: Request) throws -> Future<Scanner> {
        return try req.parameters.next(Scanner.self)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Scanner> {
        return try flatMap(to: Scanner.self, req.parameters.next(Scanner.self), req.content.decode(Scanner.self)) { (scanner, updatedScanner) in
            scanner.name = updatedScanner.name
            scanner.yearOfProduction = updatedScanner.yearOfProduction
            scanner.shortInfo = updatedScanner.shortInfo
            scanner.modificationDate = Date()
            
            return scanner.save(on: req)
        }
    }
    
    func updateHandlerWeb(_ req: Request) throws -> Future<Response> {
        return try flatMap(req.parameters.next(Scanner.self), req.content.decode(Scanner.self)) { scanner, updatedScanner in
            scanner.name = updatedScanner.name
            scanner.shortInfo = updatedScanner.shortInfo
            scanner.yearOfProduction = updatedScanner.yearOfProduction
            scanner.modificationDate = Date()
            
            return scanner.save(on: req)
                .map(to: Response.self) { savedScanner in
                    return req.redirect(to: "/settings/scanners/scanner/\(savedScanner.id!)")
            }
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Scanner.self).flatMap { scanner in
            return scanner.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
    
    func deleteHandlerWeb(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Scanner.self).flatMap { scanner in
            return scanner.delete(on: req).map {_ in
                req.redirect(to: "/settings/scanners")
            }
        }
    }
    
    func getScannerOrders(_ req: Request) throws -> Future<[Order]> {
        return try req.parameters.next(Scanner.self).flatMap(to: [Order].self) { scanner in
            return try scanner.orders.query(on: req).all()
        }
    }
    
    func renderScanners(_ req: Request) throws -> Future<View> {
        return Scanner.query(on: req).all().flatMap(to: View.self) { scanners in
            return try req.view().render("settings/scanners/scanners", ["scanners": scanners])
        }
    }
    
    func renderScannerDetails(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Scanner.self).flatMap { scanner in
            return try req.view().render("settings/scanners/scanner_detail", ["scanner": scanner])
        }
    }
    
    func renderAddNewScanner(_ req: Request) throws -> Future<View> {
        return try req.view().render("settings/scanners/add_new_scanner")
    }
}
