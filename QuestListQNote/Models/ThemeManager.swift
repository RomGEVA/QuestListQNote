import SwiftUI

enum AppTheme: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    case colorful = "Colorful"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        case .colorful:
            return .light // Base scheme for colorful theme
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .system, .light, .dark:
            return .blue
        case .colorful:
            return .purple
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .system, .light, .dark:
            return .gray
        case .colorful:
            return .pink
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .system, .light:
            return .white
        case .dark:
            return Color(.systemBackground)
        case .colorful:
            return Color(.systemBackground).opacity(0.9)
        }
    }
}

class ThemeManager: ObservableObject {
    
    @Published var currentTheme: AppTheme {
        didSet {
            selectedThemeRaw = currentTheme.rawValue
        }
    }

    private var selectedThemeRaw: String {
        get { UserDefaults.standard.string(forKey: "selectedTheme") ?? AppTheme.system.rawValue }
        set { UserDefaults.standard.set(newValue, forKey: "selectedTheme") }
    }

    init() {
        self.currentTheme = AppTheme(rawValue: UserDefaults.standard.string(forKey: "selectedTheme") ?? "") ?? .system
    }

    func applyTheme() {
        currentTheme = AppTheme(rawValue: selectedThemeRaw) ?? .system
    }
}
