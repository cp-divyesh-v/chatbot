//
//  SQLiteDataStore.swift
//  NoLonely
//
//  Created by Divyesh Vekariya on 11/02/22.
//

import Foundation
import SQLite

class SQLiteDataStore {

    let db: Connection?
    static let current = SQLiteDataStore()

    private init() {
        defer {
            if let db = db {
                do {
                    try db.execute("PRAGMA foreign_keys = ON;")
                } catch {
                    print(error)
                }
            }
        }

        if let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

            do {
                db = try Connection("\(docDir)/NoLonely.sqlite3")
                print("SQLiteDataStore init successfully at: \(docDir) ")
            } catch {
                db = nil
                print("SQLiteDataStore init error: \(error)")
            }
        } else {
            db = nil
        }
    }

    func createTables() throws {
        try ChatMessageDataHelper.createTable()
    }
}

protocol DataHelperProtocol {
    associatedtype T
    static func createTable() throws
    static func insert(item: T) -> Swift.Result<(Int64, T), DataAccessError>
    static func delete(item: T) -> Swift.Result<T, DataAccessError>
    static func findAll() -> Swift.Result<[T], DataAccessError>
}
