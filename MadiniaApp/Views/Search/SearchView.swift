//
//  SearchView.swift
//  MadiniaApp
//
//  Created by Madinia on 2026-01-24.
//

import SwiftUI

/// Navigation destination for all formations list
struct AllFormationsDestination: Hashable {
    let formations: [Formation]
}

/// Navigation destination for categories grid
struct CategoriesGridDestination: Hashable {}

/// Main search screen centralizing services, formations, and categories.
/// Replaces the old Formations tab with a unified search experience.
/// Based on Figma mockup "16 Search".
struct SearchView: View {
    /// ViewModel managing data and search state
    @State private var viewModel = SearchViewModel()

    /// Navigation path for programmatic navigation
    @State private var navigationPath = NavigationPath()

    /// Controls sheet presentation for service detail
    @State private var selectedService: Service?

    /// Controls navigation to all formations
    @State private var showAllFormations = false

    /// Controls navigation to all services
    @State private var showAllServices = false

    /// Controls filter sheet presentation
    @State private var showFilters = false

    /// Deep link formation slug binding (optional)
    @Binding var deepLinkFormationSlug: String?

    /// Deep link service slug binding (optional)
    @Binding var deepLinkServiceSlug: String?

    /// API service for fetching formation details
    private let apiService: APIServiceProtocol = APIService.shared

    /// Default initializer without deep link
    init() {
        self._deepLinkFormationSlug = .constant(nil)
        self._deepLinkServiceSlug = .constant(nil)
    }

