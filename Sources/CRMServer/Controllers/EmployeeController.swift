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
        let protected = employees.grouped(UserToken.authenticator())

        protected.get(use: index)
        protected.post(use: create)
        protected.get(":id", "payslips", use: payslips)
        protected.post("payslip", use: createPayslip)
        
        protected.get("count", use: getEmployeeCountHandler)
        protected.get("jobtitles", use: getJobTitlesHandler)
    }
    
    func getJobTitlesHandler(_ req: Request) async throws -> [String] {
        _ = try req.auth.require(User.self)
        
        let employees = try await Employee.query(on: req.db)
            .all()
        
        // Берём только jobTitle, фильтруем nil и дубли
        let titles = employees.compactMap { $0.jobTitle }
        let uniqueTitles = Array(Set(titles)).sorted()
        
        return uniqueTitles
    }
    
    func getEmployeeCountHandler(_ req: Request) async throws -> Int {
        return try await Employee.query(on: req.db).count()
    }
    
    // Получить всех сотрудников
    func index(req: Request) async throws -> [Employee] {
        return try await Employee.query(on: req.db).all()
    }

    // Создать сотрудника
    func create(req: Request) async throws -> Employee {
        let user = try req.auth.require(User.self)
        let createEmployee = try req.content.decode(Employee.Create.self)
        let employee = Employee(name: createEmployee.name, jobTitle: createEmployee.jobTitle, email: createEmployee.email, isDirector: createEmployee.isDirector ?? false)
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
