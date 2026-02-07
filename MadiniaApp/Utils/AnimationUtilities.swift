//
//  AnimationUtilities.swift
//  MadiniaApp
//
//  Utilitaires d'animation et view modifiers pour des transitions fluides.
//

import SwiftUI

// MARK: - Animation Presets

/// Preset d'animations cohérentes pour l'app
enum MadiniaAnimation {
    /// Animation rapide pour les micro-interactions
    static let quick = Animation.easeOut(duration: 0.15)

    /// Animation standard pour les transitions
    static let standard = Animation.easeInOut(duration: 0.25)

    /// Animation douce pour les apparitions
    static let gentle = Animation.easeOut(duration: 0.35)

    /// Animation spring pour les interactions
    static let spring = Animation.spring(response: 0.35, dampingFraction: 0.7)

    /// Animation spring légère
    static let springLight = Animation.spring(response: 0.3, dampingFraction: 0.8)

    /// Animation spring rebondissante
    static let springBouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)

    /// Animation pour les listes (staggered)
    static let list = Animation.easeOut(duration: 0.3)

    /// Animation de fade
    static let fade = Animation.easeInOut(duration: 0.2)
}

// MARK: - Transition Presets

/// Transitions prédéfinies pour les vues
extension AnyTransition {
    /// Slide et fade depuis le bas
    static var slideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        )
    }

    /// Slide et fade depuis le haut
    static var slideDown: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }

    /// Scale et fade (pour les modales, popovers)
    static var scaleAndFade: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .scale(scale: 0.95).combined(with: .opacity)
        )
    }

    /// Scale depuis le centre avec bounce
    static var scaleBounce: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 0.9).combined(with: .opacity)
        )
    }

}

// MARK: - View Modifiers

/// Modifier pour animer l'apparition avec un délai (staggered animation)
struct StaggeredAppearance: ViewModifier {
    let index: Int
    let baseDelay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(MadiniaAnimation.gentle.delay(baseDelay * Double(index))) {
                    isVisible = true
                }
            }
    }
}

/// Modifier pour un effet de press scale
struct PressScaleEffect: ViewModifier {
    @State private var isPressed = false
    let scale: CGFloat

    init(scale: CGFloat = 0.95) {
        self.scale = scale
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(MadiniaAnimation.quick, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

/// Modifier pour un effet de shimmer sur le texte ou les éléments
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.5),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.5)
                    .offset(x: phase * geometry.size.width * 1.5 - geometry.size.width * 0.25)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

/// Modifier pour un pulse effect (notifications, badges)
struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    let color: Color

    func body(content: Content) -> some View {
        content
            .background(
                Circle()
                    .fill(color.opacity(0.3))
                    .scaleEffect(isPulsing ? 1.5 : 1)
                    .opacity(isPulsing ? 0 : 0.5)
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: false)
                ) {
                    isPulsing = true
                }
            }
    }
}

/// Modifier pour un effet de shake (erreur)
struct ShakeEffect: ViewModifier {
    @Binding var trigger: Bool
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    withAnimation(.linear(duration: 0.05).repeatCount(5, autoreverses: true)) {
                        offset = 8
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        offset = 0
                        trigger = false
                    }
                }
            }
    }
}

/// Modifier pour une entrée animée depuis une direction
struct SlideInFromEdge: ViewModifier {
    let edge: Edge
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .offset(x: xOffset, y: yOffset)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(MadiniaAnimation.spring) {
                    isVisible = true
                }
            }
    }

    private var xOffset: CGFloat {
        guard !isVisible else { return 0 }
        switch edge {
        case .leading: return -50
        case .trailing: return 50
        default: return 0
        }
    }

    private var yOffset: CGFloat {
        guard !isVisible else { return 0 }
        switch edge {
        case .top: return -50
        case .bottom: return 50
        default: return 0
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Animation staggered pour les listes
    func staggeredAppearance(index: Int, baseDelay: Double = 0.05) -> some View {
        modifier(StaggeredAppearance(index: index, baseDelay: baseDelay))
    }

    /// Effet de scale au press
    func pressScale(_ scale: CGFloat = 0.95) -> some View {
        modifier(PressScaleEffect(scale: scale))
    }

    /// Effet shimmer
    func shimmerEffect() -> some View {
        modifier(ShimmerEffect())
    }

    /// Effet pulse (pour badges, notifications)
    func pulseEffect(color: Color = MadiniaColors.accent) -> some View {
        modifier(PulseEffect(color: color))
    }

    /// Effet shake (pour erreurs)
    func shakeOnError(trigger: Binding<Bool>) -> some View {
        modifier(ShakeEffect(trigger: trigger))
    }

    /// Entrée animée depuis un bord
    func slideIn(from edge: Edge) -> some View {
        modifier(SlideInFromEdge(edge: edge))
    }

    /// Animation de fade in
    func fadeIn(delay: Double = 0) -> some View {
        self
            .opacity(0)
            .onAppear {
                withAnimation(MadiniaAnimation.fade.delay(delay)) {
                    // L'opacity sera gérée par le parent
                }
            }
    }

    /// Animation conditionnelle basée sur un état
    func animateOnChange<V: Equatable>(of value: V, animation: Animation = MadiniaAnimation.standard) -> some View {
        self.animation(animation, value: value)
    }
}

// MARK: - Previews

#Preview("Staggered List") {
    ScrollView {
        VStack(spacing: 12) {
            ForEach(0..<10, id: \.self) { index in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.purple.opacity(0.2))
                    .frame(height: 60)
                    .staggeredAppearance(index: index)
            }
        }
        .padding()
    }
}

#Preview("Press Scale") {
    Button("Tap me") {}
        .padding()
        .background(Color.purple)
        .foregroundColor(.white)
        .cornerRadius(12)
        .pressScale()
}

#Preview("Pulse Effect") {
    Circle()
        .fill(Color.purple)
        .frame(width: 20, height: 20)
        .pulseEffect(color: .purple)
        .padding(40)
}
