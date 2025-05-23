import SwiftUI

struct AddQuestView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var questViewModel: QuestViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var xpValue = 10
    @State private var category = "General"
    @State private var deadline: Date = Date()
    @State private var hasDeadline = false
    
    let categories = ["General", "Work", "Study", "Health", "Personal"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Quest Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                
                Section(header: Text("XP Reward")) {
                    Stepper("XP: \(xpValue)", value: $xpValue, in: 5...100, step: 5)
                }
                
                Section(header: Text("Deadline")) {
                    Toggle("Set Deadline", isOn: $hasDeadline)
                    if hasDeadline {
                        DatePicker("Deadline", selection: $deadline, displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("New Quest")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Add") {
                    addQuest()
                }
                .disabled(title.isEmpty)
            )
            .background(content: {
                BackgroundView()
            })
        }
    }
    
    private func addQuest() {
        questViewModel.addQuest(
            title: title,
            description: description.isEmpty ? nil : description,
            xpValue: xpValue,
            category: category,
            deadline: hasDeadline ? deadline : nil
        )
        dismiss()
    }
}

#Preview {
    AddQuestView(questViewModel: QuestViewModel(context: PersistenceController.shared.container.viewContext))
} 
