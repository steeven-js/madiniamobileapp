//
//  MadiQuiz.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-06.
//

import Foundation

// MARK: - Quiz Question

/// Represents a single quiz question
struct QuizQuestion: Identifiable, Equatable {
    let id: UUID
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
    let relatedFormationSlug: String?

    init(
        id: UUID = UUID(),
        question: String,
        options: [String],
        correctIndex: Int,
        explanation: String,
        relatedFormationSlug: String? = nil
    ) {
        self.id = id
        self.question = question
        self.options = options
        self.correctIndex = correctIndex
        self.explanation = explanation
        self.relatedFormationSlug = relatedFormationSlug
    }

    /// Check if the selected answer is correct
    func isCorrect(_ selectedIndex: Int) -> Bool {
        selectedIndex == correctIndex
    }

    /// Get the correct answer text
    var correctAnswer: String {
        guard correctIndex >= 0 && correctIndex < options.count else { return "" }
        return options[correctIndex]
    }
}

// MARK: - Quiz State

/// Represents an active quiz session
struct MadiQuiz: Equatable {
    let questions: [QuizQuestion]
    var currentIndex: Int = 0
    var score: Int = 0
    var answers: [Int?] = []
    var isComplete: Bool = false

    init(questions: [QuizQuestion]) {
        self.questions = questions
        self.answers = Array(repeating: nil, count: questions.count)
    }

    /// Current question being displayed
    var currentQuestion: QuizQuestion? {
        guard currentIndex >= 0 && currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    /// Progress as a fraction (0.0 to 1.0)
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    /// Total number of questions
    var totalQuestions: Int {
        questions.count
    }

    /// Whether we're on the last question
    var isLastQuestion: Bool {
        currentIndex == questions.count - 1
    }

    /// Submit an answer for the current question
    mutating func submitAnswer(_ selectedIndex: Int) {
        guard let question = currentQuestion else { return }
        answers[currentIndex] = selectedIndex
        if question.isCorrect(selectedIndex) {
            score += 1
        }
    }

    /// Move to the next question
    mutating func nextQuestion() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else {
            isComplete = true
        }
    }

    /// Get score percentage
    var scorePercentage: Int {
        guard !questions.isEmpty else { return 0 }
        return Int((Double(score) / Double(questions.count)) * 100)
    }

    /// Get a feedback message based on score
    var feedbackMessage: String {
        let percentage = scorePercentage
        switch percentage {
        case 80...100:
            return "Excellent ! Vous maîtrisez bien le sujet. 🎉"
        case 60..<80:
            return "Bravo ! Vous avez de bonnes connaissances."
        case 40..<60:
            return "Pas mal ! Il reste quelques points à approfondir."
        default:
            return "C'est un début ! Je vous recommande de consulter nos formations."
        }
    }
}

// MARK: - Predefined Questions

extension QuizQuestion {
    /// Predefined questions about AI and generative AI
    static let iaQuestions: [QuizQuestion] = [
        QuizQuestion(
            question: "Quel modèle de langage est développé par Anthropic ?",
            options: ["GPT-4", "Claude", "Gemini", "LLaMA"],
            correctIndex: 1,
            explanation: "Claude est le modèle d'IA développé par Anthropic, connu pour son approche axée sur la sécurité et l'éthique.",
            relatedFormationSlug: "starter-pack-ia-generative"
        ),
        QuizQuestion(
            question: "Que signifie 'Prompt Engineering' ?",
            options: [
                "La programmation de robots",
                "L'art de formuler des requêtes efficaces pour l'IA",
                "La création de sites web",
                "L'ingénierie logicielle classique"
            ],
            correctIndex: 1,
            explanation: "Le Prompt Engineering est l'art de formuler des instructions claires et efficaces pour obtenir les meilleures réponses de l'IA.",
            relatedFormationSlug: "performer-pack-ia-avancee"
        ),
        QuizQuestion(
            question: "Quel type de tâche l'IA générative excelle-t-elle ?",
            options: [
                "Calculs mathématiques complexes",
                "Création de contenu (texte, images, code)",
                "Gestion de bases de données",
                "Sécurité informatique"
            ],
            correctIndex: 1,
            explanation: "L'IA générative excelle dans la création de contenu original : textes, images, musique, code et bien plus.",
            relatedFormationSlug: "starter-pack-ia-generative"
        ),
        QuizQuestion(
            question: "Qu'est-ce qu'un 'token' en IA générative ?",
            options: [
                "Une monnaie virtuelle",
                "Une unité de texte (mot ou partie de mot)",
                "Un type de connexion réseau",
                "Un certificat de sécurité"
            ],
            correctIndex: 1,
            explanation: "Un token est une unité de texte que l'IA utilise pour traiter le langage. Cela peut être un mot, une partie de mot ou même un caractère.",
            relatedFormationSlug: "performer-pack-ia-avancee"
        ),
        QuizQuestion(
            question: "Quel est le principal avantage du 'few-shot learning' ?",
            options: [
                "Il ne nécessite aucun exemple",
                "Il apprend avec seulement quelques exemples",
                "Il est plus rapide que tous les autres",
                "Il ne fonctionne qu'avec des images"
            ],
            correctIndex: 1,
            explanation: "Le few-shot learning permet à l'IA d'apprendre un nouveau concept avec seulement quelques exemples, contrairement à l'apprentissage traditionnel qui nécessite des milliers d'exemples.",
            relatedFormationSlug: "master-pack-expert-ia"
        )
    ]

