//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/12/25.
//

import Vapor
import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("login", .string, .required)
            .field("email", .string)
            .field("password", .string, .required)
            .field("role", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "login")
            .create()
    }
    
    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema("users").delete()
    }
}
