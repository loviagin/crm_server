//
//  File.swift
//  CRMServer
//
//  Created by Ilia Loviagin on 8/2/25.
//

import Vapor
import Fluent

struct ImportController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let importGroup = routes.grouped("import")
        importGroup.on(.POST, "payoneer", body: .collect(maxSize: "10mb"), use: importPayoneer)
    }

    func importPayoneer(req: Request) throws -> EventLoopFuture<[Transaction]> {
        guard var buffer = req.body.data else {
            throw Abort(.badRequest, reason: "Файл не передан")
        }

        guard let data = buffer.readData(length: buffer.readableBytes) else {
            throw Abort(.badRequest, reason: "Не удалось прочитать данные файла")
        }

        guard let csvString = String(data: data, encoding: .utf8) else {
            throw Abort(.badRequest, reason: "Не удалось декодировать CSV")
        }

        let lines = csvString.components(separatedBy: CharacterSet.newlines).dropFirst()

        return req.db.transaction { db in
            // Проходим все строки, создаём транзакции и ledger entries
            let transactionFutures: [EventLoopFuture<Transaction>] = lines.compactMap { line in
                let columns = line.components(separatedBy: ",")
                guard columns.count >= 10 else { return nil }

                let dateString = "\(columns[2]) \(columns[3])"
                let formatter = DateFormatter()
                formatter.dateFormat = "MM-dd-yyyy HH:mm:ss"

                guard let date = formatter.date(from: dateString) else { return nil }

                let currency = columns[0]
                let description = columns[9]
                let credit = Double(columns[5]) ?? 0
                let debit = Double(columns[6]) ?? 0

                let transaction = Transaction(date: date, description: description)

                return transaction.save(on: db).flatMap {
                    // Ledger entry
                    let entry = LedgerEntry()
                    entry.$transaction.id = transaction.id!
                    entry.$account.id = UUID() // TODO: Привязать к реальному счёту Payoneer
                    entry.type = credit > 0 ? "debit" : "credit"
                    entry.amount = credit > 0 ? credit : debit
                    entry.currency = currency

                    return entry.save(on: db).map { transaction }
                }
            }

            // Возвращаем массив всех транзакций, когда они сохранятся
            return transactionFutures.flatten(on: db.eventLoop)
        }
    }
}
