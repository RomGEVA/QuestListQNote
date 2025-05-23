import SwiftUI

struct ProfileView: View {
    @ObservedObject var userViewModel: UserViewModel
    @StateObject private var themeManager = ThemeManager()
    @State private var showingThemePicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Avatar and Name
                VStack {
                    if let avatar = userViewModel.currentUser?.avatar {
                        Image(avatar)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(themeManager.currentTheme.primaryColor, lineWidth: 3))
                    }
                    
                    Text(userViewModel.currentUser?.name ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding()
                
                // Stats Card
                VStack(spacing: 15) {
                    StatRow(title: "Current Level", value: "\(userViewModel.level)")
                    StatRow(title: "Total XP", value: "\(userViewModel.currentXP)")
                    StatRow(title: "Current Streak", value: "\(userViewModel.streak) days")
                }
                .padding()
                .background(themeManager.currentTheme.backgroundColor)
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                // Achievements
                VStack(alignment: .leading, spacing: 10) {
                    Text("Achievements")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            AchievementCard(
                                title: "First Quest",
                                description: "Complete your first quest",
                                isUnlocked: userViewModel.level > 1,
                                theme: themeManager.currentTheme
                            )
                            
                            AchievementCard(
                                title: "Quest Master",
                                description: "Complete 10 quests",
                                isUnlocked: userViewModel.level > 5,
                                theme: themeManager.currentTheme
                            )
                            
                            AchievementCard(
                                title: "Streak Warrior",
                                description: "Maintain a 7-day streak",
                                isUnlocked: userViewModel.streak >= 7,
                                theme: themeManager.currentTheme
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Theme Settings
                Button(action: { showingThemePicker = true }) {
                    HStack {
                        Image(systemName: "paintbrush.fill")
                        Text("Change Theme")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeManager.currentTheme.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingThemePicker) {
            ThemePickerView()
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(themeManager.currentTheme.secondaryColor)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.currentTheme.primaryColor)
        }
    }
}

struct AchievementCard: View {
    let title: String
    let description: String
    let isUnlocked: Bool
    let theme: AppTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: isUnlocked ? "trophy.fill" : "trophy")
                .font(.title)
                .foregroundColor(isUnlocked ? .yellow : theme.secondaryColor)
            
            Text(title)
                .font(.headline)
                .foregroundColor(theme.primaryColor)
            
            Text(description)
                .font(.caption)
                .foregroundColor(theme.secondaryColor)
        }
        .frame(width: 150)
        .padding()
        .background(theme.backgroundColor)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

struct ThemePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        NavigationView {
            List(AppTheme.allCases, id: \.self) { theme in
                Button(action: { 
                    themeManager.currentTheme = theme
                }) {
                    HStack {
                        Text(theme.rawValue)
                        Spacer()
                        if theme == themeManager.currentTheme {
                            Image(systemName: "checkmark")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                    }
                }
                .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            .navigationTitle("Choose Theme")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

#Preview {
    ProfileView(userViewModel: UserViewModel(context: PersistenceController.shared.container.viewContext))
} 