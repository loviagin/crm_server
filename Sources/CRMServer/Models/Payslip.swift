//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/2/25.
//

import Fluent
import struct Foundation.UUID
import Vapor

final class Payslip: Model, Content, @unchecked Sendable {
    static let schema = "payslips"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "employee_id")
    var employee: Employee

    @Field(key: "period_start")
    var periodStart: Date

    @Field(key: "period_end")
    var periodEnd: Date

    @Field(key: "gross_pay")
    var grossPay: Double

    @Field(key: "net_pay")
    var netPay: Double

    @Field(key: "tax")
    var tax: Double

    @Field(key: "national_insurance")
    var nationalInsurance: Double

    @OptionalField(key: "pension")
    var pension: Double?
    
    @OptionalField(key: "file_path")
    var filePath: String? // путь к PDF

    init() {}
}

struct CreatePayslip: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("payslips")
            .id()
            .field("employee_id", .uuid, .required, .references("employees", "id"))
            .field("period_start", .date, .required)
            .field("period_end", .date, .required)
            .field("gross_pay", .double, .required)
            .field("net_pay", .double, .required)
            .field("tax", .double, .required)
            .field("national_insurance", .double, .required)
            .field("pension", .double)
            .field("file_path", .string)
            .create()
    }

    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("payslips").delete()
    }
}

