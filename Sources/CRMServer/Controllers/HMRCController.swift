//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/13/25.
//

import Vapor

struct HMRCController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let r = routes.grouped("hmrc")
        r.get("login", use: login)
        r.get("callback", use: callback)
        r.post("fps", use: fps)
        r.post("eps", use: eps)
    }

    func login(_ req: Request) async throws -> Response {
        try await HMRCClient(req: req).makeAuthorizeRedirect()
    }
    
    func callback(_ req: Request) async throws -> Response {
        guard let code = try? req.query.get(String.self, at: "code") else {
            throw Abort(.badRequest, reason: "No code")
        }
        // просто ждём и возвращаем Response
        return try await HMRCClient(req: req).exchangeCode(code)
    }

    // Принимаем JSON payload от твоего UI/серверной логики и пробрасываем в HMRC
    func fps(_ req: Request) async throws -> Response {
        let buf = req.body.data ?? ByteBuffer()
        let hmrc = try await HMRCClient(req: req).sendFPS(buf)

        guard hmrc.status.code < 300 else {
            let body = String(buffer: hmrc.body ?? .init())
            throw Abort(.badRequest, reason: "HMRC FPS error \(hmrc.status): \(body)")
        }

        var headers = HTTPHeaders()
        if let ct = hmrc.headers.contentType {
            headers.contentType = ct
        }

        return Response(
            status: .ok,
            headers: headers,
            body: .init(buffer: hmrc.body ?? .init())
        )
    }
    
    func eps(_ req: Request) async throws -> Response {
        let buf = req.body.data ?? ByteBuffer()
        let hmrc = try await HMRCClient(req: req).sendEPS(buf)

        guard hmrc.status.code < 300 else {
            let body = String(buffer: hmrc.body ?? .init())
            throw Abort(.badRequest, reason: "HMRC EPS error \(hmrc.status): \(body)")
        }

        var headers = HTTPHeaders()
        if let ct = hmrc.headers.contentType {
            headers.contentType = ct
        }

        return Response(
            status: .ok,
            headers: headers,
            body: .init(buffer: hmrc.body ?? .init())
        )
    }
}
