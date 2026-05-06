import SwiftUI

enum AgeBand: String, CaseIterable, Identifiable {
    case toddler = "2-3"
    case preschool = "4-5"
    case bridge = "6"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .toddler: "2-3岁"
        case .preschool: "4-5岁"
        case .bridge: "6岁"
        }
    }

    var focus: String {
        switch self {
        case .toddler: "听音和模仿"
        case .preschool: "词汇和短句"
        case .bridge: "自然拼读"
        }
    }
}

enum LessonTheme: String, CaseIterable, Identifiable {
    case animals
    case food
    case family
    case colors
    case toys
    case nature
    case body
    case actions

    var id: String { rawValue }

    var title: String {
        switch self {
        case .animals: "动物朋友"
        case .food: "好吃的"
        case .family: "我的家"
        case .colors: "颜色乐园"
        case .toys: "玩具天地"
        case .nature: "天空自然"
        case .body: "身体认知"
        case .actions: "动起来"
        }
    }

    var symbol: String {
        switch self {
        case .animals: "pawprint.fill"
        case .food: "fork.knife"
        case .family: "house.fill"
        case .colors: "paintpalette.fill"
        case .toys: "teddybear.fill"
        case .nature: "sun.max.fill"
        case .body: "figure.wave"
        case .actions: "figure.run"
        }
    }

    var tint: Color {
        switch self {
        case .animals: Color(red: 0.22, green: 0.62, blue: 0.48)
        case .food: Color(red: 0.97, green: 0.42, blue: 0.25)
        case .family: Color(red: 0.40, green: 0.48, blue: 0.92)
        case .colors: Color(red: 0.92, green: 0.36, blue: 0.58)
        case .toys: Color(red: 0.20, green: 0.58, blue: 0.86)
        case .nature: Color(red: 0.98, green: 0.66, blue: 0.16)
        case .body: Color(red: 0.78, green: 0.40, blue: 0.86)
        case .actions: Color(red: 0.18, green: 0.62, blue: 0.42)
        }
    }
}

struct LessonCard: Identifiable, Hashable {
    let id = UUID()
    let theme: LessonTheme
    let word: String
    let phonics: String
    let meaning: String
    let phrase: String
    let prompt: String
    let symbol: String
    let imageName: String
    let color: Color
}

struct LessonPack: Identifiable, Hashable {
    let id = UUID()
    let theme: LessonTheme
    let ageBand: AgeBand
    let minutes: Int
    let cards: [LessonCard]

    var title: String { theme.title }
    var progressKey: String { "\(theme.rawValue)-\(ageBand.rawValue)" }
}

struct DailyMission: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let symbol: String
}

struct LearningBadge: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let symbol: String
    let color: Color
    let requiredStars: Int
}

struct WeeklyPlan: Identifiable {
    let id = UUID()
    let day: String
    let focus: String
    let theme: LessonTheme
}

@MainActor
final class LearningProgress: ObservableObject {
    @Published var childName: String {
        didSet { UserDefaults.standard.set(childName, forKey: "childName") }
    }

    @Published var selectedAgeBand: AgeBand {
        didSet { UserDefaults.standard.set(selectedAgeBand.rawValue, forKey: "selectedAgeBand") }
    }

    @Published var dailyGoalMinutes: Int {
        didSet { UserDefaults.standard.set(dailyGoalMinutes, forKey: "dailyGoalMinutes") }
    }

    @Published var gentleMode: Bool {
        didSet { UserDefaults.standard.set(gentleMode, forKey: "gentleMode") }
    }

    @Published var completedCards: Int {
        didSet { UserDefaults.standard.set(completedCards, forKey: "completedCards") }
    }

    @Published var selectedPack: LessonPack?
    @Published var earnedStars: Int

    init() {
        let storedChildName = UserDefaults.standard.string(forKey: "childName")
        childName = storedChildName?.isEmpty == false ? storedChildName! : "钥钥"

        let storedAge = UserDefaults.standard.string(forKey: "selectedAgeBand")
        selectedAgeBand = AgeBand(rawValue: storedAge ?? "") ?? .toddler

        let storedGoal = UserDefaults.standard.integer(forKey: "dailyGoalMinutes")
        dailyGoalMinutes = storedGoal == 0 ? 10 : storedGoal

        if UserDefaults.standard.object(forKey: "gentleMode") == nil {
            gentleMode = true
        } else {
            gentleMode = UserDefaults.standard.bool(forKey: "gentleMode")
        }

        let storedCompletedCards = UserDefaults.standard.integer(forKey: "completedCards")
        completedCards = storedCompletedCards
        earnedStars = max(3, storedCompletedCards + 3)
    }

