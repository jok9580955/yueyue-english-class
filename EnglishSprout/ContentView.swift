import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var progress: LearningProgress
    @EnvironmentObject private var speechCoach: SpeechCoach
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                NavigationSplitView {
                    HomeSidebar()
                } detail: {
                    if let pack = progress.selectedPack {
                        LessonView(pack: pack)
                    } else {
                        WelcomePanel()
                    }
                }
            } else {
                NavigationStack {
                    HomeView()
                }
            }
        }
        .tint(Color(red: 0.97, green: 0.42, blue: 0.25))
    }
}

private struct HomeView: View {
    @EnvironmentObject private var progress: LearningProgress

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HeaderView()
                AgeBandPicker()
                MissionStrip()
                LearningSummaryView()
                DailyPathView()
                AchievementShelfView()
                WeeklyPlanView()
                LessonGrid()
                ParentCenterView()
            }
            .padding(20)
            .frame(maxWidth: 900, alignment: .leading)
        }
        .background(AppBackground())
        .navigationTitle(progress.courseTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct HomeSidebar: View {
    @EnvironmentObject private var progress: LearningProgress

    var body: some View {
        List(selection: Binding(
            get: { progress.selectedPack?.id },
            set: { selectedID in
                progress.selectedPack = LessonLibrary.packs(for: progress.selectedAgeBand).first { $0.id == selectedID }
            }
        )) {
            Section {
                HeaderView(compact: true)
                    .listRowSeparator(.hidden)
            }

            Section("年龄") {
                AgeBandPicker()
                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
            }

            Section("课程") {
                ForEach(LessonLibrary.packs(for: progress.selectedAgeBand)) { pack in
                    LessonRow(pack: pack)
                        .tag(pack.id)
                        .onTapGesture {
                            progress.selectedPack = pack
                        }
                }
            }

            Section("家长") {
                ParentCenterView(compact: true)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppBackground())
        .navigationTitle(progress.courseTitle)
        .onAppear {
            progress.selectedPack = progress.selectedPack ?? LessonLibrary.packs(for: progress.selectedAgeBand).first
        }
    }
}

private struct HeaderView: View {
    @EnvironmentObject private var progress: LearningProgress
    var compact = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 1.0, green: 0.77, blue: 0.30))
                    Image(systemName: "sparkles")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 4) {
                    Text(progress.courseTitle)
                        .font(compact ? .title2.bold() : .largeTitle.bold())
                    Text("每天一点点，听懂、敢说、喜欢英语。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if !compact {
                HStack(spacing: 10) {
                    StatPill(value: "2-6", label: "岁适用", symbol: "figure.and.child.holdinghands")
                    StatPill(value: "5-12", label: "分钟课程", symbol: "timer")
                    StatPill(value: "离线", label: "点读", symbol: "speaker.wave.2.fill")
                }
            }
        }
    }
}

private struct AgeBandPicker: View {
    @EnvironmentObject private var progress: LearningProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选择宝宝阶段")
                .font(.headline)

            Picker("年龄段", selection: Binding(
                get: { progress.selectedAgeBand },
                set: {
                    progress.selectedAgeBand = $0
                    progress.selectedPack = LessonLibrary.packs(for: $0).first
                }
            )) {
                ForEach(AgeBand.allCases) { age in
                    Text(age.title).tag(age)
                }
            }
            .pickerStyle(.segmented)

            Text(progress.selectedAgeBand.focus)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }
}

private struct MissionStrip: View {
    @EnvironmentObject private var progress: LearningProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("今日小任务")
                    .font(.headline)
                Spacer()
                Label("\(progress.earnedStars)", systemImage: "star.fill")
                    .foregroundStyle(Color(red: 0.92, green: 0.58, blue: 0.10))
                    .font(.headline)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(progress.todaysMissions) { mission in
                        MissionCard(mission: mission)
                    }
                }
            }
        }
    }
}

