//
//  ChatMessageDataHelper.swift
//  NoLonely
//
//  Created by Divyesh Vekariya on 11/02/22.
//

import Foundation
import SQLite

class ChatMessageDataHelper: DataHelperProtocol {

    static let table = Table("MessageModel")
    static let id = Expression<String>("id")
    static let isUserMessage = Expression<Bool>("isUserMessage")
    static let sentTime = Expression<Int>("sentTime")
    static let message = Expression<String>("message")

    typealias T = MessageModel

    static func createTable() throws {
        guard let database = SQLiteDataStore.current.db else {
            throw DataAccessError.connection
        }
        do {
            try database.run(table.create(ifNotExists: true, block: { table in
                table.column(id)
                table.column(isUserMessage)
                table.column(sentTime)
                table.column(message)
            }))
        } catch {
            // Error throw if table already exists
        }
    }

    static func insert(item: T) -> Swift.Result<(Int64, T), DataAccessError> {

        let insert = table.insert(self.id <- item.id,
                                  self.isUserMessage <- item.isUserMessage,
                                  self.sentTime <- item.sentTime,
                                  self.message <- item.message)

        guard let database = SQLiteDataStore.current.db else {
            return .failure(.connection)
        }
        do {
            let rowID = try database.run(insert)
            guard rowID > 0 else {
                throw DataAccessError.insert
            }
            return .success((rowID, item))
        } catch {
            return .failure(.underlying(error))
        }
    }

    static func delete(item: MessageModel) -> Swift.Result<MessageModel, DataAccessError> {

        guard let db = SQLiteDataStore.current.db else {
            return .failure(.connection)
        }
        let query = table.filter(id == item.id)
        do {
            let rowID = try db.run(query.delete())
            guard rowID > .zero else {
                return .failure(.delete)
            }
            return .success(item)
        } catch {
            return .failure(.delete)
        }
    }

    static func deleteMessage(item: MessageModel) -> Swift.Result<Int, DataAccessError> {

        guard let db = SQLiteDataStore.current.db else {
            return .failure(.connection)
        }

        let query = table.filter(id == item.id)
        do {
            let rows = try db.run(query.delete())
            return .success(rows)
        } catch {
            return .failure(.delete)
        }
    }

//    static func findMessageWith(messageId: String) -> Swift.Result<[T], DataAccessError> {
//
//        var data: [T] = []
//
//        guard let database = SQLiteDataStore.current.db else {
//            return .failure(.connection)
//        }
//        do {
//            let table = Self.table.filter(self.id == messageId)
//            for t in try database.prepare(table) {
//                data.append(.init(id: t[self.id],
//                                  isUserMessage: t[self.isUserMessage],
//                                  sentTime: t[self.sentTime],
//                                  message: t[self.message]))
//            }
//            return .success(data)
//        } catch {
//            return .failure(.underlying(error))
//        }
//    }

    static func findMessageWith(id: String) -> Swift.Result<T, DataAccessError> {

        var data: [T] = []

        guard let database = SQLiteDataStore.current.db else {
            return .failure(.connection)
        }
        do {
            let table = Self.table.filter(self.id == id)
            for t in try database.prepare(table) {
                data.append(.init(id: t[self.id],
                                  isUserMessage: t[self.isUserMessage],
                                  sentTime: t[self.sentTime],
                                  message: t[self.message]))
            }
            if let data = data.first {
                return .success(data)
            } else {
                return .failure(DataAccessError.connection)
            }
        } catch {
            return .failure(.underlying(error))
        }
    }

    static func findAll() -> Swift.Result<[T], DataAccessError> {

        guard let database = SQLiteDataStore.current.db else {
            return .failure(.connection)
        }
        do {
            var data: [T] = []
            let table = Self.table
            let items = try database.prepare(table)

            for item in items {
                data.append(.init(id: item[id],
                                  isUserMessage: item[isUserMessage],
                                  sentTime: item[sentTime],
                                  message: item[message])
                )
            }
            return .success(data)
        } catch {
            return .failure(.underlying(error))
        }
    }
}
