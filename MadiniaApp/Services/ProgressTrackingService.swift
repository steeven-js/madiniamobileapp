//
//  ProgressTrackingService.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-07.
//

import Foundation

// MARK: - Achievement Tier

/// Tier levels for achievements
enum AchievementTier: String, Codable, CaseIterable {
    case bronze
    case silver
    case gold
}

// MARK: - Achievement

/// Represents an unlockable achievement
struct Achievement: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let tier: AchievementTier
    let requirement: Int
    var progress: Int = 0
    var unlockedAt: Date?

    var isUnlocked: Bool {
        unlockedAt != nil
    }

    var progressPercentage: Double {
        guard requirement > 0 else { return 0 }
        return min(Double(progress) / Double(requirement), 1.0)
    }
}

// MARK: - User Statistics

/// User engagement statistics
struct UserStatistics: Codable {
    var totalFormationsViewed: Int = 0
    var uniqueFormationsViewed: Int = 0
    var categoriesExplored: Set<String> = []
    var totalTimeSpentMinutes: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var firstLaunchDate: Date?
    var lastActiveDate: Date?

    var categoriesCount: Int {
        categoriesExplored.count
    }
}

// MARK: - Formation Progress

/// Tracks individual formation engagement
struct FormationProgress: Codable, Identifiable {
    var id: Int { formationId }
    let formationId: Int
    let formationTitle: String
    let formationSlug: String
    let categoryName: String?
    var viewCount: Int
    var totalTimeSpentSeconds: Int
    var lastViewedAt: Date
    var firstViewedAt: Date
}

// MARK: - Daily Activity

/// Tracks daily activity for the weekly chart
struct DailyActivity: Codable, Identifiable {
    var id: String { date }
    let date: String // Format: "yyyy-MM-dd"
    var minutesActive: Int
    var formationsViewed: Int
}

// MARK: - Progress Tracking Service

/// Centralized service for tracking user progress, statistics, and achievements.
/// Uses local storage (UserDefaults) for persistence.
@Observable
final class ProgressTrackingService {
    /// Shared singleton instance
    static let shared = ProgressTrackingService()

    // MARK: - Storage Keys

    private let statisticsKey = "progress_statistics"
    private let achievementsKey = "progress_achievements"
    private let formationProgressKey = "progress_formations"
    private let dailyActivityKey = "progress_daily_activity"

    // MARK: - Public State

    /// User statistics
    private(set) var statistics: UserStatistics = UserStatistics()

    /// All achievements (both locked and unlocked)
    private(set) var achievements: [Achievement] = []

    /// Progress per formation
    private(set) var formationProgress: [Int: FormationProgress] = [:]

    /// Daily activity for the last 7 days
    private(set) var weeklyActivity: [DailyActivity] = []

    // MARK: - Private Properties

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let dateFormatter: DateFormatter

    // MARK: - Initialization

    private init() {
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd"

        // Initialize achievements
        initializeAchievements()

        // Load from local storage
        loadStatistics()
        loadAchievements()
        loadFormationProgress()
        loadWeeklyActivity()

        // Update streak on init
        updateStreak()
    }

    // MARK: - Achievement Definitions

