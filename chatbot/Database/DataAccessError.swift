//
//  DataAccessError.swift
//  NoLonely
//
//  Created by Divyesh Vekariya on 11/02/22.
//

import Foundation

enum DataAccessError: Error {
    case connection
    case insert
    case delete
    case recordNotFound
    case underlying(Error)
}
