import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: UserController())
    try app.register(collection: AccountController())
    try app.register(collection: TransactionController())
    try app.register(collection: EmployeeController())
    try app.register(collection: ImportController())
    try app.register(collection: HMRCController())
    try app.register(collection: InviteCodeController())
}
