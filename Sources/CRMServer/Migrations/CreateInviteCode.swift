//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/24/25.
//

import Vapor
import Fluent

struct CreateInviteCode: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema(InviteCode.schema)
            .id()
            .field("code", .string, .required)
            .field("user_id", .uuid, .references(User.schema, .id, onDelete: .setNull))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("redeemed_at", .datetime)
            .unique(on: "code")
            .create()
    }

    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema(InviteCode.schema).delete()
    }
}
