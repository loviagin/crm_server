//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 9/3/25.
//

import Vapor

struct EmployeeTeamMemberController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let group = routes.grouped("employees", "teams", "members")
        let protected = group.grouped(UserToken.authenticator())
        
        protected.get(use: getAllHandler)
    }
    
    func getAllHandler(_ req: Request) async throws -> [EmployeeListDTO] {
        _ = try req.auth.require(User.self)
        
        let members = try await EmployeeTeamMember.query(on: req.db)
            .with(\.$employee)     // подтягиваем данные сотрудника
            .all()
        
        return members.map { m in
            EmployeeListDTO(
                id: m.id!,
                employeeID: m.$employee.id,
                name: m.employee.name,
                email: m.employee.email,
                phone: m.employee.phone,
                jobTitle: m.employee.jobTitle,
                isDirector: m.employee.isDirector,
                joinedAt: m.joinedAt,
                role: m.role
            )
        }
    }
}

