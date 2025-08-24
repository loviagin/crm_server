import Fluent
import struct Foundation.UUID
import Vapor

final class Account: Model, Content, @unchecked Sendable {
    static let schema = "accounts"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "type")
    var type: String   // asset, liability, income, expense, equity

    @Field(key: "currency")
    var currency: String

    init() {}
    init(name: String, type: String, currency: String) {
        self.name = name
        self.type = type
        self.currency = currency
    }
}