    /// Initializer with deep link support
    init(deepLinkFormationSlug: Binding<String?>, deepLinkServiceSlug: Binding<String?> = .constant(nil)) {
        self._deepLinkFormationSlug = deepLinkFormationSlug
        self._deepLinkServiceSlug = deepLinkServiceSlug
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            content
                .navigationTitle("Recherche")
                .navigationBarTitleDisplayMode(.large)
                .navigationDestination(for: Formation.self) { formation in
                    FormationDetailView(formation: formation)
                }
                .navigationDestination(for: FormationCategory.self) { category in
                    CategoryListView(
                        category: category,
                        formations: viewModel.formations
                    )
                }
                .navigationDestination(isPresented: $showAllFormations) {
                    AllFormationsListView(formations: viewModel.formations)
                }
                .navigationDestination(isPresented: $showAllServices) {
                    AllServicesListView(services: viewModel.services)
                }
                .navigationDestination(for: CategoriesGridDestination.self) { _ in
                    CategoriesGridView { category in
                        navigationPath.append(category)
                    }
                }
        }
        .sheet(item: $selectedService) { service in
            ServiceDetailView(service: service)
        }
        .onChange(of: deepLinkFormationSlug) { _, newSlug in
            guard let slug = newSlug else { return }
            Task {
                await navigateToFormation(slug: slug)
            }
        }
        .onChange(of: deepLinkServiceSlug) { _, newSlug in
            guard let slug = newSlug else { return }
            Task {
                await navigateToService(slug: slug)
            }
        }
        .task(id: deepLinkFormationSlug) {
            // Handle initial value when view appears with a slug already set
            guard let slug = deepLinkFormationSlug else { return }
            await navigateToFormation(slug: slug)
        }
        .task(id: deepLinkServiceSlug) {
            // Handle initial value when view appears with a slug already set
            guard let slug = deepLinkServiceSlug else { return }
            await navigateToService(slug: slug)
        }
    }

    /// Navigate to a formation by fetching it from the API
    @MainActor
    private func navigateToFormation(slug: String) async {
        do {
            let formation = try await apiService.fetchFormation(slug: slug)
            navigationPath.append(formation)
            deepLinkFormationSlug = nil
        } catch {
            print("Failed to fetch formation for deep link: \(error)")
            deepLinkFormationSlug = nil
        }
    }

    /// Navigate to a service by finding it in the viewModel
    @MainActor
    private func navigateToService(slug: String) async {
        // Wait for data to load if needed
        if viewModel.services.isEmpty {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
        }

        if let service = viewModel.services.first(where: { $0.slug == slug }) {
            selectedService = service
        }
        deepLinkServiceSlug = nil
    }

    // MARK: - Content View

    @ViewBuilder
    private var content: some View {
        // Data is preloaded during splash - show content directly
        // Only show error if there's no data at all
        if viewModel.services.isEmpty && viewModel.formations.isEmpty && viewModel.categories.isEmpty {
            if let error = AppDataRepository.shared.errorMessage {
                ErrorView(message: error) {
                    Task { await viewModel.refresh() }
                }
            } else {
                // Fallback empty state (shouldn't happen normally)
                ContentUnavailableView {
                    Label("Aucune donnée", systemImage: "magnifyingglass")
                } description: {
                    Text("Tirez vers le bas pour actualiser")
                }
            }
        } else {
            mainContent
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MadiniaSpacing.lg) {
                // Search bar with filter button
                HStack(spacing: MadiniaSpacing.sm) {
                    SearchBar(text: $viewModel.searchQuery)

                    FilterButton(activeCount: viewModel.filters.activeFiltersCount) {
                        showFilters = true
                    }
                }
                .padding(.horizontal, MadiniaSpacing.md)

                // Active filters chips
                if viewModel.filters.hasActiveFilters {
                    ActiveFiltersChipsView(
                        filters: viewModel.filters,
                        categories: viewModel.categories
                    )
                }

                if viewModel.isSearching || viewModel.filters.hasActiveFilters {
                    // Search/filter results
                    searchResultsContent
                } else {
                    // Default sections
                    defaultSectionsContent
                }
            }
            .padding(.vertical, MadiniaSpacing.md)
            .tabBarSafeArea()
        }
        .refreshable {
            await viewModel.refresh()
        }
        .sheet(isPresented: $showFilters) {
            SearchFiltersView(
                filters: viewModel.filters,
                categories: viewModel.categories,
                onApply: {}
            )
            .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Default Sections (No Search)

    private var defaultSectionsContent: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.xl) {
            // Categories section
            categoriesSection

            // Services section ("Nos Services")
            servicesSection

            // Formations section ("Nos Formations")
            formationsSection
        }
    }

    // MARK: - Categories Section

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            SectionHeader(title: "Catégories") {
                navigationPath.append(CategoriesGridDestination())
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MadiniaSpacing.sm) {
                    ForEach(viewModel.categories) { category in
                        CategoryCard(category: category) {
                            navigationPath.append(category)
                        }
                    }
                }
                .padding(.horizontal, MadiniaSpacing.md)
            }
        }
    }

    // MARK: - Services Section

    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            SectionHeader(title: "Nos Services") {
                showAllServices = true
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MadiniaSpacing.sm) {
                    ForEach(viewModel.services) { service in
                        ServiceCard(service: service) {
                            selectedService = service
                        }
                    }
                }
                .padding(.horizontal, MadiniaSpacing.md)
            }
        }
    }

    // MARK: - Formations Section

    private var formationsSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            SectionHeader(title: "Nos Formations") {
                // Navigate to all formations list
                showAllFormations = true
            }

            VStack(spacing: MadiniaSpacing.sm) {
                ForEach(viewModel.formations.prefix(5)) { formation in
                    FormationRowCard(formation: formation) {
                        navigationPath.append(formation)
                    }
                }
            }
            .padding(.horizontal, MadiniaSpacing.md)
        }
    }

    // MARK: - Search Results

    private var searchResultsContent: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.lg) {
            // Results count header
            if viewModel.filters.hasActiveFilters || viewModel.isSearching {
                resultsCountHeader
            }

            if !viewModel.hasSearchResults {
                // No results
                noResultsView
            } else {
                // Categories results (only when searching by text)
                if viewModel.isSearching && !viewModel.filteredCategories.isEmpty {
                    searchCategoriesSection
                }

                // Services results
                if !viewModel.filteredServices.isEmpty {
                    searchServicesSection
                }

                // Formations results
                if !viewModel.filteredFormations.isEmpty {
                    searchFormationsSection
                }
            }
        }
    }

    private var resultsCountHeader: some View {
        HStack {
            let formationsCount = viewModel.filteredFormations.count
            let servicesCount = viewModel.filteredServices.count

            if viewModel.isSearching || viewModel.filters.hasActiveFilters {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(formationsCount) formation\(formationsCount > 1 ? "s" : "") • \(servicesCount) service\(servicesCount > 1 ? "s" : "")")
                        .font(MadiniaTypography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if viewModel.filters.hasActiveFilters {
                Button {
                    viewModel.filters.reset()
                } label: {
                    Text("Effacer")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(MadiniaColors.accent)
                }
            }
        }
        .padding(.horizontal, MadiniaSpacing.md)
    }

    private var noResultsView: some View {
        VStack(spacing: MadiniaSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("Aucun résultat pour \"\(viewModel.searchQuery)\"")
                .font(MadiniaTypography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, MadiniaSpacing.xxl)
    }

    private var searchCategoriesSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            Text("Catégories")
                .font(MadiniaTypography.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, MadiniaSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MadiniaSpacing.sm) {
                    ForEach(viewModel.filteredCategories) { category in
                        CategoryCard(category: category) {
                            navigationPath.append(category)
                        }
                    }
                }
                .padding(.horizontal, MadiniaSpacing.md)
            }
        }
    }

    private var searchServicesSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            Text("Services (\(viewModel.filteredServices.count))")
                .font(MadiniaTypography.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, MadiniaSpacing.md)

            VStack(spacing: MadiniaSpacing.sm) {
                ForEach(viewModel.filteredServices) { service in
                    ServiceRowCard(service: service) {
                        selectedService = service
                    }
                }
            }
            .padding(.horizontal, MadiniaSpacing.md)
        }
    }

    private var searchFormationsSection: some View {
        VStack(alignment: .leading, spacing: MadiniaSpacing.sm) {
            Text("Formations")
                .font(MadiniaTypography.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, MadiniaSpacing.md)

            VStack(spacing: MadiniaSpacing.sm) {
                ForEach(viewModel.filteredFormations) { formation in
                    FormationRowCard(formation: formation) {
                        navigationPath.append(formation)
                    }
                }
            }
            .padding(.horizontal, MadiniaSpacing.md)
        }
    }
}

// MARK: - Previews

#Preview {
    SearchView()
}
