//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 9/3/25.
//

import Vapor
import Fluent

final class EmployeeTeamMember: Model, @unchecked Sendable {
    static let schema = "employee_team_members"

    @ID
    var id: UUID?

    @Parent(key: "employee_id") var employee: Employee
    @Parent(key: "group_id") var group: EmployeeTeam

    // Доп. поля при необходимости:
    @OptionalField(key: "role") var role: String?    // "owner" | "admin" | "member"
    @Timestamp(key: "joined_at", on: .create) var joinedAt: Date?

    init() {}
    init(employeeID: UUID, groupID: UUID, role: String? = nil) {
        self.$employee.id = employeeID
        self.$group.id = groupID
        self.role = role
    }
}
