//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/2/25.
//

import Fluent
import struct Foundation.UUID
import Vapor

final class LedgerEntry: Model, Content, @unchecked Sendable {
    static let schema = "ledger_entries"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "transaction_id")
    var transaction: Transaction

    @Parent(key: "account_id")
    var account: Account

    @Field(key: "type")
    var type: String  // debit or credit

    @Field(key: "amount")
    var amount: Double
    
    @OptionalField(key: "currency")
    var currency: String?

    @OptionalField(key: "exchange_rate")
    var exchangeRate: Double?
    
    init(transactionID: UUID, accountID: UUID, type: String, amount: Double) {
        self.$transaction.id = transactionID
        self.$account.id = accountID
        self.type = type
        self.amount = amount
    }
    
    init() {}
}

struct CreateLedgerEntry: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("ledger_entries")
            .id()
            .field("transaction_id", .uuid, .required, .references("transactions", "id"))
            .field("account_id", .uuid, .required, .references("accounts", "id"))
            .field("type", .string, .required)
            .field("amount", .double, .required)
            .field("currency", .string)
            .field("exchange_rate", .double)
            .create()
    }
    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("ledger_entries").delete()
    }
}
