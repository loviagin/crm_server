////
////  File.swift
////  CRMServer
////
////  Created by Ilia Loviagin on 8/2/25.
////
//
//import Foundation
//
//struct PayoneerTransaction: Codable {
//    var date: Date
//    var description: String
//    var currency: String
//    var credit: Double
//    var debit: Double
//}
//
//func parsePayoneerCSV(fileURL: URL) -> [PayoneerTransaction] {
//    var transactions: [PayoneerTransaction] = []
//    if let content = try? String(contentsOf: fileURL) {
//        let rows = content.components(separatedBy: "\n").dropFirst()
//        for row in rows where !row.isEmpty {
//            let columns = row.components(separatedBy: ",")
//            if columns.count >= 10 {
//                let dateStr = columns[2] + " " + columns[3]
//                let formatter = DateFormatter()
//                formatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
//                
//                let transaction = PayoneerTransaction(
//                    date: formatter.date(from: dateStr)!,
//                    description: columns[9],
//                    currency: columns[0],
//                    credit: Double(columns[5]) ?? 0,
//                    debit: Double(columns[6]) ?? 0
//                )
//                transactions.append(transaction)
//            }
//        }
//    }
//    return transactions
//}