    var courseTitle: String {
        let trimmedName = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(trimmedName.isEmpty ? "钥钥" : trimmedName)的英语课"
    }

    var todaysMissions: [DailyMission] {
        [
            DailyMission(title: "听3个新单词", detail: "点一下卡片，听清发音", symbol: "ear.fill"),
            DailyMission(title: "说1句小短句", detail: "跟着老师慢慢说", symbol: "mic.fill"),
            DailyMission(title: "完成一次找一找", detail: "选出听到的单词", symbol: "hand.tap.fill")
        ]
    }

    var badges: [LearningBadge] {
        [
            LearningBadge(title: "敢开口", detail: "完成3次跟读", symbol: "mouth.fill", color: Color(red: 0.92, green: 0.36, blue: 0.58), requiredStars: 3),
            LearningBadge(title: "小耳朵", detail: "听满8张卡", symbol: "ear.fill", color: Color(red: 0.20, green: 0.58, blue: 0.86), requiredStars: 8),
            LearningBadge(title: "游戏星", detail: "完成15次游戏", symbol: "gamecontroller.fill", color: Color(red: 0.22, green: 0.62, blue: 0.48), requiredStars: 15),
            LearningBadge(title: "故事宝贝", detail: "听完20句故事", symbol: "book.pages.fill", color: Color(red: 0.98, green: 0.66, blue: 0.16), requiredStars: 20)
        ]
    }

    var weeklyPlan: [WeeklyPlan] {
        [
            WeeklyPlan(day: "周一", focus: "动物听音", theme: .animals),
            WeeklyPlan(day: "周二", focus: "食物短句", theme: .food),
            WeeklyPlan(day: "周三", focus: "家庭表达", theme: .family),
            WeeklyPlan(day: "周四", focus: "颜色观察", theme: .colors),
            WeeklyPlan(day: "周五", focus: "玩具游戏", theme: .toys),
            WeeklyPlan(day: "周六", focus: "自然儿歌", theme: .nature),
            WeeklyPlan(day: "周日", focus: "身体动作", theme: .actions)
        ]
    }

    func markCardPracticed() {
        completedCards += 1
        earnedStars += 1
    }
}

enum LessonLibrary {
    static let packs: [LessonPack] = LessonTheme.allCases.flatMap { theme in
        AgeBand.allCases.map { ageBand in
            LessonPack(theme: theme, ageBand: ageBand, minutes: minutes(for: ageBand), cards: cards(for: theme, ageBand: ageBand))
        }
    }

    static func packs(for ageBand: AgeBand) -> [LessonPack] {
        packs.filter { $0.ageBand == ageBand }
    }

    private static func minutes(for ageBand: AgeBand) -> Int {
        switch ageBand {
        case .toddler: 5
        case .preschool: 8
        case .bridge: 12
        }
    }