    private func initializeAchievements() {
        let defaultAchievements: [Achievement] = [
            // Viewing achievements
            Achievement(
                id: "first_view",
                name: "Premier pas",
                description: "Consultez votre 1ère formation",
                icon: "eye.fill",
                tier: .bronze,
                requirement: 1
            ),
            Achievement(
                id: "explorer_5",
                name: "Explorateur",
                description: "Consultez 5 formations",
                icon: "binoculars.fill",
                tier: .bronze,
                requirement: 5
            ),
            Achievement(
                id: "curious_10",
                name: "Curieux",
                description: "Consultez 10 formations",
                icon: "lightbulb.fill",
                tier: .silver,
                requirement: 10
            ),
            Achievement(
                id: "passionate_25",
                name: "Passionné",
                description: "Consultez 25 formations",
                icon: "flame.fill",
                tier: .gold,
                requirement: 25
            ),
            // Category achievements
            Achievement(
                id: "category_3",
                name: "Multi-disciplines",
                description: "Explorez 3 catégories",
                icon: "square.grid.2x2.fill",
                tier: .bronze,
                requirement: 3
            ),
            // Favorite achievements
            Achievement(
                id: "favorite_first",
                name: "Coup de cœur",
                description: "Ajoutez 1 favori",
                icon: "heart.fill",
                tier: .bronze,
                requirement: 1
            ),
            Achievement(
                id: "collector_5",
                name: "Collectionneur",
                description: "Ajoutez 5 favoris",
                icon: "heart.circle.fill",
                tier: .silver,
                requirement: 5
            ),
            // Streak achievements
            Achievement(
                id: "streak_3",
                name: "Régularité",
                description: "3 jours consécutifs",
                icon: "calendar.badge.checkmark",
                tier: .bronze,
                requirement: 3
            ),
            Achievement(
                id: "streak_7",
                name: "Hebdomadaire",
                description: "7 jours consécutifs",
                icon: "calendar.circle.fill",
                tier: .silver,
                requirement: 7
            )
        ]

        // Load saved achievements or use defaults
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let saved = try? decoder.decode([Achievement].self, from: data) {
            // Merge saved progress with default definitions
            achievements = defaultAchievements.map { defaultAchievement in
                if let savedAchievement = saved.first(where: { $0.id == defaultAchievement.id }) {
                    var merged = defaultAchievement
                    merged.progress = savedAchievement.progress
                    merged.unlockedAt = savedAchievement.unlockedAt
                    return merged
                }
                return defaultAchievement
            }
        } else {
            achievements = defaultAchievements
        }
    }

    // MARK: - Public Methods

    /// Track when a user views a formation
    func trackFormationEngagement(_ formation: Formation, timeSpent: TimeInterval) {
        let now = Date()
        let categoryName = formation.category?.name

        // Update or create formation progress
        if var progress = formationProgress[formation.id] {
            progress.viewCount += 1
            progress.totalTimeSpentSeconds += Int(timeSpent)
            progress.lastViewedAt = now
            formationProgress[formation.id] = progress
        } else {
            let progress = FormationProgress(
                formationId: formation.id,
                formationTitle: formation.title,
                formationSlug: formation.slug,
                categoryName: categoryName,
                viewCount: 1,
                totalTimeSpentSeconds: Int(timeSpent),
                lastViewedAt: now,
                firstViewedAt: now
            )
            formationProgress[formation.id] = progress
        }

        // Update statistics
        statistics.totalFormationsViewed += 1
        statistics.uniqueFormationsViewed = formationProgress.count
        if let category = categoryName {
            statistics.categoriesExplored.insert(category)
        }
        statistics.totalTimeSpentMinutes += Int(timeSpent / 60)
        statistics.lastActiveDate = now
        if statistics.firstLaunchDate == nil {
            statistics.firstLaunchDate = now
        }

        // Update daily activity
        updateDailyActivity(minutes: Int(timeSpent / 60), formationsViewed: 1)

        // Save and check achievements
        saveFormationProgress()
        saveStatistics()
        updateStreak()
        checkAndUnlockAchievements()
    }

