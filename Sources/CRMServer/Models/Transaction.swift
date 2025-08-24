//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/2/25.
//

import Fluent
import struct Foundation.UUID
import Vapor

final class Transaction: Model, Content, @unchecked Sendable {
    static let schema = "transactions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "date")
    var date: Date

    @Field(key: "description")
    var description: String

    @Children(for: \.$transaction)
    var entries: [LedgerEntry]

    init() {}
    init(date: Date, description: String) {
        self.date = date
        self.description = description
    }
}

struct CreateTransaction: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("transactions")
            .id()
            .field("date", .datetime, .required)
            .field("description", .string)
            .create()
    }
    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("transactions").delete()
    }
}
