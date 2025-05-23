import Foundation
import CoreData
import SwiftUI

class QuestViewModel: ObservableObject {
    @Published var quests: [Quest] = []
    @Published var dailyChallenges: [Challenge] = []
    
     let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchQuests()
        checkAndUpdateChallenges()
    }
    
    func fetchQuests() {
        let request = NSFetchRequest<Quest>(entityName: "Quest")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Quest.date, ascending: true)]
        
        do {
            quests = try viewContext.fetch(request)
        } catch {
            print("Error fetching quests: \(error)")
        }
    }
    
    func addQuest(title: String, description: String?, xpValue: Int, category: String?, deadline: Date?) {
        let quest = Quest(context: viewContext)
        quest.id = UUID()
        quest.title = title
        quest.questDescription = description
        quest.xpValue = Int32(xpValue)
        quest.category = category
        quest.date = deadline ?? Date()
        quest.isCompleted = false
        
        do {
            try viewContext.save()
            fetchQuests()
            checkAndUpdateChallenges()
        } catch {
            print("Error saving quest: \(error)")
        }
    }
    
    func completeQuest(_ quest: Quest) {
        quest.isCompleted = true
        
        do {
            try viewContext.save()
            fetchQuests()
            checkAndUpdateChallenges()
        } catch {
            print("Error completing quest: \(error)")
        }
    }
    
    func deleteQuest(_ quest: Quest) {
        viewContext.delete(quest)
        
        do {
            try viewContext.save()
            fetchQuests()
            checkAndUpdateChallenges()
        } catch {
            print("Error deleting quest: \(error)")
        }
    }
    
    private func generateDailyChallenges() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Challenge.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
            
            let challenges = [
                ("Complete 3 quests today", 50),
                ("Finish all morning quests", 75),
                ("Maintain a 3-day streak", 100),
                ("Complete 5 quests in one day", 150),
                ("Complete quests from 3 different categories", 125),
                ("Complete a high-priority quest", 80),
                ("Complete all quests before noon", 200),
                ("Complete a quest with 50+ XP reward", 100),
                ("Complete 2 quests in a row", 60),
                ("Complete a quest with a deadline", 90)
            ]
            
            let now = Date()
            for (description, reward) in challenges {
                let challenge = Challenge(context: viewContext)
                challenge.id = UUID()
                challenge.challengeDescription = description
                challenge.rewardXP = Int32(reward)
                challenge.isCompleted = false
                challenge.date = now
            }
            
            try viewContext.save()
            fetchDailyChallenges()
        } catch {
            print("Error generating challenges: \(error)")
        }
    }
    
    func fetchDailyChallenges() {
        let request = NSFetchRequest<Challenge>(entityName: "Challenge")
        
        do {
            dailyChallenges = try viewContext.fetch(request)
        } catch {
            print("Error fetching challenges: \(error)")
        }
    }
    
    func completeChallenge(_ challenge: Challenge) {
        challenge.isCompleted = true
        
        do {
            try viewContext.save()
            fetchDailyChallenges()
        } catch {
            print("Error completing challenge: \(error)")
        }
    }
    
    func checkAndUpdateChallenges() {
        let calendar = Calendar.current
        let now = Date()
        
        if dailyChallenges.isEmpty {
            generateDailyChallenges()
            return
        }
        
        if let firstChallenge = dailyChallenges.first,
           let lastUpdateDate = firstChallenge.date,
           !calendar.isDate(lastUpdateDate, inSameDayAs: now) {
            generateDailyChallenges()
        }
        
        for challenge in dailyChallenges {
            if !challenge.isCompleted {
                switch challenge.challengeDescription {
                case "Complete 3 quests today":
                    let completedToday = quests.filter { $0.isCompleted && calendar.isDateInToday($0.date ?? Date()) }.count
                    if completedToday >= 3 {
                        completeChallenge(challenge)
                    }
                case "Finish all morning quests":
                    let morningQuests = quests.filter { calendar.component(.hour, from: $0.date ?? Date()) < 12 }
                    if !morningQuests.isEmpty && morningQuests.allSatisfy({ $0.isCompleted }) {
                        completeChallenge(challenge)
                    }
                case "Complete 5 quests in one day":
                    let completedToday = quests.filter { $0.isCompleted && calendar.isDateInToday($0.date ?? Date()) }.count
                    if completedToday >= 5 {
                        completeChallenge(challenge)
                    }
                case "Complete quests from 3 different categories":
                    let completedCategories = Set(quests.filter { $0.isCompleted && calendar.isDateInToday($0.date ?? Date()) }
                        .compactMap { $0.category })
                    if completedCategories.count >= 3 {
                        completeChallenge(challenge)
                    }
                case "Complete a high-priority quest":
                    let hasCompletedHighPriority = quests.contains { $0.isCompleted && $0.xpValue >= 50 }
                    if hasCompletedHighPriority {
                        completeChallenge(challenge)
                    }
                case "Complete all quests before noon":
                    let noonQuests = quests.filter { calendar.component(.hour, from: $0.date ?? Date()) < 12 }
                    if !noonQuests.isEmpty && noonQuests.allSatisfy({ $0.isCompleted }) {
                        completeChallenge(challenge)
                    }
                case "Complete a quest with 50+ XP reward":
                    let hasCompletedHighXP = quests.contains { $0.isCompleted && $0.xpValue >= 50 }
                    if hasCompletedHighXP {
                        completeChallenge(challenge)
                    }
                case "Complete 2 quests in a row":
                    let completedQuests = quests.filter { $0.isCompleted }.sorted { ($0.date ?? Date()) < ($1.date ?? Date()) }
                    if completedQuests.count >= 2 {
                        let lastTwo = Array(completedQuests.suffix(2))
                        if calendar.isDate(lastTwo[0].date ?? Date(), inSameDayAs: lastTwo[1].date ?? Date()) {
                            completeChallenge(challenge)
                        }
                    }
                case "Complete a quest with a deadline":
                    let hasCompletedWithDeadline = quests.contains { $0.isCompleted && $0.deadline != nil }
                    if hasCompletedWithDeadline {
                        completeChallenge(challenge)
                    }
                default:
                    break
                }
            }
        }
    }
} 
