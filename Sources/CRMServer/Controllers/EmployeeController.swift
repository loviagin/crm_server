//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/2/25.
//

import Vapor
import Fluent

struct EmployeeController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let employees = routes.grouped("employees")
        employees.get(use: index)
        employees.post(use: create)
        employees.get(":id", "payslips", use: payslips)
        employees.post("payslip", use: createPayslip)
    }
    
    // Получить всех сотрудников
    func index(req: Request) async throws -> [Employee] {
        return try await Employee.query(on: req.db).all()
    }

    // Создать сотрудника
    func create(req: Request) async throws -> Employee {
        let employee = try req.content.decode(Employee.self)
        try await employee.save(on: req.db)
        return employee
    }

    // Получить все payslip сотрудника
    func payslips(req: Request) async throws -> [Payslip] {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Неверный ID сотрудника")
        }
        
        return try await Payslip.query(on: req.db)
            .filter(\Payslip.$employee.$id, .equal, id)
            .all()
    }

    // Создать payslip
    func createPayslip(req: Request) throws -> EventLoopFuture<Payslip> {
        struct PayslipRequest: Content {
            var employeeID: UUID
            var periodStart: Date
            var periodEnd: Date
            var grossPay: Double
            var netPay: Double
            var tax: Double
            var nationalInsurance: Double
            var pension: Double?
        }

        let data = try req.content.decode(PayslipRequest.self)

        return req.db.transaction { db in
            // Проверка, что сотрудник существует
            Employee.find(data.employeeID, on: db)
                .unwrap(or: Abort(.notFound, reason: "Сотрудник не найден"))
                .flatMap { employee in
                    let payslip = Payslip()
                    payslip.$employee.id = employee.id!
                    payslip.periodStart = data.periodStart
                    payslip.periodEnd = data.periodEnd
                    payslip.grossPay = data.grossPay
                    payslip.netPay = data.netPay
                    payslip.tax = data.tax
                    payslip.nationalInsurance = data.nationalInsurance
                    payslip.pension = data.pension

                    return payslip.save(on: db).map { payslip }
                }
        }
    }
}
