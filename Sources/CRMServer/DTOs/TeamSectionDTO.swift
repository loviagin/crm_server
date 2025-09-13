//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 9/3/25.
//

import Vapor

struct TeamSectionDTO: Content {
    let group: EmployeeTeam
    let members: [EmployeeListDTO]
}
