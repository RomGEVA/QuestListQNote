import SwiftUI
import CoreData

struct OnboardingView: View {
    
    private let persistenceController = PersistenceController.shared
    @StateObject private var userViewModel: UserViewModel
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    @State private var selectedAvatar = "avatar1"
    @State private var nickname = ""
    @State private var isOpenMainView = false
    
    let avatars = ["avatar1", "avatar2", "avatar3", "avatar4"]
    
    init(context: NSManagedObjectContext) {
        _userViewModel = StateObject(wrappedValue: UserViewModel(context: context))
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack(spacing: 30) {
                Text("Welcome to QuestList!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Your gamified to-do list")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                VStack {
                    Text("Choose your avatar")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        ForEach(avatars, id: \.self) { avatar in
                            Image(avatar)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(selectedAvatar == avatar ? Color.blue : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    selectedAvatar = avatar
                                }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground).opacity(0.8))
                .cornerRadius(15)
                
                VStack {
                    Text("Enter your nickname")
                        .font(.headline)
                    
                    TextField("Nickname", text: $nickname)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
                .padding()
                .background(Color(.systemBackground).opacity(0.8))
                .cornerRadius(15)
                
                Button(action: completeOnboarding) {
                    Text("Start Your Adventure")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(nickname.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(nickname.isEmpty)
                .padding(.horizontal)
            }
            .padding()
            .fullScreenCover(isPresented: $isOpenMainView) {
                ContentView(context: self.persistenceController.container.viewContext)
            }
        }
    }
    
    private func completeOnboarding() {
        userViewModel.createUser(name: nickname, avatar: selectedAvatar)
        hasCompletedOnboarding = true
        isOpenMainView = true
    }
}

#Preview {
    OnboardingView(context: PersistenceController.shared.container.viewContext)
} 
