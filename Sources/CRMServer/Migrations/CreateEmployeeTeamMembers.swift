//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 9/3/25.
//

import Fluent

struct CreateEmployeeTeamMembers: AsyncMigration {
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema("employee_team_members")
            .id()
            .field("employee_id", .uuid, .required, .references("employees", "id", onDelete: .cascade))
            .field("group_id", .uuid, .required, .references("employee_teams", "id", onDelete: .cascade))
            .field("role", .string)
            .field("joined_at", .datetime)
        // запрет дубликатов «сотрудник в этой группе»
            .unique(on: "employee_id", "group_id")
            .create()
    }
    
    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema("employee_team_members").delete()
    }
}
