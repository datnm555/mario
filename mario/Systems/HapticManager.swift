import UIKit

/// Loại phản hồi rung theo ngữ cảnh.
enum HapticKind {
    case light      // jump
    case medium     // stomp
    case heavy      // trúng đòn / chết
    case success    // ăn power-up
    case selection  // coin / bấm nút
}

/// Rung phản hồi, tôn trọng cờ haptic trong Settings. Bọc UIFeedbackGenerator.
final class HapticManager {

    static let shared = HapticManager()

    private let settings: SettingsStore

    init(settings: SettingsStore = .shared) {
        self.settings = settings
    }

    var isEnabled: Bool { settings.hapticEnabled }

    func play(_ kind: HapticKind) {
        guard isEnabled else { return }
        switch kind {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
}
