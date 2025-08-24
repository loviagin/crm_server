import Fluent
import Vapor

struct CreateTransactionRequest: Content {
    var date: Date
    var description: String
    var entries: [Entry]
    
    struct Entry: Content {
        var accountID: UUID
        var type: String   // "debit" или "credit"
        var amount: Double
    }
}

struct TransactionController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let transactions = routes.grouped("transactions")
        transactions.get(use: index)
        transactions.post(use: create)
    }

    func index(req: Request) throws -> EventLoopFuture<[Transaction]> {
        Transaction.query(on: req.db).with(\.$entries).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Transaction> {
        let data = try req.content.decode(CreateTransactionRequest.self)
        
        // Проверка double-entry
        let totalDebit = data.entries.filter { $0.type == "debit" }.reduce(0) { $0 + $1.amount }
        let totalCredit = data.entries.filter { $0.type == "credit" }.reduce(0) { $0 + $1.amount }
        
        guard abs(totalDebit - totalCredit) < 0.0001 else {
            throw Abort(.badRequest, reason: "Debit and credit are not the same!")
        }
        
        // Сохраняем транзакцию и все LedgerEntries
        return req.db.transaction { db in
            let transaction = Transaction(date: data.date, description: data.description)
            return transaction.save(on: db).flatMap {
                let entries = data.entries.map { entry in
                    LedgerEntry(transactionID: transaction.id!, accountID: entry.accountID, type: entry.type, amount: entry.amount)
                }
                return entries.create(on: db).map { transaction }
            }
        }
    }
}
