//
//  ToDoListViewModel.swift
//  edison_iosmobileapp_2025_q1_test
//
//  Created by Sunjay Kolakeri on 3/1/25.
//

import Foundation
import SwiftUI
import Combine

class ToDoListViewModel: ObservableObject {
    
    private let repository: ToDoListRepository = ToDoListRepositoryImpl()
    private let notificationManager = NotificationManager.shared
    
    @Published var editingItemId: UUID?
    @Published var inputTask: String = ""
    @Published var inputPriority: TaskPriority = .medium
    @Published var toDoItems: [ToDoItem] = []
    @Published var hideCompleted: Bool = false
    @Published var hasNotificationPermission: Bool = false
    @Published var searchQuery: String = ""
    @Published var availableTags: [String] = ["Work", "Personal", "Home", "Shopping", "Urgent", "Later"]
    @Published var tagInput: String = ""
    
    func addTagToTask(_ itemId: UUID, tag: String) {
        if let index = toDoItems.firstIndex(where: { $0.id == itemId }) {
            // Don't add if tag already exists or is empty
            let trimmedTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedTag.isEmpty || toDoItems[index].tags.contains(trimmedTag) {
                return
            }
            
            // Add tag to item
            toDoItems[index].tags.append(trimmedTag)
            
            // Add to available tags if it's new
            if !availableTags.contains(trimmedTag) {
                availableTags.append(trimmedTag)
                availableTags.sort() // Keep them sorted
            }
            
            objectWillChange.send()
            repository.saveToDoItems(toDoItems)
        }
    }
    
    func removeTagFromTask(_ itemId: UUID, tag: String) {
        if let index = toDoItems.firstIndex(where: { $0.id == itemId }) {
            
            var updatedTags = toDoItems[index].tags
            updatedTags.removeAll { $0 == tag }
            toDoItems[index].tags = updatedTags
            
            
            objectWillChange.send()
            
            repository.saveToDoItems(toDoItems)
        }
    }
    
    var filteredItems: [ToDoItem] {
        var result = toDoItems
        
        if hideCompleted {
            result = result.filter { !$0.isComplete }
        }
        
        if !searchQuery.isEmpty {
            result = result.filter {
                $0.title.lowercased().contains(searchQuery.lowercased())
            }
        }
        
        let uniqueIds = Set(result.map { $0.id })
        result = uniqueIds.compactMap { id in
            result.first { $0.id == id }
        }
        
        return result
    }
    
    func addItem() {
        if inputTask.isEmpty { return }
        toDoItems.append(ToDoItem(title: inputTask, priority: inputPriority))
        inputTask = ""
        inputPriority = .medium
        sortItems()
        repository.saveToDoItems(toDoItems)
    }
    
    func setNotification(for item: ToDoItem, date: Date?) {
        if let index = toDoItems.firstIndex(where: { $0.id == item.id }) {
            
            if let notificationId = toDoItems[index].notificationId {
                notificationManager.cancelNotification(identifier: notificationId)
            }
            
            
            if date == nil {
                toDoItems[index].notificationDate = nil
                toDoItems[index].notificationId = nil
            } else {
                
                toDoItems[index].notificationDate = date
                let notificationId = notificationManager.scheduleNotification(for: toDoItems[index])
                toDoItems[index].notificationId = notificationId
            }
            
            repository.saveToDoItems(toDoItems)
        }
    }
    
    func removeItem(_ item: ToDoItem) {
        if let index = toDoItems.firstIndex(where: { $0.id == item.id }) {
            toDoItems.remove(at: index)
            repository.saveToDoItems(toDoItems)
        }
    }
    
    func toggleItem(_ item: ToDoItem) {
        if let index = toDoItems.firstIndex(where: { $0.id == item.id }) {
            toDoItems[index].isComplete.toggle()
            
            if toDoItems[index].isComplete, let notificationId = toDoItems[index].notificationId {
                notificationManager.cancelNotification(identifier: notificationId)
            }
            
            sortItems()
            repository.saveToDoItems(toDoItems)
        }
    }
    
    func requestNotificationPermission() {
        notificationManager.requestAuthorization { granted in
            self.hasNotificationPermission = granted
        }
    }
    
    func updateItemText(_ item: ToDoItem, _ newValue: String) {
        if let index = toDoItems.firstIndex(where: { $0.id == item.id }) {
            toDoItems[index].title = newValue
            repository.saveToDoItems(toDoItems)
        }
    }
    
    func updateItemPriority(_ item: ToDoItem, _ newPriority: TaskPriority) {
        if let index = toDoItems.firstIndex(where: { $0.id == item.id }) {
            toDoItems[index].priority = newPriority
            sortItems()
            repository.saveToDoItems(toDoItems)
        }
    }
    
    func toggleHideCompleted() {
        hideCompleted.toggle()
        UserDefaults.standard.set(hideCompleted, forKey: "hideCompleted")
    }
    
    func loadData() {
        toDoItems = repository.loadToDoItems()
        hideCompleted = UserDefaults.standard.bool(forKey: "hideCompleted")
        checkNotificationPermission()
        sortItems()
        
        for (index, item) in toDoItems.enumerated() {
            if let _ = item.notificationDate, !item.isComplete {
                let id = notificationManager.scheduleNotification(for: item)
                toDoItems[index].notificationId = id
            }
        }
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasNotificationPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func onSubmit() {
        editingItemId = nil
        repository.saveToDoItems(toDoItems)
    }
    
    func onTapItem(_ item: ToDoItem) {
        editingItemId = item.id
        repository.saveToDoItems(toDoItems)
    }
    
    private func sortItems() {
        toDoItems.sort { item1, item2 in
            if item1.isComplete != item2.isComplete {
                return !item1.isComplete
            }
            return item1.priority.sortOrder < item2.priority.sortOrder
        }
    }
    
}

