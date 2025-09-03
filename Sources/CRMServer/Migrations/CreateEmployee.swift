//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 9/3/25.
//

import Vapor
import Fluent

struct CreateEmployee: AsyncMigration {    
    func prepare(on database: any FluentKit.Database) async throws {
        try await database.schema("employees")
            .id()
            .field("name", .string, .required)
            .field("ni_number", .string)
            .field("tax_code", .string)
            .field("salary", .double)
            .field("employee_number", .string)
            .field("date_of_birth", .date)
            .field("gender", .string)
            .field("address", .string)
            .field("email", .string)
            .field("phone", .string)
            .field("employment_start_date", .date)
            .field("ni_category", .string)
            .field("pay_frequency", .string)
            .field("hours_per_week", .double)
            .field("basic_rate_per_hour", .double)
            .field("is_director", .bool, .required, .sql(.default(false)))
            .field("directorship_start_date", .date)
            .field("nics_calculation_method", .string)
            .field("pension_scheme", .string)
            .field("leave_allowance_days", .int)
            .field("payment_method", .string)
            .field("bank_account", .string)
            .field("bank_sort_code", .string)
            .create()
    }
    
    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema( "employees" ).delete()
    }
}
