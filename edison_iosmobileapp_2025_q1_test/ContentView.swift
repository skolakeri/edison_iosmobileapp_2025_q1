//
//  ContentView.swift
//  edison_iosmobileapp_2025_q1_test
//
//  Created by Sunjay Kolakeri on 2/26/25.
//

import SwiftUI

struct ToDoItem: Identifiable {
    var id: UUID = UUID()
    var title: String
    var isComplete: Bool = false
}

struct ContentView: View {
    @State private var editingItemId: UUID?
    @State private var inputTask: String = ""
    @State private var toDoItems: [ToDoItem] = [ToDoItem(title: "test")]
    
    var body: some View {
        VStack {
            HStack {
                TextField("Input task", text: $inputTask)
                Button("Add") {
                    if inputTask.isEmpty { return }
                    toDoItems.append(ToDoItem(title: inputTask))
                    inputTask = ""
                }
            }
            .padding([.leading, .trailing, .bottom], 15)
            .background(Color.blue.opacity(0.2))
            
            List {
                ForEach(toDoItems) { item in
                    HStack {
                        Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                            .onTapGesture {
                                if let index = toDoItems.firstIndex(where: { $0.id == item.id }) {
                                    toDoItems[index].isComplete.toggle()
                                }
                            }
                        if editingItemId == item.id {
                            TextField("", text: Binding(
                                get: { item.title },
                                set: { newValue in
                                    if let index = toDoItems.firstIndex(where: { $0.id == item.id }) {
                                        toDoItems[index].title = newValue
                                    }
                                }
                            ))
                            .onSubmit {
                                editingItemId = nil
                            }
                            
                        } else {
                            Text(item.title)
                                .strikethrough(item.isComplete)
                                .onTapGesture {
                                    editingItemId = item.id
                                }
                        }
                        Spacer()
                        Button {
                            if let index = toDoItems.firstIndex(where: { $0.id == item.id }) {
                                toDoItems.remove(at: index)
                            }
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
