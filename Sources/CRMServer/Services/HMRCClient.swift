//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/13/25.
//

import Vapor
import Fluent

struct HMRCClient {
    let req: Request
    
    private var baseURL: URI {
        let env = Environment.get("HMRC_ENV") ?? "sandbox"
        return env == "production" ? URI(string: "https://api.service.hmrc.gov.uk")
        : URI(string: "https://test-api.service.hmrc.gov.uk")
    }
    
    // MARK: OAuth endpoints
    private var authorizeURL: URI { URI(string: baseURL.string + "/oauth/authorize") }
    private var tokenURL: URI { URI(string: baseURL.string + "/oauth/token") }
    
    // MARK: Token storage helpers
    private func fetchToken() async throws -> HMRCToken? {
        try await HMRCToken
            .query(on: req.db)
            .sort(\.$updatedAt, .descending)
            .first()
    }
    
    @discardableResult
    private func saveToken(_ t: HMRCToken) async throws -> HMRCToken {
        try await req.db.transaction { db in
            try await HMRCToken.query(on: db).delete()
            try await t.save(on: db)
        }
        return t
    }
    
    // MARK: Public: build authorize URL
    func makeAuthorizeRedirect() async throws -> Response {
        let clientId = Environment.get("HMRC_CLIENT_ID")
        let redirect = Environment.get("HMRC_REDIRECT_URI")
        // scopes проверь в dev hub; тут примерный список
        let scope = "read:employment write:employment"
        let state = UUID().uuidString
        
        var comps = URLComponents(string: authorizeURL.string)!
        comps.queryItems = [
            .init(name: "response_type", value: "code"),
            .init(name: "client_id", value: clientId),
            .init(name: "redirect_uri", value: redirect),
            .init(name: "scope", value: scope),
            .init(name: "state", value: state)
        ]
        return req.redirect(to: comps.url!.absoluteString)
    }
    
    // Exchange code for token
    func exchangeCode(_ code: String) async throws -> Response {
        guard let clientId = Environment.get("HMRC_CLIENT_ID"),
              let secret   = Environment.get("HMRC_CLIENT_SECRET"),
              let redirect = Environment.get("HMRC_REDIRECT_URI") else {
            throw Abort(.badRequest, reason: "No client id or secret or redirect url")
        }
        
        let body: [String: String] = [
            "grant_type": "authorization_code",
            "code": code,
            "client_id": clientId,
            "client_secret": secret,
            "redirect_uri": redirect
        ]
        
        // 1) запрос в HMRC
        let res = try await req.client.post(tokenURL) { c in
            try c.content.encode(body, as: .urlEncodedForm)
            c.headers.contentType = .urlEncodedForm
        }
        
        guard res.status == .ok else {
            let err = String(buffer: res.body ?? .init())
            throw Abort(.badRequest, reason: "Token exchange failed: \(res.status) \(err)")
        }
        
        // 2) распарсили ответ
        let t = try res.content.decode(TokenResp.self)
        let expires = Date().addingTimeInterval(TimeInterval(t.expires_in - 60))
        let model = HMRCToken(access: t.access_token, refresh: t.refresh_token, expiresAt: expires)
        
        // 3) сохранили в БД
        try await saveToken(model)
        
        // 4) вернули ответ клиенту (если нужен свой JSON — собери Content и верни encode)
        return Response(status: .ok, body: .init(string: "HMRC linked ✔︎"))
    }
    
    // Get valid access token (refresh if needed)
    func validAccessToken() async throws -> String {
        if let tok = try await fetchToken(), tok.expiresAt > Date() {
            return tok.accessToken
        }
        
        guard let tok = try await fetchToken(),
              !tok.refreshToken.isEmpty else {
            throw Abort(.unauthorized, reason: "No HMRC token")
        }
        
        guard let clientId = Environment.get("HMRC_CLIENT_ID"),
              let secret   = Environment.get("HMRC_CLIENT_SECRET") else {
            throw Abort(.badGateway, reason: "No client id or secret")
        }
        
        let body: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": tok.refreshToken,
            "client_id": clientId,
            "client_secret": secret
        ]
        
        let res = try await req.client.post(tokenURL) { c in
            try c.content.encode(body, as: .urlEncodedForm)
            c.headers.contentType = .urlEncodedForm
        }
        
        guard res.status == .ok else {
            let msg = String(buffer: res.body ?? .init())
            throw Abort(.unauthorized, reason: "Refresh failed \(res.status) \(msg)")
        }
        
        let t = try res.content.decode(TokenResp.self)
        let expires = Date().addingTimeInterval(TimeInterval(t.expires_in - 60))
        let model = HMRCToken(access: t.access_token, refresh: t.refresh_token, expiresAt: expires)
        try await saveToken(model)
        
        return t.access_token
    }
    
    // MARK: RTI endpoints (paths могут отличаться в зависимости от версии API)
    func sendFPS(_ payload: ByteBuffer) async throws -> ClientResponse {
        let token = try await validAccessToken()
        let uri = URI(string: "\(baseURL)/organisations/paye/rtI/fps") // поставь нужный путь
        return try await req.client.post(uri) { c in
            c.headers.bearerAuthorization = .init(token: token)
            c.headers.replaceOrAdd(name: "Accept", value: "application/json")
            c.headers.replaceOrAdd(name: "Content-Type", value: "application/json")
            c.body = .init(buffer: payload)
        }
    }
    
    func sendEPS(_ payload: ByteBuffer) async throws -> ClientResponse {
        let token = try await validAccessToken()
        let uri = URI(string: "\(baseURL)/organisations/paye/rtI/eps") // поставь нужный путь
        return try await req.client.post(uri) { c in
            c.headers.bearerAuthorization = .init(token: token)
            c.headers.replaceOrAdd(name: "Accept", value: "application/json")
            c.headers.replaceOrAdd(name: "Content-Type", value: "application/json")
            c.body = .init(buffer: payload)
        }
    }
}

private struct TokenResp: Content {
    let access_token: String
    let refresh_token: String
    let expires_in: Int
    let token_type: String
}
