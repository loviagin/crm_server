//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/24/25.
//

import Vapor
import Fluent

final class InviteCode: Model, Content, @unchecked Sendable {
    static let schema = "invite_codes"
    
    @ID
    var id: UUID?
    
    @Field(key: "code")
    var code: String
    
    @OptionalParent(key: "user_id")
    var user: User?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "redeemed_at", on: .none)
    var redeemedAt: Date?
    
    init(id: UUID? = nil, code: String, userID: UUID? = nil) {
        self.id = id
        self.code = code
        self.$user.id = userID
    }
    
    init() {  }
    
    struct DTO: Content {
        var code: String
        var userID: UUID?
    }
}

