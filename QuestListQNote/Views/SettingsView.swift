import SwiftUI
import CoreData
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingResetAlert = false
    @State private var showingPrivacyPolicy = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: scene)
                        }
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Rate App")
                        }
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://www.termsfeed.com/live/acda9bab-8c75-45cf-854b-883fa37a466d") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.blue)
                            Text("Privacy Policy")
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                            Text("Reset All Data")
                        }
                    }
                }
            }
            .alert("Reset All Data", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will delete all your quests, challenges, and progress. This action cannot be undone.")
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
        }
    }
    
    private func resetAllData() {
        // Reset UserDefaults
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        
        // Reset Core Data
        let context = PersistenceController.shared.container.viewContext
        
        // Delete all entities
        let entities = PersistenceController.shared.container.managedObjectModel.entities
        entities.forEach { entity in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity.name!)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Error deleting \(entity.name!): \(error)")
            }
        }
        
        // Save context
        do {
            try context.save()
        } catch {
            print("Error saving context after reset: \(error)")
        }
        
        // Restart app
        exit(0)
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                        .foregroundColor(.secondary)
                    
                    Group {
                        Text("1. Data Collection")
                            .font(.headline)
                        Text("QuestList collects and stores your quests, challenges, and progress locally on your device. We do not collect any personal information or share your data with third parties.")
                        
                        Text("2. Data Storage")
                            .font(.headline)
                        Text("All your data is stored locally on your device using Core Data. You can reset all data at any time through the Settings menu.")
                        
                        Text("3. Permissions")
                            .font(.headline)
                        Text("QuestList does not require any special permissions to function. All features work without access to your personal data or device features.")
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

#Preview {
    SettingsView()
} 