    private static func cards(for theme: LessonTheme, ageBand: AgeBand) -> [LessonCard] {
        let base: [(String, String, String, String, String, String, String, Color)] = switch theme {
        case .animals:
            [
                ("cat", "/kaet/", "猫咪", "The cat is soft.", "摸摸小猫，说 cat", "cat.fill", "cat", Color(red: 0.22, green: 0.62, blue: 0.48)),
                ("dog", "/dog/", "小狗", "The dog can run.", "挥挥手，说 dog", "dog.fill", "dog", Color(red: 0.18, green: 0.52, blue: 0.76)),
                ("bird", "/berd/", "小鸟", "A bird can fly.", "张开手，说 bird", "bird.fill", "bird", Color(red: 0.95, green: 0.62, blue: 0.18))
            ]
        case .food:
            [
                ("apple", "/ap-uhl/", "苹果", "I like apples.", "假装咬一口，说 apple", "apple.logo", "apple", Color(red: 0.93, green: 0.21, blue: 0.28)),
                ("milk", "/milk/", "牛奶", "Milk is yummy.", "端起杯子，说 milk", "mug.fill", "milk", Color(red: 0.28, green: 0.56, blue: 0.88)),
                ("cake", "/kayk/", "蛋糕", "Cake is sweet.", "拍拍手，说 cake", "birthday.cake.fill", "cake", Color(red: 0.92, green: 0.36, blue: 0.58))
            ]
        case .family:
            [
                ("mom", "/mom/", "妈妈", "Mom hugs me.", "抱一抱，说 mom", "figure.2.and.child.holdinghands", "mom", Color(red: 0.88, green: 0.37, blue: 0.50)),
                ("dad", "/dad/", "爸爸", "Dad reads books.", "翻翻书，说 dad", "book.fill", "dad", Color(red: 0.32, green: 0.45, blue: 0.86)),
                ("baby", "/bay-bee/", "宝宝", "The baby smiles.", "笑一笑，说 baby", "face.smiling.fill", "baby", Color(red: 0.97, green: 0.56, blue: 0.27))
            ]
        case .colors:
            [
                ("red", "/red/", "红色", "Red balloon.", "找找红色，说 red", "circle.fill", "red_balloon", Color(red: 0.92, green: 0.18, blue: 0.22)),
                ("blue", "/bloo/", "蓝色", "Blue sky.", "指指天空，说 blue", "cloud.fill", "blue_sky_cloud", Color(red: 0.24, green: 0.48, blue: 0.90)),
                ("green", "/green/", "绿色", "Green leaf.", "摸摸叶子，说 green", "leaf.fill", "green_leaf", Color(red: 0.20, green: 0.62, blue: 0.35))
            ]
        case .toys:
            [
                ("ball", "/bawl/", "球", "The ball is round.", "滚一滚，说 ball", "circle.grid.cross.fill", "ball", Color(red: 0.20, green: 0.58, blue: 0.86)),
                ("book", "/book/", "书", "Open the book.", "翻开书，说 book", "book.fill", "book", Color(red: 0.32, green: 0.45, blue: 0.86)),
                ("car", "/kar/", "小汽车", "The car goes beep.", "开小车，说 car", "car.fill", "car", Color(red: 0.92, green: 0.22, blue: 0.18))
            ]
        case .nature:
            [
                ("sun", "/sun/", "太阳", "The sun is warm.", "举起手，说 sun", "sun.max.fill", "sun", Color(red: 0.98, green: 0.66, blue: 0.16)),
                ("moon", "/moon/", "月亮", "The moon is bright.", "闭上眼，说 moon", "moon.fill", "moon", Color(red: 0.64, green: 0.52, blue: 0.90)),
                ("star", "/star/", "星星", "A star shines.", "眨眨眼，说 star", "star.fill", "star", Color(red: 0.95, green: 0.58, blue: 0.12))
            ]
        case .body:
            [
                ("eyes", "/ize/", "眼睛", "I see with my eyes.", "指指眼睛，说 eyes", "eye.fill", "eyes", Color(red: 0.34, green: 0.48, blue: 0.86)),
                ("hand", "/hand/", "手", "Wave your hand.", "挥挥手，说 hand", "hand.wave.fill", "hand", Color(red: 0.96, green: 0.58, blue: 0.32)),
                ("shoes", "/shooz/", "鞋子", "Put on shoes.", "跺跺脚，说 shoes", "shoeprints.fill", "shoes", Color(red: 0.20, green: 0.54, blue: 0.86))
            ]
        case .actions:
            [
                ("jump", "/jump/", "跳", "I can jump.", "跳一跳，说 jump", "figure.jumprope", "jump", Color(red: 0.18, green: 0.62, blue: 0.42)),
                ("sleep", "/sleep/", "睡觉", "Time to sleep.", "假装睡觉，说 sleep", "bed.double.fill", "sleep", Color(red: 0.36, green: 0.50, blue: 0.92)),
                ("train", "/trayn/", "火车", "The train goes choo-choo.", "开火车，说 train", "tram.fill", "train", Color(red: 0.88, green: 0.28, blue: 0.20))
            ]
        }

        let requiredCount = switch ageBand {
        case .toddler: 2
        case .preschool, .bridge: 3
        }

        return base.prefix(requiredCount).map { item in
            LessonCard(
                theme: theme,
                word: item.0,
                phonics: ageBand == .bridge ? item.1 : "",
                meaning: item.2,
                phrase: ageBand == .toddler ? "Say \(item.0)." : item.3,
                prompt: item.4,
                symbol: item.5,
                imageName: item.6,
                color: item.7
            )
        }
    }
}
