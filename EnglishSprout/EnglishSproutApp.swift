import SwiftUI

@main
struct EnglishSproutApp: App {
    @StateObject private var progress = LearningProgress()
    @StateObject private var speechCoach = SpeechCoach()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(progress)
                .environmentObject(speechCoach)
        }
    }
}
