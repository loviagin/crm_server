//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 9/3/25.
//

import Vapor
import Fluent

struct CreateEmployeeTeams: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema("employee_teams")
            .id()
            .field("name", .string, .required)
            .field("desc", .string)
            .unique(on: "name")
            .create()
    }
    
    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema("employee_teams").delete()
    }
}
