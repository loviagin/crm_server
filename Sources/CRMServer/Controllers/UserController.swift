//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/12/25.
//

import Vapor

struct UserController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let group = routes.grouped("users")
        group.post(use: createHandler)
        group.post("login", use: loginHandler)
        
        let protected = group.grouped(UserToken.authenticator())
        protected.get("me", use: getUserHandler)
    }
    
    func getUserHandler(_ req: Request) async throws -> User.Public {
        let user = try req.auth.require(User.self)
        return user.convertToPublic()
    }
    
    func loginHandler(_ req: Request) async throws -> UserToken {
        let credentials = try req.content.decode(User.Login.self)
        
        guard let user = try await User
            .query(on: req.db)
            .filter(\.$login, .equal, credentials.login)
            .first()
        else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }
        
        guard try user.verify(password: credentials.password) else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }
        
        let token = try user.generateToken()
        try await token.save(on: req.db)
        return token
    }
    
    func createHandler(_ req: Request) async throws -> UserToken {
        try User.Create.validate(content: req)
        let create = try req.content.decode(User.Create.self)
        
        let user = try User(
            name: create.name,
            login: create.login,
            email: create.email,
            password: Bcrypt.hash(create.password),
            role: create.role
        )
        
        try await user.save(on: req.db)
        let token = try user.generateToken()
        try await token.save(on: req.db)
        return token
    }
}
