//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/24/25.
//

import Vapor
import Fluent

struct InviteCodeController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let group = routes.grouped("invitecode")
        group.get(":code", use: redeemInviteHandler)
        
        let protected = group.grouped(UserToken.authenticator())
        protected.post(use: createInviteHandler)
    }
    
    func createInviteHandler(_ req: Request) async throws -> InviteCode {
        let user = try req.auth.require(User.self)
        let dto = try req.content.decode(InviteCode.DTO.self)
        
        let inviteCode = InviteCode(code: dto.code, userID: dto.userID)
        try await inviteCode.save(on: req.db)
        return inviteCode
    }
    
    func redeemInviteHandler(_ req: Request) async throws -> UserDTO {
        let code = try req.parameters.require("code")

        guard let invite = try await InviteCode.query(on: req.db)
            .filter(\.$code == code)
            .first()
        else {
            throw Abort(.notFound, reason: "Invalid invite code")
        }

        if invite.redeemedAt != nil {
            throw Abort(.conflict, reason: "Invite code already used")
        }

        if let user = try await User.find(invite.$user.id, on: req.db) {
            invite.redeemedAt = Date()
            try await invite.save(on: req.db)
            
            return UserDTO(id: user.id, name: user.name, login: user.login, email: user.email, role: user.role, createdAt: user.createdAt, updatedAt: user.updatedAt)
        } else {
            throw Abort(.notFound, reason: "User not found")
        }
    }
}
