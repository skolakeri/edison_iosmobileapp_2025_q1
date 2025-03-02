import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ToDoListViewModel()
    
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
        .sheet(item: $datePickerItem) { item in
            NotificationDatePicker(item: item) { date in
                if let date = date {
                    viewModel.setNotification(for: item, date: date)
                }
                datePickerItem = nil
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
