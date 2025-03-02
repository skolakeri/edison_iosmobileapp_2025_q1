import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ToDoListViewModel()
    @State private var selectedItemForTags: ToDoItem? = nil
    
    var body: some View {
            NavigationStack{
                VStack {
                    
                    VStack(spacing: 10) {
                        TextField("Input task", text: $viewModel.inputTask)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        HStack {
                            Text("Priority:")
                            Picker("Priority", selection: $viewModel.inputPriority) {
                                ForEach(TaskPriority.allCases, id: \.self) { priority in
                                    Label(
                                        priority.rawValue,
                                        systemImage: priority.icon
                                    )
                                    .foregroundColor(priority.color)
                                    .tag(priority)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            Spacer()
                            
                            Button("Add") {
                                viewModel.addItem()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    HStack {
                        Toggle("Hide Completed Tasks", isOn: $viewModel.hideCompleted)
                            .onChange(of: viewModel.hideCompleted) {
                                viewModel.toggleHideCompleted()
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    List {
                        ForEach(viewModel.filteredItems, id: \.id) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                
                                HStack {
                                    Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                                        .onTapGesture {
                                            viewModel.toggleItem(item)
                                        }
                                    
                                    if viewModel.editingItemId == item.id {
                                        TextField("", text: Binding(
                                            get: { item.title },
                                            set: { viewModel.updateItemText(item, $0) }
                                        ))
                                        .onSubmit { viewModel.onSubmit() }
                                    } else {
                                        Text(item.title)
                                            .strikethrough(item.isComplete)
                                            .onTapGesture { viewModel.onTapItem(item) }
                                    }
                                    
                                    Image(systemName: item.priority.icon)
                                        .foregroundColor(item.priority.color)
                                    
                                    Spacer()
                                    
                                    Menu {
                                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                                            Button(action: { viewModel.updateItemPriority(item, priority) }) {
                                                Label(priority.rawValue, systemImage: priority.icon)
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "flag")
                                    }
                                    
                                    Button {
                                        viewModel.removeItem(item)
                                    } label: {
                                        Image(systemName: "minus.circle")
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                                
                                
                                if !item.isComplete {
                                    HStack {
                                        if let notificationDate = item.notificationDate {
                                            Label(formatDate(notificationDate), systemImage: "bell.fill")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                            
                                            Spacer()
                                            
                                            Button {
                                                viewModel.setNotification(for: item, date: nil)
                                            } label: {
                                                Image(systemName: "bell.slash")
                                                    .font(.caption)
                                            }
                                        } else {
                                            Button {
                                                showDatePicker(for: item)
                                            } label: {
                                                Label("Set Reminder", systemImage: "bell")
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                            }
                                            .disabled(!viewModel.hasNotificationPermission)
                                        }
                                    }
                                    .padding(.leading, 30)
                                }
                                
                                
                                if !item.tags.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(item.tags, id: \.self) { tag in
                                                Text(tag)
                                                    .font(.caption)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 2)
                                                    .background(Color.blue.opacity(0.2))
                                                    .cornerRadius(10)
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                        .id(item.tags.hashValue)
                                    }
                                    .padding(.leading, 30)
                                }

                                
                                Button {
                                    selectedItemForTags = item
                                } label: {
                                    Label("Manage Tags", systemImage: "tag")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                .padding(.leading, 30)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    if viewModel.filteredItems.isEmpty && !viewModel.searchQuery.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text("No tasks match your search")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
                    }
                    
            }
        
        }
        .onAppear {
            viewModel.loadData()
            viewModel.requestNotificationPermission()
        }
        .navigationTitle("ToDo List")
        .searchable(text: $viewModel.searchQuery, prompt: "Search tasks")
        .sheet(item: $selectedItemForTags) { item in
            NavigationView {
                TagManagementView(viewModel: viewModel, itemId: item.id)
                    .navigationTitle("Manage Tags")
                    .navigationBarItems(
                        trailing: Button("Done") { selectedItemForTags = nil }
                    )
            }
        }
        
    }
    
    
    @State private var datePickerItem: ToDoItem? = nil
    
    private func showDatePicker(for item: ToDoItem) {
        datePickerItem = item
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct NotificationDatePicker: View {
    let item: ToDoItem
    let onSave: (Date?) -> Void
    
    @State private var selectedDate = Date().addingTimeInterval(3600)
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select reminder time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                
                Text("Reminder for: \(item.title)")
                    .font(.headline)
                    .padding()
            }
            .navigationTitle("Set Reminder")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { onSave(selectedDate) }
            )
        }
    }
}

struct TagManagementView: View {
    @ObservedObject var viewModel: ToDoListViewModel
    let itemId: UUID
    @State private var newTag: String = ""
    @State private var showAddedAnimation: Bool = false
    @State private var lastAddedTag: String = ""
    
    private var item: ToDoItem? {
        viewModel.toDoItems.first(where: { $0.id == itemId })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Tags")
                .font(.headline)
            
            if let item = item, !item.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(item.tags, id: \.self) { tag in
                            TagView(tag: tag) {
                                withAnimation(.spring()) {
                                    viewModel.removeTagFromTask(itemId, tag: tag)
                                }
                            }
                            .transition(.scale)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .id(item.tags.hashValue) 
            } else {
                Text("No tags yet")
                    .foregroundColor(.gray)
                    .italic()
                    .padding(.vertical, 8)
            }
            
            Divider()
            
            HStack {
                TextField("Add tag", text: $newTag)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        addTag()
                    }
                
                Button(action: addTag) {
                    Text("Add")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(newTag.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .disabled(newTag.isEmpty || item == nil)
            }
            
            if showAddedAnimation {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Added tag: \"\(lastAddedTag)\"")
                        .foregroundColor(.green)
                }
                .padding(.vertical, 4)
                .transition(.opacity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showAddedAnimation = false
                        }
                    }
                }
            }
            
            Divider()
            
            Text("Suggested Tags")
                .font(.headline)
                .padding(.top, 8)
            
            if let currentItem = item, viewModel.availableTags.filter({ !currentItem.tags.contains($0) }).isEmpty {
                Text("No more suggestions")
                    .foregroundColor(.gray)
                    .italic()
                    .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if let currentItem = item {
                            ForEach(viewModel.availableTags.filter { !currentItem.tags.contains($0) }, id: \.self) { tag in
                                Button(action: {
                                    withAnimation {
                                        viewModel.addTagToTask(itemId, tag: tag)
                                        lastAddedTag = tag
                                        showAddedAnimation = true
                                    }
                                }) {
                                    Text(tag)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(12)
                                        .foregroundColor(.primary)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty {
            withAnimation {
                viewModel.addTagToTask(itemId, tag: trimmedTag)
                lastAddedTag = trimmedTag
                showAddedAnimation = true
                newTag = ""
            }
        }
    }
}

struct TagView: View {
    let tag: String
    let onRemove: () -> Void
    @State private var isPressed: Bool = false
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
                .padding(.leading, 8)
                .padding(.trailing, 0)
                .padding(.vertical, 4)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
            }
            .padding(.trailing, 8)
        }
        .background(isPressed ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
        .cornerRadius(12)
        .onTapGesture {
            
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation {
                    isPressed = false
                }
            }
        }
    }
}
