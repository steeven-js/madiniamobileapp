//
//  MadiQuizView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-02-06.
//

import SwiftUI

// MARK: - Quiz View

/// Interactive quiz view for testing AI knowledge
struct MadiQuizView: View {
    @State private var quiz: MadiQuiz
    @State private var selectedAnswer: Int?
    @State private var showExplanation = false
    @State private var animateScore = false

    @Environment(\.dismiss) private var dismiss

    let onComplete: (Int, Int) -> Void // score, total

    init(questions: [QuizQuestion], onComplete: @escaping (Int, Int) -> Void) {
        self._quiz = State(initialValue: MadiQuiz(questions: questions))
        self.onComplete = onComplete
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if quiz.isComplete {
                    resultView
                } else {
                    questionView
                }
            }
            .navigationTitle("Quiz IA")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Question View

    private var questionView: some View {
        VStack(spacing: 24) {
            // Progress indicator
            progressBar

            // Question
            if let question = quiz.currentQuestion {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Question \(quiz.currentIndex + 1)/\(quiz.totalQuestions)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(question.question)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

                // Answer options
                VStack(spacing: 12) {
                    ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                        answerButton(index: index, text: option, question: question)
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Explanation (shown after answering)
                if showExplanation {
                    explanationView(for: question)
                }

                // Next button
                if selectedAnswer != nil {
                    nextButton
                }
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.systemGray5))

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [MadiniaColors.accent, MadiniaColors.violet],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * quiz.progress)
                    .animation(.easeInOut(duration: 0.3), value: quiz.progress)
            }
        }
        .frame(height: 4)
    }

    private func answerButton(index: Int, text: String, question: QuizQuestion) -> some View {
        let isSelected = selectedAnswer == index
        let isCorrect = question.correctIndex == index
        let hasAnswered = selectedAnswer != nil

        let backgroundColor: Color = {
            if hasAnswered {
                if isCorrect {
                    return Color.green.opacity(0.2)
                } else if isSelected {
                    return Color.red.opacity(0.2)
                }
            }
            return isSelected ? MadiniaColors.accent.opacity(0.1) : Color(.secondarySystemBackground)
        }()

        let borderColor: Color = {
            if hasAnswered {
                if isCorrect {
                    return .green
                } else if isSelected {
                    return .red
                }
            }
            return isSelected ? MadiniaColors.accent : .clear
        }()

        return Button {
            guard selectedAnswer == nil else { return }
            selectedAnswer = index
            quiz.submitAnswer(index)
            withAnimation(.easeInOut(duration: 0.3)) {
                showExplanation = true
            }
        } label: {
            HStack {
                Text(optionLetter(for: index))
                    .font(.headline)
                    .foregroundStyle(hasAnswered && isCorrect ? .green : .secondary)
                    .frame(width: 30)

                Text(text)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)

                Spacer()

                if hasAnswered {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : (isSelected ? "xmark.circle.fill" : ""))
                        .foregroundStyle(isCorrect ? .green : .red)
                }
            }
            .padding()
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .disabled(selectedAnswer != nil)
    }

    private func optionLetter(for index: Int) -> String {
        let letters = ["A", "B", "C", "D"]
        return index < letters.count ? letters[index] : "\(index + 1)"
    }

    private func explanationView(for question: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("Explication")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Text(question.explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var nextButton: some View {
        Button {
            withAnimation {
                if quiz.isLastQuestion {
                    quiz.nextQuestion()
                } else {
                    quiz.nextQuestion()
                    selectedAnswer = nil
                    showExplanation = false
                }
            }
        } label: {
            Text(quiz.isLastQuestion ? "Voir les résultats" : "Question suivante")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(MadiniaColors.accent)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }

    // MARK: - Result View

    private var resultView: some View {
        VStack(spacing: 32) {
            Spacer()

            // Score circle
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 12)
                    .frame(width: 160, height: 160)

                Circle()
                    .trim(from: 0, to: animateScore ? Double(quiz.score) / Double(quiz.totalQuestions) : 0)
                    .stroke(
                        LinearGradient(
                            colors: [MadiniaColors.accent, MadiniaColors.violet],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.0), value: animateScore)

                VStack(spacing: 4) {
                    Text("\(quiz.score)/\(quiz.totalQuestions)")
                        .font(.system(size: 36, weight: .bold))
                    Text("\(quiz.scorePercentage)%")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }

            // Feedback
            VStack(spacing: 12) {
                Text(quiz.feedbackMessage)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                Text("Continuez à apprendre avec nos formations !")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 32)

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                Button {
                    onComplete(quiz.score, quiz.totalQuestions)
                    dismiss()
                } label: {
                    Text("Voir les recommandations")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(MadiniaColors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    dismiss()
                } label: {
                    Text("Fermer")
                        .font(.headline)
                        .foregroundStyle(MadiniaColors.accent)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(MadiniaColors.accent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateScore = true
            }
        }
    }
}

// MARK: - Previews

#Preview("Quiz Question") {
    MadiQuizView(
        questions: QuizQuestion.iaQuestions,
        onComplete: { score, total in
            print("Score: \(score)/\(total)")
        }
    )
}

#Preview("Quiz Result") {
    struct PreviewWrapper: View {
        @State var quiz = MadiQuiz(questions: Array(QuizQuestion.iaQuestions.prefix(3)))

        var body: some View {
            MadiQuizView(
                questions: Array(QuizQuestion.iaQuestions.prefix(3)),
                onComplete: { _, _ in }
            )
        }
    }
    return PreviewWrapper()
}