    /// Update the streak based on last active date
    func updateStreak() {
        let now = Date()
        let calendar = Calendar.current

        guard let lastActive = statistics.lastActiveDate else {
            // First time user
            statistics.currentStreak = 1
            statistics.longestStreak = max(statistics.longestStreak, 1)
            statistics.lastActiveDate = now
            saveStatistics()
            return
        }

        let daysSinceLastActive = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastActive), to: calendar.startOfDay(for: now)).day ?? 0

        if daysSinceLastActive == 0 {
            // Same day, no change
            return
        } else if daysSinceLastActive == 1 {
            // Consecutive day
            statistics.currentStreak += 1
            statistics.longestStreak = max(statistics.longestStreak, statistics.currentStreak)
        } else {
            // Streak broken
            statistics.currentStreak = 1
        }

        statistics.lastActiveDate = now
        saveStatistics()
    }

    /// Check and unlock achievements based on current progress
    func checkAndUnlockAchievements() {
        let favoriteCount = FavoritesService.shared.favoriteFormationIds.count

        for i in 0..<achievements.count {
            var achievement = achievements[i]

            // Skip already unlocked
            if achievement.isUnlocked { continue }

            // Update progress based on achievement type
            switch achievement.id {
            case "first_view":
                achievement.progress = statistics.uniqueFormationsViewed
            case "explorer_5":
                achievement.progress = statistics.uniqueFormationsViewed
            case "curious_10":
                achievement.progress = statistics.uniqueFormationsViewed
            case "passionate_25":
                achievement.progress = statistics.uniqueFormationsViewed
            case "category_3":
                achievement.progress = statistics.categoriesCount
            case "favorite_first":
                achievement.progress = favoriteCount
            case "collector_5":
                achievement.progress = favoriteCount
            case "streak_3":
                achievement.progress = statistics.currentStreak
            case "streak_7":
                achievement.progress = statistics.currentStreak
            default:
                break
            }

            // Check if unlocked
            if achievement.progress >= achievement.requirement {
                achievement.unlockedAt = Date()
            }

            achievements[i] = achievement
        }

        saveAchievements()
    }

    /// Get recently unlocked achievements (for notifications)
    func recentlyUnlockedAchievements(since date: Date) -> [Achievement] {
        achievements.filter {
            guard let unlockedAt = $0.unlockedAt else { return false }
            return unlockedAt > date
        }
    }

    /// Get unlocked achievements sorted by unlock date
    func unlockedAchievements() -> [Achievement] {
        achievements.filter { $0.isUnlocked }
            .sorted { ($0.unlockedAt ?? .distantPast) > ($1.unlockedAt ?? .distantPast) }
    }

    /// Get locked achievements
    func lockedAchievements() -> [Achievement] {
        achievements.filter { !$0.isUnlocked }
    }

    /// Get weekly activity data for chart
    func getWeeklyActivityData() -> [DailyActivity] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Generate last 7 days
        var result: [DailyActivity] = []
        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let dateString = dateFormatter.string(from: date)

            if let activity = weeklyActivity.first(where: { $0.date == dateString }) {
                result.append(activity)
            } else {
                result.append(DailyActivity(date: dateString, minutesActive: 0, formationsViewed: 0))
            }
        }

        return result
    }

    /// Get formation history sorted by last viewed
    func getFormationHistory() -> [FormationProgress] {
        Array(formationProgress.values).sorted { $0.lastViewedAt > $1.lastViewedAt }
    }

    // MARK: - Private Methods

    private func updateDailyActivity(minutes: Int, formationsViewed: Int) {
        let today = dateFormatter.string(from: Date())

        if let index = weeklyActivity.firstIndex(where: { $0.date == today }) {
            weeklyActivity[index].minutesActive += minutes
            weeklyActivity[index].formationsViewed += formationsViewed
        } else {
            weeklyActivity.append(DailyActivity(
                date: today,
                minutesActive: minutes,
                formationsViewed: formationsViewed
            ))
        }

        // Keep only last 14 days
        let calendar = Calendar.current
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: Date())!
        weeklyActivity = weeklyActivity.filter {
            guard let activityDate = dateFormatter.date(from: $0.date) else { return false }
            return activityDate >= twoWeeksAgo
        }

        saveDailyActivity()
    }

    // MARK: - Persistence

    private func loadStatistics() {
        guard let data = UserDefaults.standard.data(forKey: statisticsKey),
              let stats = try? decoder.decode(UserStatistics.self, from: data) else {
            statistics = UserStatistics()
            return
        }
        statistics = stats
    }

    private func saveStatistics() {
        guard let data = try? encoder.encode(statistics) else { return }
        UserDefaults.standard.set(data, forKey: statisticsKey)
    }

    private func loadAchievements() {
        // Already handled in initializeAchievements
    }

    private func saveAchievements() {
        guard let data = try? encoder.encode(achievements) else { return }
        UserDefaults.standard.set(data, forKey: achievementsKey)
    }

    private func loadFormationProgress() {
        guard let data = UserDefaults.standard.data(forKey: formationProgressKey),
              let progress = try? decoder.decode([Int: FormationProgress].self, from: data) else {
            formationProgress = [:]
            return
        }
        formationProgress = progress
    }

    private func saveFormationProgress() {
        guard let data = try? encoder.encode(formationProgress) else { return }
        UserDefaults.standard.set(data, forKey: formationProgressKey)
    }

    private func loadWeeklyActivity() {
        guard let data = UserDefaults.standard.data(forKey: dailyActivityKey),
              let activity = try? decoder.decode([DailyActivity].self, from: data) else {
            weeklyActivity = []
            return
        }
        weeklyActivity = activity
    }

    private func saveDailyActivity() {
        guard let data = try? encoder.encode(weeklyActivity) else { return }
        UserDefaults.standard.set(data, forKey: dailyActivityKey)
    }
}
