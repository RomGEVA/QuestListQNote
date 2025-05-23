import SwiftUI

struct DailyChallengesView: View {
    @ObservedObject var questViewModel: QuestViewModel
    @State private var showingCompletionAlert = false
    @State private var selectedChallenge: Challenge?
    
    var body: some View {
        List {
            ForEach(questViewModel.dailyChallenges) { challenge in
                ChallengeRowView(challenge: challenge) {
                    selectedChallenge = challenge
                    showingCompletionAlert = true
                }
            }
        }
        .scrollContentBackground(.hidden)
        .refreshable {
            questViewModel.checkAndUpdateChallenges()
        }
        .alert("Complete Challenge", isPresented: $showingCompletionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Complete") {
                if let challenge = selectedChallenge {
                    questViewModel.completeChallenge(challenge)
                }
            }
        } message: {
            if let challenge = selectedChallenge {
                Text("Are you sure you want to mark '\(challenge.challengeDescription ?? "")' as completed?")
            }
        }
        .onAppear {
            questViewModel.checkAndUpdateChallenges()
        }
        .background(content: {
            BackgroundView()
        })
    }
}

struct ChallengeRowView: View {
    let challenge: Challenge
    let onComplete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(challenge.challengeDescription ?? "")
                    .font(.headline)
                
                Text("Reward: \(challenge.rewardXP) XP")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if challenge.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            } else {
                Button(action: onComplete) {
                    Image(systemName: "circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    DailyChallengesView(questViewModel: QuestViewModel(context: PersistenceController.shared.container.viewContext))
} 