//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 9/3/25.
//

import Vapor

struct TeamAttachDTO: Content {
    let employeeId: UUID
    let role: String?
}
