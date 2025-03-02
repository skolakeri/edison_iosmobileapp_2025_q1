import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ToDoListViewModel()
    
    var body: some View {
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
            
            
            List {
                ForEach(viewModel.filteredItems) { item in
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
                }
            }
            
            Spacer()
        }
        .onAppear() {
            viewModel.loadData()
        }
    }
}
