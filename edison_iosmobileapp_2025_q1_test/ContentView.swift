import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ToDoListViewModel()
    @State private var selectedItemForTags: ToDoItem? = nil
    @State private var datePickerItem: ToDoItem? = nil
    @State private var isAddingTask: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.1), .white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            NavigationStack {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("My Tasks")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                HStack {
                                    Text("\(viewModel.toDoItems.filter { !$0.isComplete }.count) remaining")
                                        .foregroundColor(.blue)
                                    Text("•")
                                    Text("\(viewModel.toDoItems.filter { $0.isComplete }.count) completed")
                                        .foregroundColor(.green)
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                    }
                    
                    if isAddingTask {
                        VStack(spacing: 12) {
                            
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                                TextField("Task title", text: $viewModel.inputTask)
                                    .font(.body)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            
                        
                            HStack {
                                Text("Priority:")
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                ForEach(TaskPriority.allCases, id: \.self) { priority in
                                    Button(action: {
                        
                                        viewModel.inputPriority = priority
                                        
                                    }) {
                                        VStack {
                                            Circle()
                                                .fill(priority.color)
                                                .frame(width: 16, height: 16)
                                            Text(priority.rawValue)
                                                .font(.caption)
                                        }
                                        .padding(8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(viewModel.inputPriority == priority ? priority.color : Color.clear, lineWidth: 2)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                            
                            
                            HStack {
                                Button(action: {
                                    withAnimation(.spring()) {
                                        isAddingTask = false
                                    }
                                }) {
                                    Text("Cancel")
                                        .foregroundColor(.red)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    viewModel.addItem()
                                    withAnimation {
                                        isAddingTask = false
                                    }
                                }) {
                                    Text("Add Task")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                }
                                .disabled(viewModel.inputTask.isEmpty)
                                .opacity(viewModel.inputTask.isEmpty ? 0.6 : 1)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.gray.opacity(0.2), radius: 3, x: 0, y: 2)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    } else {
                        Button(action: {
                            withAnimation(.spring()) {
                                isAddingTask = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("Add New Task")
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    
                    
                    HStack {
                        Toggle("Hide Completed Tasks", isOn: $viewModel.hideCompleted)
                            .onChange(of: viewModel.hideCompleted) {
                                viewModel.toggleHideCompleted()
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    
                    if !viewModel.filteredItems.isEmpty {
                        List {
                            ForEach(viewModel.filteredItems, id: \.id) { item in
                                VStack(alignment: .leading, spacing: 4) {
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                    
                                        HStack(alignment: .top) {
                                            Button(action: {
                                                withAnimation(.spring()) {
                                                    viewModel.toggleItem(item)
                                                }
                                            }) {
                                                Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                                                    .font(.system(size: 22))
                                                    .foregroundColor(item.isComplete ? .green : .gray)
                                            }
                                            .buttonStyle(BorderlessButtonStyle())

                                            if viewModel.editingItemId == item.id {
                                                TextField("", text: Binding(
                                                    get: { item.title },
                                                    set: { viewModel.updateItemText(item, $0) }
                                                ))
                                                .onSubmit { viewModel.onSubmit() }
                                                .font(.system(size: 17, weight: .medium))
                                            } else {
                                                Text(item.title)
                                                    .font(.system(size: 17, weight: .medium))
                                                    .strikethrough(item.isComplete)
                                                    .foregroundColor(item.isComplete ? .gray : .primary)
                                                    .onTapGesture {
                                                        withAnimation(.easeInOut(duration: 0.1)) {
                                                            viewModel.onTapItem(item)
                                                        }
                                                    }
                                            }
                                            
                                            Spacer()
                                            
                                            Text(item.priority.rawValue)
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(item.priority.color.opacity(0.2))
                                                .foregroundColor(item.priority.color)
                                                .clipShape(Capsule())
                                        }
                                        
                                        
                                        if !item.tags.isEmpty {
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 6) {
                                                    ForEach(item.tags, id: \.self) { tag in
                                                        Text(tag)
                                                            .font(.caption)
                                                            .padding(.horizontal, 8)
                                                            .padding(.vertical, 3)
                                                            .background(tagColor(for: tag))
                                                            .foregroundColor(.white)
                                                            .clipShape(Capsule())
                                                    }
                                                }
                                                .id(item.tags.hashValue)
                                            }
                                        }
                                        
                                        
                                        if let notificationDate = item.notificationDate {
                                            HStack(spacing: 4) {
                                                Image(systemName: "bell.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.blue)
                                                
                                                Text(formatDate(notificationDate))
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white)
                                            .shadow(color: Color(.systemGray4).opacity(0.5), radius: 2, x: 0, y: 1)
                                    )
                                    
                                    
                                    HStack(spacing: 12) {
                                        Spacer()
                                        
                                        
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                if item.notificationDate != nil {
                                                    viewModel.setNotification(for: item, date: nil)
                                                } else {
                                                    showDatePicker(for: item)
                                                }
                                            }
                                        } label: {
                                            Label(
                                                item.notificationDate != nil ? "Remove Reminder" : "Add Reminder",
                                                systemImage: item.notificationDate != nil ? "bell.slash" : "bell"
                                            )
                                            .font(.caption)
                                            .foregroundColor(item.notificationDate != nil ? .red.opacity(0.8) : .blue)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                        
                                        
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                selectedItemForTags = item
                                            }
                                        } label: {
                                            Label("Tags", systemImage: "tag")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                        
                                        
                                        Button {
                                            withAnimation(.easeInOut) {
                                                viewModel.removeItem(item)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.top, 4)
                                    .contentShape(Rectangle())
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 6)
                                .contextMenu {
                                    Button(action: {
                                        withAnimation {
                                            viewModel.toggleItem(item)
                                        }
                                    }) {
                                        Label(
                                            item.isComplete ? "Mark as Incomplete" : "Mark as Complete",
                                            systemImage: item.isComplete ? "circle" : "checkmark.circle"
                                        )
                                    }
                                    
                                    Button(action: {
                                        withAnimation {
                                            selectedItemForTags = item
                                        }
                                    }) {
                                        Label("Manage Tags", systemImage: "tag")
                                    }
                                    
                                    if !item.isComplete {
                                        Button(action: {
                                            withAnimation {
                                                showDatePicker(for: item)
                                            }
                                        }) {
                                            Label("Set Reminder", systemImage: "bell")
                                        }
                                    }
                                    
                                    Button(role: .destructive, action: {
                                        withAnimation {
                                            viewModel.removeItem(item)
                                        }
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    } else {
                        
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Image(systemName: viewModel.searchQuery.isEmpty ? "checkmark.circle" : "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.blue.opacity(0.7))
                            
                            Text(viewModel.searchQuery.isEmpty ?
                                "No tasks yet" :
                                "No matches found")
                                .font(.title2)
                                .fontWeight(.medium)
                            
                            Text(viewModel.searchQuery.isEmpty ?
                                "Tap the + button to add your first task" :
                                "Try a different search term")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, 40)
                        
                        Spacer()
                    }
                }
                .onAppear {
                    viewModel.loadData()
                    viewModel.requestNotificationPermission()
                }
                .searchable(text: $viewModel.searchQuery, prompt: "Search tasks")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(item: $selectedItemForTags) { item in
                    NavigationView {
                        TagManagementView(
                            viewModel: viewModel,
                            itemId: item.id,
                            onDismiss: { selectedItemForTags = nil }
                        )
                        .navigationTitle("Manage Tags")
                        .navigationBarItems(
                            trailing: Button("Done") { selectedItemForTags = nil }
                        )
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    selectedItemForTags = nil
                                }
                            }
                        }
                    }
                }
                .sheet(item: $datePickerItem) { item in
                    NotificationDatePicker(item: item) { date in
                        if let date = date {
                            viewModel.setNotification(for: item, date: date)
                            viewModel.sortItems()
                        }
                        datePickerItem = nil
                    }
                }
            }
        }
    }
    
    private func showDatePicker(for item: ToDoItem) {
        datePickerItem = item
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func tagColor(for tag: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink]
        let hash = abs(tag.hashValue)
        return colors[hash % colors.count]
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
    let onDismiss: () -> Void
    @State private var newTag: String = ""
    @State private var showAddedAnimation: Bool = false
    @State private var lastAddedTag: String = ""
    @Environment(\.dismiss) private var dismiss
    
    private var item: ToDoItem? {
        viewModel.toDoItems.first(where: { $0.id == itemId })
    }
    
    private func tagColor(for tag: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink]
        let hash = abs(tag.hashValue)
        return colors[hash % colors.count]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let item = item {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(1)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Current tags section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Tags")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let currentItem = item, !currentItem.tags.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(currentItem.tags, id: \.self) { tag in
                                    TagPillView(tag: tag, color: tagColor(for: tag)) {
                                        withAnimation {
                                            viewModel.removeTagFromTask(itemId, tag: tag)
                                        }
                                    }
                                    .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .id(currentItem.tags.hashValue)
                        } else {
                            Text("No tags yet")
                                .italic()
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Add New Tag")
                            .font(.headline)
                        
                        HStack {
                            TextField("Enter tag name", text: $newTag)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .submitLabel(.done)
                                .onSubmit { addTag() }
                            
                            Button(action: addTag) {
                                Image(systemName: "plus")
                                    .padding(12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(newTag.isEmpty)
                            .opacity(newTag.isEmpty ? 0.5 : 1)
                        }
                        
                        if showAddedAnimation {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Added \"\(lastAddedTag)\"")
                                    .foregroundColor(.green)
                            }
                            .padding(.vertical, 4)
                            .transition(.opacity)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Suggested Tags")
                                .font(.headline)
                            
                            
                            Text("(\(viewModel.availableTags.count) available)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                
                        if viewModel.availableTags.isEmpty {
                            Button("Initialize Default Tags") {
                                viewModel.availableTags = ["Work", "Personal", "Home", "Shopping", "Urgent", "Later"]
                                viewModel.objectWillChange.send()
                            }
                            .padding(.vertical, 4)
                            .foregroundColor(.blue)
                        }
                        
                        if let currentItem = item {
                            let suggestions = viewModel.availableTags.filter { !currentItem.tags.contains($0) }
                            
                            if !suggestions.isEmpty {
                                FlowLayout(spacing: 8) {
                                    ForEach(suggestions, id: \.self) { tag in
                                        Button(action: {
                                            withAnimation {
                                                viewModel.addTagToTask(itemId, tag: tag)
                                                lastAddedTag = tag
                                                showAddedAnimation = true
                                            }
                                        }) {
                                            Text(tag)
                                                .font(.callout)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.gray.opacity(0.15))
                                                .cornerRadius(16)
                                                .foregroundColor(.primary)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                                .id(suggestions.hashValue)
                            } else {
                                Text("No suggestions available")
                                    .italic()
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 24)
            }
            
            Divider()
            
            Button(action: {
                onDismiss()
                dismiss()
            }) {
                Text("Done")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            }
        }
        .onChange(of: showAddedAnimation) {
            if showAddedAnimation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showAddedAnimation = false
                    }
                }
            }
        }
        .onAppear {
            
            if viewModel.availableTags.isEmpty {
                viewModel.availableTags = ["Work", "Personal", "Home", "Shopping", "Urgent", "Later"]
                viewModel.objectWillChange.send()
            }
        }
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

struct FlowLayout: Layout {
    var spacing: CGFloat = 10
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        var totalHeight: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if lineWidth + size.width > maxWidth {
                totalHeight += lineHeight + spacing
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
        }
        
        totalHeight += lineHeight
        
        return CGSize(width: maxWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        var lineStart: CGFloat = bounds.minX
        var y = bounds.minY
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if lineWidth + size.width > bounds.width {
                y += lineHeight + spacing
                lineWidth = 0
                lineHeight = 0
                lineStart = bounds.minX
            }
            
            let x = lineStart + lineWidth
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            
            lineWidth += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}


struct TagPillView: View {
    let tag: String
    let color: Color
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.callout)
                .lineLimit(1)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.2))
        .foregroundColor(color)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.5), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