private struct LessonGrid: View {
    @EnvironmentObject private var progress: LearningProgress
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: horizontalSizeClass == .regular ? 260 : 156), spacing: 14)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("主题课程")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(LessonLibrary.packs(for: progress.selectedAgeBand)) { pack in
                    NavigationLink {
                        LessonView(pack: pack)
                    } label: {
                        LessonTile(pack: pack)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct LessonView: View {
    @EnvironmentObject private var progress: LearningProgress
    @EnvironmentObject private var speechCoach: SpeechCoach
    @State private var currentIndex = 0
    @State private var quizChoice: LessonCard?
    @State private var showCelebration = false
    @State private var gameTarget: LessonCard?
    @State private var shadowTarget: LessonCard?
    @State private var trainTarget: LessonCard?
    @State private var rhythmTaps = 0
    @State private var gameScore = 0

    let pack: LessonPack

    private var safeCurrentIndex: Int {
        guard !pack.cards.isEmpty else { return 0 }
        return min(max(currentIndex, 0), pack.cards.count - 1)
    }

    private var currentCard: LessonCard { pack.cards[safeCurrentIndex] }
    private var currentGameTarget: LessonCard { gameTarget ?? currentCard }
    private var currentShadowTarget: LessonCard { shadowTarget ?? currentCard }
    private var currentTrainTarget: LessonCard { trainTarget ?? currentCard }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                LessonHeader(pack: pack)
                StoryTimePanel(pack: pack)
                PracticeCard(card: currentCard)
                ActionBar(card: currentCard, onPractice: markPractice)
                BubbleGamePanel(
                    cards: pack.cards,
                    target: currentGameTarget,
                    score: gameScore,
                    onPlaySound: {
                        speechCoach.speak(currentGameTarget.word)
                    },
                    onChoose: handleGameChoice
                )
                ShadowMatchGamePanel(
                    cards: pack.cards,
                    target: currentShadowTarget,
                    onChoose: handleShadowChoice
                )
                RhythmTapGamePanel(
                    target: currentCard,
                    taps: rhythmTaps,
                    onPlaySound: {
                        speechCoach.speak(currentCard.word)
                    },
                    onTap: handleRhythmTap,
                    onReset: {
                        rhythmTaps = 0
                    }
                )
                LetterTrainGamePanel(
                    cards: pack.cards,
                    target: currentTrainTarget,
                    onChoose: handleTrainChoice
                )
                QuizPanel(cards: pack.cards, correctCard: currentCard, choice: $quizChoice, onCorrect: markPractice)
                ProgressDots(count: pack.cards.count, currentIndex: safeCurrentIndex)
            }
            .padding(20)
            .frame(maxWidth: 820)
            .frame(maxWidth: .infinity)
        }
        .background(AppBackground())
        .navigationTitle(pack.title)
        .onAppear {
            resetLessonStateIfNeeded()
        }
        .onChange(of: pack.id) { _, _ in
            resetLessonStateIfNeeded(force: true)
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button {
                    currentIndex = max(0, safeCurrentIndex - 1)
                } label: {
                    Label("上一个", systemImage: "chevron.left")
                }
                .disabled(safeCurrentIndex == 0)

                Spacer()

                Button {
                    currentIndex = min(pack.cards.count - 1, safeCurrentIndex + 1)
                    quizChoice = nil
                    rhythmTaps = 0
                } label: {
                    Label(safeCurrentIndex == pack.cards.count - 1 ? "完成" : "下一个", systemImage: "chevron.right")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .overlay(alignment: .top) {
            if showCelebration {
                Text("太棒啦 +1")
                    .font(.headline)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(.white, in: Capsule())
                    .shadow(radius: 12)
                    .padding(.top, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private func markPractice() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            progress.markCardPracticed()
            showCelebration = true
        }

        Task {
            try? await Task.sleep(for: .seconds(1.1))
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.2)) {
                    showCelebration = false
                }
            }
        }
    }

    private func handleGameChoice(_ card: LessonCard) {
        guard card == currentGameTarget else {
            speechCoach.speak("Try again")
            return
        }

        gameScore += 1
        markPractice()
        speechCoach.speak("Great job")

        Task {
            try? await Task.sleep(for: .milliseconds(700))
            await MainActor.run {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    gameTarget = pickDifferent(from: currentGameTarget)
                }
            }
        }
    }

    private func handleShadowChoice(_ card: LessonCard) {
        guard card == currentShadowTarget else {
            speechCoach.speak("Look again")
            return
        }

        markPractice()
        speechCoach.speak("\(card.word). Nice")
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            shadowTarget = pickDifferent(from: currentShadowTarget)
        }
    }

    private func handleRhythmTap() {
        let nextTapCount = rhythmTaps + 1
        rhythmTaps = nextTapCount

        if nextTapCount == currentCard.beatCount {
            markPractice()
            speechCoach.speak("Good rhythm")
            Task {
                try? await Task.sleep(for: .milliseconds(650))
                await MainActor.run {
                    rhythmTaps = 0
                }
            }
        } else if nextTapCount > currentCard.beatCount {
            speechCoach.speak("Try again")
            rhythmTaps = 0
        }
    }

    private func handleTrainChoice(_ card: LessonCard) {
        guard card == currentTrainTarget else {
            speechCoach.speak("Try another one")
            return
        }

        gameScore += 1
        markPractice()
        speechCoach.speak("\(card.firstLetter). \(card.word)")
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            trainTarget = pickDifferent(from: currentTrainTarget)
        }
    }

    private func pickDifferent(from card: LessonCard) -> LessonCard? {
        pack.cards.filter { $0 != card }.randomElement() ?? pack.cards.randomElement()
    }

    private func resetLessonStateIfNeeded(force: Bool = false) {
        if force || currentIndex >= pack.cards.count {
            currentIndex = 0
            quizChoice = nil
            rhythmTaps = 0
        }

        if force || gameTarget == nil || !pack.cards.contains(currentGameTarget) {
            gameTarget = pack.cards.randomElement()
        }

        if force || shadowTarget == nil || !pack.cards.contains(currentShadowTarget) {
            shadowTarget = pack.cards.randomElement()
        }

        if force || trainTarget == nil || !pack.cards.contains(currentTrainTarget) {
            trainTarget = pack.cards.randomElement()
        }
    }
}

