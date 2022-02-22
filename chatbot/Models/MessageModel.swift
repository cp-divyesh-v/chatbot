//
//  MessageModel.swift
//  chatbot
//
//  Created by Divyesh Vekariya on 14/02/22.
//

import Foundation

struct MessageModel {
    let id: String
    let isUserMessage: Bool
    let sentTime: Int
    let message: String
}

struct ChatModel {
    let id: String
    let name: String
    let messages: [MessageModel]
    let createdAt: Date
    let updatedOn: Date
}
