//
//  SavedFormationsViewModel.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-25.
//

import Foundation

/// ViewModel for managing saved formations display
@Observable
final class SavedFormationsViewModel {
    /// Current loading state (includes formations when loaded)
    var loadingState: LoadingState<[Formation]> = .idle

    /// Reference to the favorites service
    private let favoritesService = FavoritesService.shared

    /// Convenience accessor for formations
    var formations: [Formation] {
        loadingState.value ?? []
    }

    // MARK: - Public Methods

    /// Load saved formations from the server
    @MainActor
    func loadSavedFormations() async {
        loadingState = .loading

        do {
            let formations = try await favoritesService.fetchSavedFormations()
            loadingState = .loaded(formations)
        } catch {
            loadingState = .error(error.localizedDescription)
            #if DEBUG
            print("Failed to load saved formations: \(error)")
            #endif
        }
    }

    /// Remove a formation from favorites
    @MainActor
    func removeFavorite(formationId: Int) async {
        await favoritesService.removeFavorite(formationId: formationId)
        // Update the loaded state with the formation removed
        if case .loaded(var currentFormations) = loadingState {
            currentFormations.removeAll { $0.id == formationId }
            loadingState = .loaded(currentFormations)
        }
    }

    /// Refresh the list (for pull-to-refresh)
    @MainActor
    func refresh() async {
        // First sync the favorites service
        await favoritesService.syncWithServer()
        // Then reload formations
        await loadSavedFormations()
    }
}
