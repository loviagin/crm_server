//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 9/3/25.
//

import Vapor

struct EmployeeTeamsController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let group = routes.grouped("employees", "teams")
        let protected = group.grouped(UserToken.authenticator())
        
        protected.get(use: getAllHandler)
        protected.post(use: createHandler)
        
        let team = protected.grouped(":id")
        team.get("users", use: getEmployeesHandler)
        team.post("attach", use: attachEmployee)
        team.post("detach", use: detachEmployee)
    }
    
    //MARK: - POST /
    func createHandler(_ req: Request) async throws -> EmployeeTeam {
        _ = try req.auth.require(User.self)
        
        let dto = try req.content.decode(TeamCreateDTO.self)
        
        let group = EmployeeTeam(name: dto.name, desc: dto.desc)
        try await group.save(on: req.db)
        return group
    }
    
    //MARK: - GET /
    func getAllHandler(_ req: Request) async throws -> [EmployeeTeam] {
        _ = try req.auth.require(User.self)
        return try await EmployeeTeam.query(on: req.db)
            .sort(\.$name, .ascending)
            .all()
    }
    
    //MARK: - POST /:id/attach
    func attachEmployee(_ req: Request) async throws -> HTTPStatus {
        _ = try req.auth.require(User.self)
        
        guard let groupID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid group id")
        }
        let dto = try req.content.decode(TeamAttachDTO.self)
        
        guard let group = try await EmployeeTeam.find(groupID, on: req.db) else {
            throw Abort(.notFound, reason: "Group not found")
        }
        guard let employee = try await Employee.find(dto.employeeId, on: req.db) else {
            throw Abort(.notFound, reason: "Employee not found")
        }
        
        try await group.$employees.attach(employee, on: req.db) { pivot in
            pivot.role = dto.role
        }
        
        return .created
    }
    
    //MARK: - POST /:id/detach
    func detachEmployee(_ req: Request) async throws -> HTTPStatus {
        _ = try req.auth.require(User.self)
        
        guard let groupID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid group id")
        }
        
        let dto = try req.content.decode(DetachDTO.self)
        
        guard let group = try await EmployeeTeam.find(groupID, on: req.db),
              let employee = try await Employee.find(dto.employeeId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await group.$employees.detach(employee, on: req.db)
        return .noContent
    }
    
    //MARK: - GET /:id/users
    func getEmployeesHandler(_ req: Request) async throws -> [Employee] {
        _ = try req.auth.require(User.self)
        
        // 1) Берём UUID из параметров
        guard let groupID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid group id")
        }
        
        // 2) Ищем группу
        guard let group = try await EmployeeTeam.find(groupID, on: req.db) else {
            throw Abort(.notFound, reason: "Group not found")
        }
        
        // 3) Возвращаем сотрудников (через siblings)
        return try await group.$employees.query(on: req.db).all()
    }
}
