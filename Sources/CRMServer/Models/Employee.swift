//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/2/25.
//

import Fluent
import struct Foundation.UUID
import Vapor

final class Employee: Model, Content, @unchecked Sendable {
    static let schema = "employees"
    
    @ID(key: .id)
    var id: UUID?
    
    // Старые поля (сохраняем!)
    @Field(key: "name")
    var name: String
    
    @OptionalField(key: "ni_number")
    var niNumber: String?
    
    @OptionalField(key: "tax_code")
    var taxCode: String?
    
    @OptionalField(key: "salary")
    var salary: Double?
    
    // Новые поля
    @OptionalField(key: "employee_number")
    var employeeNumber: String?
    
    @OptionalField(key: "date_of_birth")
    var dateOfBirth: Date?
    
    @OptionalField(key: "gender")
    var gender: String?
    
    @OptionalField(key: "address")
    var address: String?
    
    @OptionalField(key: "email")
    var email: String?
    
    @OptionalField(key: "phone")
    var phone: String?
    
    @OptionalField(key: "employment_start_date")
    var employmentStartDate: Date?
    
    @OptionalField(key: "ni_category")
    var niCategory: String?
    
    @OptionalField(key: "pay_frequency")
    var payFrequency: String? // weekly, monthly...
    
    @OptionalField(key: "hours_per_week")
    var hoursPerWeek: Double?
    
    @OptionalField(key: "basic_rate_per_hour")
    var basicRatePerHour: Double?
    
    @Field(key: "is_director")
    var isDirector: Bool
    
    @OptionalField(key: "directorship_start_date")
    var directorshipStartDate: Date?
    
    @OptionalField(key: "nics_calculation_method")
    var nicsCalculationMethod: String?
    
    @OptionalField(key: "pension_scheme")
    var pensionScheme: String?
    
    @OptionalField(key: "leave_allowance_days")
    var leaveAllowanceDays: Int?
    
    @OptionalField(key: "payment_method")
    var paymentMethod: String?
    
    @OptionalField(key: "bank_account")
    var bankAccount: String?
    
    @OptionalField(key: "bank_sort_code")
    var bankSortCode: String?
    
    @Siblings(through: EmployeeTeamMember.self, from: \.$employee, to: \.$group)
    var groups: [EmployeeTeam]
    
    init(id: UUID? = nil, name: String, niNumber: String? = nil, taxCode: String? = nil, salary: Double? = nil, employeeNumber: String? = nil, dateOfBirth: Date? = nil, gender: String? = nil, address: String? = nil, email: String? = nil, phone: String? = nil, employmentStartDate: Date? = nil, niCategory: String? = nil, payFrequency: String? = nil, hoursPerWeek: Double? = nil, basicRatePerHour: Double? = nil, isDirector: Bool, directorshipStartDate: Date? = nil, nicsCalculationMethod: String? = nil, pensionScheme: String? = nil, leaveAllowanceDays: Int? = nil, paymentMethod: String? = nil, bankAccount: String? = nil, bankSortCode: String? = nil) {
        self.id = id
        self.name = name
        self.niNumber = niNumber
        self.taxCode = taxCode
        self.salary = salary
        self.employeeNumber = employeeNumber
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.address = address
        self.email = email
        self.phone = phone
        self.employmentStartDate = employmentStartDate
        self.niCategory = niCategory
        self.payFrequency = payFrequency
        self.hoursPerWeek = hoursPerWeek
        self.basicRatePerHour = basicRatePerHour
        self.isDirector = isDirector
        self.directorshipStartDate = directorshipStartDate
        self.nicsCalculationMethod = nicsCalculationMethod
        self.pensionScheme = pensionScheme
        self.leaveAllowanceDays = leaveAllowanceDays
        self.paymentMethod = paymentMethod
        self.bankAccount = bankAccount
        self.bankSortCode = bankSortCode
    }
    
    init() {}
    
    struct Create: Content {
        var name: String
        var email: String
        var isDirector: Bool?
        
        init(name: String, email: String, isDirector: Bool? = false) {
            self.name = name
            self.email = email
            self.isDirector = isDirector
        }
    }
}
