//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 9/3/25.
//

import Vapor

struct EmployeeListDTO: Content {
    let id: UUID
    let employeeID: UUID
    let name: String
    let email: String?
    let phone: String?
    let jobTitle: String?       // должность или роль в компании
//    let avatarURL: String?      // если у тебя фото профиля
    let isDirector: Bool        // чтобы помечать в списках
    let joinedAt: Date?         // дата присоединения к группе (если актуально)
    let role: String?            
}
