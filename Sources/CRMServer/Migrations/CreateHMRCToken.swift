//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/13/25.
//

import Fluent
import Vapor

struct CreateHMRCToken: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema("hmrc_tokens")
            .id()
            .field("access_token", .string, .required)
            .field("refresh_token", .string, .required)
            .field("expires_at", .datetime, .required)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema("hmrc_tokens").delete()
    }
}