private struct LessonHeader: View {
    let pack: LessonPack

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(pack.theme.tint.gradient)
                PackCoverImage(pack: pack)
                    .padding(8)
            }
            .frame(width: 76, height: 76)

            VStack(alignment: .leading, spacing: 6) {
                Text(pack.title)
                    .font(.title.bold())
                Text("\(pack.ageBand.title) · \(pack.minutes)分钟 · \(pack.cards.count)张卡片")
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

private struct PracticeCard: View {
    @EnvironmentObject private var speechCoach: SpeechCoach
    let card: LessonCard

    var body: some View {
        Button {
            speechCoach.speak(card.word)
        } label: {
            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(card.color.opacity(0.14))
                    VocabularyImage(card: card)
                        .padding(12)
                }
                .frame(width: 188, height: 188)

                VStack(spacing: 8) {
                    Text(card.word)
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.7)
                    if !card.phonics.isEmpty {
                        Text(card.phonics)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    Text(card.meaning)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                Text(card.prompt)
                    .font(.headline)
                    .foregroundStyle(card.color)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(.white, in: RoundedRectangle(cornerRadius: 8))
            .shadow(color: card.color.opacity(0.18), radius: 20, y: 10)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("点读 \(card.word)")
    }
}

private struct ActionBar: View {
    @EnvironmentObject private var speechCoach: SpeechCoach
    let card: LessonCard
    let onPractice: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button {
                speechCoach.speak(card.word)
            } label: {
                Label("听单词", systemImage: speechCoach.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                speechCoach.speak(card.phrase)
            } label: {
                Label("听句子", systemImage: "text.bubble.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                onPractice()
            } label: {
                Label("我会说", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .controlSize(.large)
        .font(.headline)
    }
}

private struct QuizPanel: View {
    @EnvironmentObject private var speechCoach: SpeechCoach
    let cards: [LessonCard]
    let correctCard: LessonCard
    @Binding var choice: LessonCard?
    let onCorrect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("找一找")
                    .font(.headline)
                Spacer()
                Button {
                    speechCoach.speak(correctCard.word)
                } label: {
                    Label("播放", systemImage: "play.fill")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.bordered)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                ForEach(cards) { card in
                    Button {
                        choice = card
                        if card == correctCard {
                            onCorrect()
                        }
                    } label: {
                        VStack(spacing: 8) {
                            VocabularyImage(card: card)
                                .frame(width: 54, height: 54)
                            Text(card.meaning)
                                .font(.headline)
                        }
                        .foregroundStyle(choice == card ? .white : card.color)
                        .frame(maxWidth: .infinity, minHeight: 104)
                        .background(answerColor(for: card), in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 8))
    }

    private func answerColor(for card: LessonCard) -> Color {
        guard choice == card else { return Color.white }
        return card == correctCard ? Color(red: 0.22, green: 0.62, blue: 0.48) : Color(red: 0.86, green: 0.28, blue: 0.30)
    }
}

private struct StoryTimePanel: View {
    @EnvironmentObject private var speechCoach: SpeechCoach
    let pack: LessonPack

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("故事时间", systemImage: "book.pages.fill")
                    .font(.headline)
                Spacer()
                Button {
                    speechCoach.speak(pack.storyLines.joined(separator: " "))
                } label: {
                    Label("播放", systemImage: "play.fill")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.bordered)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(pack.storyTitle)
                    .font(.title3.bold())
                ForEach(pack.storyLines, id: \.self) { line in
                    Button {
                        speechCoach.speak(line)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundStyle(pack.theme.tint)
                            Text(line)
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(12)
                        .background(.white, in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(pack.storyHint)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(Color.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct BubbleGamePanel: View {
    let cards: [LessonCard]
    let target: LessonCard
    let score: Int
    let onPlaySound: () -> Void
    let onChoose: (LessonCard) -> Void

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 120), spacing: 12)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Label("气泡游戏", systemImage: "gamecontroller.fill")
                    .font(.headline)

                Spacer()

                Label("\(score)", systemImage: "star.fill")
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.92, green: 0.58, blue: 0.10))
            }

            HStack(spacing: 14) {
                Button(action: onPlaySound) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title2.weight(.bold))
                        .frame(width: 54, height: 54)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("听一听")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("点到 \(target.meaning)")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.8)
                }

                Spacer()
            }
            .padding(14)
            .background(target.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(cards) { card in
                    Button {
                        onChoose(card)
                    } label: {
                        VStack(spacing: 8) {
                            VocabularyImage(card: card)
                                .frame(width: 66, height: 66)
                            Text(card.word)
                                .font(.title3.weight(.black))
                                .minimumScaleFactor(0.75)
                            Text(card.meaning)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .foregroundStyle(card.color)
                        .frame(maxWidth: .infinity, minHeight: 128)
                        .background(.white, in: Circle())
                        .shadow(color: card.color.opacity(0.18), radius: 12, y: 6)
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct ShadowMatchGamePanel: View {
    let cards: [LessonCard]
    let target: LessonCard
    let onChoose: (LessonCard) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("影子配对", systemImage: "circle.dashed.inset.filled")
                .font(.headline)

            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(target.color.opacity(0.12))
                    VocabularyImage(card: target)
                        .padding(8)
                }
                .frame(width: 108, height: 108)

                VStack(alignment: .leading, spacing: 6) {
                    Text("给它找英文名")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(target.meaning)
                        .font(.title2.bold())
                    Text("选对会读给宝宝听")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 12)], spacing: 12) {
                ForEach(cards) { card in
                    Button {
                        onChoose(card)
                    } label: {
                        Text(card.word)
                            .font(.title3.weight(.black))
                            .foregroundStyle(card.color)
                            .frame(maxWidth: .infinity, minHeight: 58)
                            .background(card.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct RhythmTapGamePanel: View {
    let target: LessonCard
    let taps: Int
    let onPlaySound: () -> Void
    let onTap: () -> Void
    let onReset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("节奏拍词", systemImage: "music.note")
                    .font(.headline)
                Spacer()
                Button(action: onReset) {
                    Image(systemName: "arrow.counterclockwise")
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 14) {
                Button(action: onPlaySound) {
                    Image(systemName: "play.fill")
                        .font(.headline)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.bordered)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 5) {
                    Text(target.word)
                        .font(.title.bold())
                    Text("拍 \(target.beatCount) 下")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                ForEach(0..<max(target.beatCount, taps), id: \.self) { index in
                    Circle()
                        .fill(index < taps ? target.color : Color.gray.opacity(0.20))
                        .frame(width: 22, height: 22)
                }
            }

            Button(action: onTap) {
                Label("拍一下", systemImage: "hand.tap.fill")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity, minHeight: 64)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(18)
        .background(Color.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct LetterTrainGamePanel: View {
    let cards: [LessonCard]
    let target: LessonCard
    let onChoose: (LessonCard) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("字母小火车", systemImage: "tram.fill")
                .font(.headline)

            HStack(spacing: 14) {
                Text(target.firstLetter)
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 78, height: 78)
                    .background(target.color, in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 5) {
                    Text("找开头字母")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("哪一个从 \(target.firstLetter) 开始？")
                        .font(.title3.bold())
                        .minimumScaleFactor(0.8)
                }

                Spacer()
            }

            HStack(spacing: 0) {
                ForEach(cards) { card in
                    Button {
                        onChoose(card)
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "rectangle.fill")
                                .font(.title3)
                            Text(card.word)
                                .font(.headline.bold())
                                .minimumScaleFactor(0.75)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 86)
                        .background(card.color)
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(18)
        .background(Color.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct ParentCenterView: View {
    @EnvironmentObject private var progress: LearningProgress
    @EnvironmentObject private var speechCoach: SpeechCoach
    var compact = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("家长中心", systemImage: "lock.shield.fill")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("宝宝名字")
                    .font(.subheadline.weight(.semibold))
                HStack(spacing: 8) {
                    TextField("钥钥", text: $progress.childName)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .padding(.horizontal, 12)
                        .frame(height: 42)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 8))
                    Text("的英语课")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Text("当前显示：\(progress.courseTitle)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Toggle("温和模式", isOn: $progress.gentleMode)

            VStack(alignment: .leading) {
                HStack {
                    Text("每日目标")
                    Spacer()
                    Text("\(progress.dailyGoalMinutes)分钟")
                        .foregroundStyle(.secondary)
                }
                Stepper("每日目标", value: $progress.dailyGoalMinutes, in: 5...20, step: 5)
                    .labelsHidden()
            }

            VStack(alignment: .leading) {
                Text("语速")
                Slider(value: $speechCoach.speechRate, in: 0.32...0.52)
            }

            if !compact {
                Text("已练习 \(progress.completedCards) 张卡片。建议每次学习不超过15分钟，家长陪伴重复听说，比一次学很多更有效。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(compact ? 0 : 18)
        .background(compact ? Color.clear : Color.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct LearningSummaryView: View {
    @EnvironmentObject private var progress: LearningProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("学习记录")
                .font(.headline)

            HStack(spacing: 12) {
                SummaryMetric(value: "\(progress.completedCards)", label: "已练卡片", symbol: "checkmark.circle.fill", color: Color(red: 0.22, green: 0.62, blue: 0.48))
                SummaryMetric(value: "\(progress.earnedStars)", label: "小星星", symbol: "star.fill", color: Color(red: 0.92, green: 0.58, blue: 0.10))
                SummaryMetric(value: "\(LessonLibrary.packs(for: progress.selectedAgeBand).count)", label: "主题课", symbol: "square.grid.2x2.fill", color: Color(red: 0.40, green: 0.48, blue: 0.92))
            }
        }
    }
}

private struct DailyPathView: View {
    @EnvironmentObject private var progress: LearningProgress
    @EnvironmentObject private var speechCoach: SpeechCoach

    private var firstPack: LessonPack? {
        LessonLibrary.packs(for: progress.selectedAgeBand).first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日学习路径")
                .font(.headline)

            HStack(spacing: 12) {
                if let firstPack {
                    NavigationLink {
                        LessonView(pack: firstPack)
                    } label: {
                        PathStepCard(
                            title: "玩主题课",
                            detail: firstPack.title,
                            symbol: "play.fill",
                            color: firstPack.theme.tint
                        )
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    speechCoach.speak("Hello! Let's play English.")
                } label: {
                    PathStepCard(title: "热身儿歌", detail: "Hello 跟读", symbol: "music.note", color: Color(red: 0.92, green: 0.36, blue: 0.58))
                }
                .buttonStyle(.plain)

                Button {
                    if let reviewLine = firstPack?.storyLines.first {
                        speechCoach.speak(reviewLine)
                    }
                } label: {
                    PathStepCard(title: "复习一句", detail: "听一句再说", symbol: "arrow.trianglehead.2.clockwise", color: Color(red: 0.22, green: 0.62, blue: 0.48))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct PathStepCard: View {
    let title: String
    let detail: String
    let symbol: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: symbol)
                .font(.headline.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(detail)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 134, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct AchievementShelfView: View {
    @EnvironmentObject private var progress: LearningProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("成就贴纸")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(progress.badges) { badge in
                        BadgeCard(badge: badge, unlocked: progress.earnedStars >= badge.requiredStars)
                    }
                }
            }
        }
    }
}

private struct BadgeCard: View {
    let badge: LearningBadge
    let unlocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: badge.symbol)
                .font(.title3.weight(.bold))
                .foregroundStyle(unlocked ? badge.color : Color.gray)
                .frame(width: 42, height: 42)
                .background((unlocked ? badge.color : Color.gray).opacity(0.14), in: Circle())
            Text(badge.title)
                .font(.headline)
            Text(unlocked ? "已获得" : "\(badge.requiredStars)星解锁")
                .font(.caption.weight(.bold))
                .foregroundStyle(unlocked ? badge.color : .secondary)
            Text(badge.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(width: 148, height: 156, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 8))
        .opacity(unlocked ? 1 : 0.68)
    }
}

private struct WeeklyPlanView: View {
    @EnvironmentObject private var progress: LearningProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("一周启蒙计划")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: 10)], spacing: 10) {
                ForEach(progress.weeklyPlan) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.day)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        Image(systemName: item.theme.symbol)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(item.theme.tint)
                        Text(item.focus)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, minHeight: 116, alignment: .leading)
                    .background(.white, in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

private struct SummaryMetric: View {
    let value: String
    let label: String
    let symbol: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol)
                .font(.headline)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 116, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct WelcomePanel: View {
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "sparkles")
                .font(.system(size: 80, weight: .bold))
                .foregroundStyle(Color(red: 0.97, green: 0.42, blue: 0.25))
            Text("选择一个主题开始")
                .font(.largeTitle.bold())
            Text("iPad 上可以一边选课，一边看点读卡片。")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppBackground())
    }
}

private struct LessonTile: View {
    let pack: LessonPack

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: pack.theme.symbol)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.clear)
                    .frame(width: 52, height: 52)
                    .overlay {
                        PackCoverImage(pack: pack)
                            .padding(4)
                    }
                    .background(pack.theme.tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))

                Spacer()

                Text("\(pack.minutes)分钟")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(pack.theme.tint.opacity(0.12), in: Capsule())
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(pack.title)
                    .font(.title3.bold())
                Text(pack.cards.map(\.word).joined(separator: " · "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 166, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 8))
        .shadow(color: pack.theme.tint.opacity(0.12), radius: 12, y: 6)
    }
}

private struct LessonRow: View {
    let pack: LessonPack

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: pack.theme.symbol)
                .frame(width: 38, height: 38)
                .foregroundStyle(.clear)
                .overlay {
                    PackCoverImage(pack: pack)
                        .padding(3)
                }
                .background(pack.theme.tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading) {
                Text(pack.title)
                    .font(.headline)
                Text(pack.cards.map(\.word).joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct MissionCard: View {
    let mission: DailyMission

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: mission.symbol)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color(red: 0.97, green: 0.42, blue: 0.25))
            Text(mission.title)
                .font(.headline)
            Text(mission.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(width: 172, height: 132, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct VocabularyImage: View {
    let card: LessonCard

    var body: some View {
        Image(card.imageName)
            .resizable()
            .scaledToFit()
            .accessibilityHidden(true)
    }
}

private struct PackCoverImage: View {
    let pack: LessonPack

    var body: some View {
        if let card = pack.cards.first {
            VocabularyImage(card: card)
        } else {
            Image(systemName: pack.theme.symbol)
                .resizable()
                .scaledToFit()
                .foregroundStyle(pack.theme.tint)
        }
    }
}

private struct StatPill: View {
    let value: String
    let label: String
    let symbol: String

    var body: some View {
        Label {
            Text("\(value) \(label)")
                .font(.caption.weight(.bold))
        } icon: {
            Image(systemName: symbol)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.8), in: Capsule())
    }
}

private struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.24, dampingFraction: 0.62), value: configuration.isPressed)
    }
}

private struct ProgressDots: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color(red: 0.97, green: 0.42, blue: 0.25) : Color.gray.opacity(0.24))
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.bottom, 72)
    }
}

private struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.96, blue: 0.88),
                Color(red: 0.90, green: 0.97, blue: 1.0),
                Color(red: 0.95, green: 0.94, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private extension LessonCard {
    var firstLetter: String {
        String(word.prefix(1)).uppercased()
    }

    var beatCount: Int {
        switch word {
        case "apple", "baby":
            2
        default:
            1
        }
    }
}

private extension LessonPack {
    var storyTitle: String {
        switch theme {
        case .animals: "Little Animal Friends"
        case .food: "Yummy Snack Time"
        case .family: "My Happy Family"
        case .colors: "Colors Around Me"
        case .toys: "Play With Me"
        case .nature: "Up In The Sky"
        case .body: "My Little Body"
        case .actions: "Move And Smile"
        }
    }

    var storyLines: [String] {
        switch theme {
        case .animals:
            ["I see a cat.", "I see a dog.", "I see a bird."]
        case .food:
            ["I like apples.", "I drink milk.", "I see a cake."]
        case .family:
            ["Mom hugs me.", "Dad reads books.", "Baby smiles."]
        case .colors:
            ["Red balloon.", "Blue sky.", "Green leaf."]
        case .toys:
            ["I have a ball.", "Open the book.", "The car goes beep."]
        case .nature:
            ["Hello sun.", "Good night moon.", "Twinkle little star."]
        case .body:
            ["I see with my eyes.", "I wave my hand.", "I put on shoes."]
        case .actions:
            ["I can jump.", "Time to sleep.", "The train goes choo-choo."]
        }
    }

    var storyHint: String {
        "点每一句可以单独听，适合家长带宝宝做亲子跟读。"
    }
}

#Preview {
    ContentView()
        .environmentObject(LearningProgress())
        .environmentObject(SpeechCoach())
}
