//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/2/25.
//

import Vapor

struct AccountController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let accounts = routes.grouped("accounts")
        accounts.get(use: index)
        accounts.post(use: create)
    }

    func index(req: Request) throws -> EventLoopFuture<[Account]> {
        Account.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Account> {
        let account = try req.content.decode(Account.self)
        return account.save(on: req.db).map { account }
    }
}

