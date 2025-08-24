//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/23/25.
//

import Fluent
import Vapor

final class UserToken: Model, Content, @unchecked Sendable {
    static let schema = "user_tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "value")
    var value: String

    @Parent(key: "user_id")
    var user: User

    init() { }

    init(id: UUID? = nil, value: String, userID: User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}

extension UserToken: ModelTokenAuthenticatable {
    static var valueKey: KeyPath<UserToken, Field<String>> { \.$value }
    static var userKey: KeyPath<UserToken, Parent<User>> { \.$user }

    var isValid: Bool {
        true
    }
}
