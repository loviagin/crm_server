//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/13/25.
//
import Vapor
import Fluent

final class HMRCToken: Model, Content, @unchecked Sendable {
    static let schema = "hmrc_tokens"

    @ID(key: .id) var id: UUID?
    @Field(key: "access_token") var accessToken: String
    @Field(key: "refresh_token") var refreshToken: String
    @Field(key: "expires_at") var expiresAt: Date
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?

    init() {}
    init(access: String, refresh: String, expiresAt: Date, updatedAt: Date? = nil) {
        self.accessToken = access
        self.refreshToken = refresh
        self.expiresAt = expiresAt
        self.updatedAt = updatedAt
    }
}
