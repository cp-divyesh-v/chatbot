//
//  ChatDataHelper.swift
//  chatbot
//
//  Created by Divyesh Vekariya on 01/03/22.
//

import Foundation
import SQLite

class ChatDataHelper: DataHelperProtocol {

    static let table = Table("ChatModel")
    static let id = Expression<String>("id")
    static let name = Expression<String>("name")
    static let createdAt = Expression<Date>("createdAt")
    static let updatedOn = Expression<Date>("updatedOn")

    typealias T = ChatModel

    static func createTable() throws {
        guard let database = SQLiteDataStore.current.db else {
            throw DataAccessError.connection
        }
        do {
            try database.run(table.create(ifNotExists: true, block: { table in
                table.column(id)
                table.column(name)
                table.column(createdAt)
                table.column(updatedOn)
            }))
        } catch {
            // Error throw if table already exists
        }
    }
    
    static func insert(item: T) -> Swift.Result<(Int64, T), DataAccessError> {

        let insert = table.insert(self.id <- item.id,
                                  self.name <- item.name,
                                  self.createdAt <- item.createdAt,
                                  self.updatedOn <- item.updatedOn)

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

    static func delete(item: ChatModel) -> Swift.Result<ChatModel, DataAccessError> {

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

    static func findChatWith(id: String) -> Swift.Result<T, DataAccessError> {

        var data: [T] = []

        guard let database = SQLiteDataStore.current.db else {
            return .failure(.connection)
        }
        do {
            let table = Self.table.filter(self.id == id)
            for t in try database.prepare(table) {
                data.append(.init(id: t[self.id],
                                  name: t[self.name],
                                  createdAt: t[self.createdAt],
                                  updatedOn: t[self.updatedOn]))
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

            for t in items {
                data.append(.init(id: t[self.id],
                                  name: t[self.name],
                                  createdAt: t[self.createdAt],
                                  updatedOn: t[self.updatedOn]))
            }
            return .success(data)
        } catch {
            return .failure(.underlying(error))
        }
    }
}
