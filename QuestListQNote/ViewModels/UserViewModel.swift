import Foundation
import CoreData
import SwiftUI

class UserViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var currentXP: Int = 0
    @Published var level: Int = 1
    @Published var streak: Int = 0
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchUser()
    }
    
    func fetchUser() {
        let request = NSFetchRequest<User>(entityName: "User")
        
        do {
            let users = try viewContext.fetch(request)
            if let user = users.first {
                self.currentUser = user
                self.currentXP = Int(user.currentXP)
                self.level = Int(user.level)
                self.streak = Int(user.streak)
            }
        } catch {
            print("Error fetching user: \(error)")
        }
    }
    
    func createUser(name: String, avatar: String) {
        // Check if user already exists
        let request = NSFetchRequest<User>(entityName: "User")
        do {
            let users = try viewContext.fetch(request)
            if let existingUser = users.first {
                // Update existing user
                existingUser.name = name
                existingUser.avatar = avatar
                self.currentUser = existingUser
            } else {
                // Create new user
                let user = User(context: viewContext)
                user.id = UUID()
                user.name = name
                user.avatar = avatar
                user.currentXP = 0
                user.level = 1
                user.streak = 0
                user.unlockedThemes = []
                self.currentUser = user
            }
            
            // Save context immediately
            try viewContext.save()
            
            // Update published properties
            self.currentXP = Int(self.currentUser?.currentXP ?? 0)
            self.level = Int(self.currentUser?.level ?? 1)
            self.streak = Int(self.currentUser?.streak ?? 0)
        } catch {
            print("Error creating/updating user: \(error)")
        }
    }
    
    func addXP(_ amount: Int) {
        guard let user = currentUser else { return }
        
        let newXP = currentXP + amount
        let xpForNextLevel = level * 100
        
        if newXP >= xpForNextLevel {
            levelUp()
            currentXP = newXP - xpForNextLevel
        } else {
            currentXP = newXP
        }
        
        user.currentXP = Int32(currentXP)
        user.level = Int32(level)
        
        saveContext()
    }
    
    private func levelUp() {
        level += 1
        // Here you can add logic for unlocking new content
    }
    
    func updateStreak() {
        guard let user = currentUser else { return }
        streak += 1
        user.streak = Int32(streak)
        saveContext()
    }
    
     func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
} 