    /// Questions about productivity and AI tools
    static let productivityQuestions: [QuizQuestion] = [
        QuizQuestion(
            question: "Quelle est la meilleure façon de structurer une demande à ChatGPT ?",
            options: [
                "Écrire le moins de mots possible",
                "Donner du contexte, un rôle et des instructions claires",
                "Utiliser uniquement des questions fermées",
                "Écrire en majuscules"
            ],
            correctIndex: 1,
            explanation: "Une bonne demande inclut le contexte, le rôle souhaité pour l'IA, et des instructions claires et précises.",
            relatedFormationSlug: "starter-pack-ia-generative"
        ),
        QuizQuestion(
            question: "Comment l'IA peut-elle améliorer votre productivité au travail ?",
            options: [
                "Elle remplace tous vos collègues",
                "Elle automatise les tâches répétitives et aide à la rédaction",
                "Elle ne peut pas être utilisée au travail",
                "Elle fonctionne uniquement pour le divertissement"
            ],
            correctIndex: 1,
            explanation: "L'IA peut automatiser les tâches répétitives, aider à la rédaction, analyser des données et bien plus, libérant du temps pour les tâches à haute valeur ajoutée.",
            relatedFormationSlug: "performer-pack-ia-avancee"
        ),
        QuizQuestion(
            question: "Quelle précaution prendre avec les données sensibles et l'IA ?",
            options: [
                "Aucune, l'IA est toujours sécurisée",
                "Ne jamais partager de données confidentielles avec des IA publiques",
                "Les partager uniquement le week-end",
                "Les crypter avant de les envoyer"
            ],
            correctIndex: 1,
            explanation: "Il ne faut jamais partager de données confidentielles (personnelles, entreprise) avec des IA publiques car elles peuvent être utilisées pour l'entraînement.",
            relatedFormationSlug: "master-pack-expert-ia"
        )
    ]

    /// Get a random set of questions for a quiz
    static func randomQuiz(count: Int = 5) -> [QuizQuestion] {
        let allQuestions = iaQuestions + productivityQuestions
        return Array(allQuestions.shuffled().prefix(count))
    }

    /// Get questions by category
    static func questions(for category: QuizCategory) -> [QuizQuestion] {
        switch category {
        case .ia:
            return iaQuestions
        case .productivity:
            return productivityQuestions
        case .mixed:
            return randomQuiz()
        }
    }
}

// MARK: - Quiz Category

/// Categories of quiz questions available
enum QuizCategory: String, CaseIterable {
    case ia = "Intelligence Artificielle"
    case productivity = "Productivité"
    case mixed = "Quiz mixte"

    var icon: String {
        switch self {
        case .ia: return "brain.head.profile"
        case .productivity: return "bolt.fill"
        case .mixed: return "shuffle"
        }
    }

    var description: String {
        switch self {
        case .ia:
            return "Testez vos connaissances sur l'IA générative"
        case .productivity:
            return "Questions sur l'utilisation de l'IA au quotidien"
        case .mixed:
            return "Un mélange de toutes les catégories"
        }
    }
}
