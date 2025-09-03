//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 9/3/25.
//

import Vapor
import Fluent

final class EmployeeTeam: Model, Content, @unchecked Sendable {
    static let schema: String = "employee_teams"
    
    @ID
    var id: UUID?
    
    @Field(key: "name") var name: String
    @OptionalField(key: "desc") var desc: String?
    
    // Обратная связь на сотрудников
    @Siblings(through: EmployeeTeamMember.self, from: \.$group, to: \.$employee)
    var employees: [Employee]
    
    init(id: UUID? = nil, name: String, desc: String? = nil) {
        self.id = id
        self.name = name
        self.desc = desc
    }
    
    init() {  }
}
