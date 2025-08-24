//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/12/25.
//

import Vapor
import Fluent

struct CreateAccount: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema("accounts")
            .id()
            .field("name", .string, .required)
            .field("type", .string, .required)
            .field("currency", .string, .required)
            .create()
    }
    
    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema("accounts").delete()
    }
}
