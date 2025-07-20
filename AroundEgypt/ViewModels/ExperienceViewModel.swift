//
//  ExperienceViewModel.swift
//  AroundEgypt
//
//  Created by Mohamed Shendy on 18/07/2025.
//

import Foundation
import Combine // Added for Combine publishers


/// ViewModel for managing experiences, recommended experiences, and related actions.
/// Handles networking, caching, search, and like logic.
@MainActor
class ExperiencesViewModel: ObservableObject {
    @Published var experiences: [Experience] = []
    @Published var recommended: [Experience] = []
    @Published var isLoading = false
    @Published var searchText: String = ""
    @Published var error: AppError? = nil
    @Published var searchResults: [Experience]? = nil // nil = not searching, [] = no results
    @Published var isSearching: Bool = false
    @Published var searchError: AppError? = nil
    
    private let cache = ExperienceCacheManager()
    private let api: APIServiceProtocol
    private let likesService = LikesService()
    private var cancellables = Set<AnyCancellable>() // Added for Combine publishers
    
    /// Initializes the ViewModel with an API service (default: APIService.shared).
    init(api: APIServiceProtocol = APIService.shared) {
        self.api = api
        // Remove debounce and local filtering on searchText changes
    }
    
    /// Returns the set of liked experience IDs.
    var likedExperienceIDs: Set<String> {
        likesService.likedExperienceIDs
    }
    /// Adds an experience ID to the liked set.
    private func addLikedExperienceID(_ id: String) {
        likesService.addLikedExperienceID(id)
    }
    
    /// Triggers a remote search for experiences by query, updating searchResults.
    @MainActor
    func submitSearch() async {
        guard !searchText.isEmpty else { return }
        isSearching = true
        searchError = nil
        defer { isSearching = false }
        if NetworkMonitor.shared.isConnected {
            do {
                let results = try await api.searchExperiences(query: searchText)
                self.searchResults = applyLikedState(to: results)
                if results.isEmpty {
                    self.searchError = .searchNoResults
                }
            } catch {
                self.searchError = .network
                self.searchResults = []
            }
        } else {
            // Fallback to local filter (in-memory) if offline
            let filtered = experiences.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
            self.searchResults = applyLikedState(to: filtered)
            if filtered.isEmpty {
                self.searchError = .searchNoResults
            }
        }
    }
    
    /// Loads recent experiences from the network or cache.
    /// Sets error if loading fails or no cache is available.
    func loadPlaces() async {
        isLoading = true
        defer { isLoading = false }
        if NetworkMonitor.shared.isConnected {
            do {
                let experiences = try await api.fetchRecentExperiences()
                let withLiked = applyLikedState(to: experiences)
                self.experiences = withLiked
                self.cache.saveExperiences(withLiked, "recommended >= 0")
            } catch {
                self.error = .network
                return
            }
        } else {
            let cached = cache.fetchCachedExperiences("recommended >= 0")
            self.experiences = applyLikedState(to: cached)
            if cached.isEmpty {
                self.error = .noCache
                return
            }
        }
    }
    
    /// Loads recommended experiences from the network or cache.
    /// Sets error if loading fails or no cache is available.
    func loadRecommended() async {
        isLoading = true
        defer { isLoading = false }
        if NetworkMonitor.shared.isConnected {
            do {
                let recs = try await api.fetchRecommendedExperiences()
                let withLiked = applyLikedState(to: recs)
                self.recommended = withLiked
                self.cache.saveExperiences(withLiked, "recommended != 0")
            } catch {
                self.error = .network
                return
            }
        } else {
            let cached = cache.fetchCachedExperiences("recommended != 0")
            self.recommended = applyLikedState(to: cached)
            if cached.isEmpty {
                self.error = .noCache
                return
            }
        }
    }
    
    /// Fetches experience details by ID, using network or cache.
    /// Sets error if details cannot be loaded.
    func fetchExperienceDetails(id: String) async -> Experience? {
        if NetworkMonitor.shared.isConnected {
            do {
                return try await api.fetchSingleExperience(id: id)
            } catch {
                self.error = .details
                return nil
            }
        }
        let cached = cache.fetchCachedExperiences("")
        let exp = cached.first(where: { $0.id == id })
        if exp == nil {
            self.error = .noCache
        }
        return exp
    }
    
    /// Likes an experience by calling the API and updating local state.
    /// Sets error if the like fails.
    @MainActor
    func likeExperience(_ experience: Experience) async {
        guard !experience.isLiked else { return }
        do {
            let newLikes = try await api.likeExperience(id: experience.id)
            if let idx = experiences.firstIndex(where: { $0.id == experience.id }) {
                experiences[idx].likesNo = newLikes
                experiences[idx].isLiked = true
                addLikedExperienceID(experience.id)
            }
            if let idx = recommended.firstIndex(where: { $0.id == experience.id }) {
                recommended[idx].likesNo = newLikes
                recommended[idx].isLiked = true
                addLikedExperienceID(experience.id)
            }
        } catch {
            self.error = .like
            return
        }
    }
    
    /// Applies liked state to a list of experiences based on the liked IDs.
    private func applyLikedState(to experiences: [Experience]) -> [Experience] {
        let liked = likedExperienceIDs
        return experiences.map { exp in
            var exp = exp
            exp.isLiked = liked.contains(exp.id)
            return exp
        }
    }
    
    /// Clears the current error.
    func clearError() {
        self.error = nil
    }
}

