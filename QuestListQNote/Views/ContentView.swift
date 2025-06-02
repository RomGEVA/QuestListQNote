import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var userViewModel: UserViewModel
    @StateObject private var questViewModel: QuestViewModel
    @State private var showingAddQuest = false
    @State private var selectedTab = 0
    
    init(context: NSManagedObjectContext) {
        _userViewModel = StateObject(wrappedValue: UserViewModel(context: context))
        _questViewModel = StateObject(wrappedValue: QuestViewModel(context: context))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                VStack {
                    XPBarView(currentXP: userViewModel.currentXP, level: userViewModel.level)
                        .padding()
                    
                    List {
                        ForEach(questViewModel.quests) { quest in
                            QuestRowView(quest: quest) {
                                questViewModel.completeQuest(quest)
                                userViewModel.addXP(Int(quest.xpValue))
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                questViewModel.deleteQuest(questViewModel.quests[index])
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                .background(content: {
                    BackgroundView()
                })
                .navigationTitle("Today's Quests")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddQuest = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddQuest) {
                AddQuestView(questViewModel: questViewModel)
            }
            .tabItem {
                Label("Quests", systemImage: "list.bullet")
            }
            .tag(0)
            
            NavigationView {
                DailyChallengesView(questViewModel: questViewModel)
                    .navigationTitle("Daily Challenges")
                    .background(content: {
                        BackgroundView()
                    })
            }
            .tabItem {
                Label("Challenges", systemImage: "star.fill")
            }
            .tag(1)
            
            NavigationView {
                ProfileView(userViewModel: userViewModel)
                    .navigationTitle("Profile")
                    .background(content: {
                        BackgroundView()
                    })
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(2)
            
            NavigationView {
                SettingsView()
                    .background(content: {
                        BackgroundView()
                    })
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(3)
        }
        .animation(.bouncy, value: selectedTab)
        .environment(\.managedObjectContext, viewContext)
    }
}

struct XPBarView: View {
    let currentXP: Int
    let level: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Level \(level)")
                    .font(.headline)
                Spacer()
                Text("\(currentXP) XP")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 8)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(currentXP) / CGFloat(level * 100) * geometry.size.width, geometry.size.width), height: 8)
                        .foregroundColor(.blue)
                }
                .cornerRadius(4)
            }
            .frame(height: 8)
        }
    }
}

struct QuestRowView: View {
    let quest: Quest
    let onComplete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(quest.title ?? "")
                    .font(.headline)
                if let description = quest.questDescription {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                HStack {
                    if let category = quest.category {
                        Text(category)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                    Text("\(quest.xpValue) XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if !quest.isCompleted {
                Button(action: onComplete) {
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView(context: PersistenceController.shared.container.viewContext)
} 
