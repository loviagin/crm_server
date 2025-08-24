//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/12/25.
//

import Vapor
import Fluent

final class User: Model, Content, Authenticatable, @unchecked Sendable {
    static let schema: String = "users"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "login")
    var login: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "role")
    var role: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, name: String, login: String, email: String, password: String, role: String, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.name = name
        self.login = login
        self.email = email
        self.password = password
        self.role = role
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func convertToPublic() -> User.Public {
        return Public(id: id, name: name, login: login, email: email, role: role, createdAt: createdAt, updatedAt: updatedAt)
    }
    
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}

extension User {
    struct Public: Content {
        var id: UUID?
        var name: String
        var login: String
        var email: String
        var role: String
        var createdAt: Date?
        var updatedAt: Date?
        
        init(id: UUID? = nil, name: String, login: String, email: String, role: String, createdAt: Date? = nil, updatedAt: Date? = nil) {
            self.id = id
            self.name = name
            self.login = login
            self.email = email
            self.role = role
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }
}

extension User {
    struct Login: Content {
        var login: String
        var password: String
        
        init(login: String, password: String) {
            self.login = login
            self.password = password
        }
    }
}

extension User {
    struct Create: Content {
        var name: String
        var login: String
        var email: String
        var password: String
        var role: String
        
        init(name: String, login: String, email: String, password: String, role: String) {
            self.name = name
            self.login = login
            self.email = email
            self.password = password
            self.role = role
        }
    }
}

extension User.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("login", as: String.self, is: !.empty)
        validations.add("role", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension User: ModelAuthenticatable {
    static var usernameKey: KeyPath<User, Field<String>> { \User.$login }
    static var passwordHashKey: KeyPath<User, Field<String>> { \User.$password }
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}
