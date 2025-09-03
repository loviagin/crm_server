//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 9/3/25.
//

import Vapor

struct TeamCreateDTO: Content {
    let name: String
    let desc: String?
}
