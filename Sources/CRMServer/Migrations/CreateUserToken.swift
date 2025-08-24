//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/23/25.
//

import Vapor
import Fluent

struct CreateUserToken: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema("user_tokens")
            .id()
            .field("value", .string, .required)
            .field("user_id", .uuid, .references(User.schema, .id, onDelete: .setNull))
            .unique(on: "value")
            .create()
    }
    
    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema("user_tokens").delete()
    }
}
