//
//  ToDoItem.swift
//  edison_iosmobileapp_2025_q1_test
//
//  Created by Sunjay Kolakeri on 3/1/25.
//

import Foundation

struct ToDoItem: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var isComplete: Bool = false
}


