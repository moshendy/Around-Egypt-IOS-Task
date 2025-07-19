//
//  ExperienceViewModel.swift
//  AroundEgypt
//
//  Created by Mohamed Shendy on 18/07/2025.
//

import Foundation


@MainActor
class ExperiencesViewModel: ObservableObject {
    @Published var experiences: [Experience] = []
    @Published var recommended: [Experience] = []
    @Published var isLoading = false
    @Published var searchText: String = ""
    @Published var errorMessage: String? = nil
    
    var isSearching: Bool { !searchText.isEmpty }
    var filteredExperiences: [Experience] {
        if searchText.isEmpty {
            return experiences
        } else {
            return experiences.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private let cache = ExperienceCacheManager()
    private let api: APIServiceProtocol
    private let likedKey = "likedExperienceIDs"

    init(api: APIServiceProtocol = APIService.shared) {
        self.api = api
    }
    
    // Public getter for outside use
    var likedExperienceIDs: Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: likedKey) ?? [])
    }
    // Private method to update liked IDs
    private func addLikedExperienceID(_ id: String) {
        var liked = likedExperienceIDs
        liked.insert(id)
        UserDefaults.standard.set(Array(liked), forKey: likedKey)
    }

    private func applyLikedState(to experiences: [Experience]) -> [Experience] {
        let liked = likedExperienceIDs
        return experiences.map { exp in
            var exp = exp
            exp.isLiked = liked.contains(exp.id)
            return exp
        }
    }

    func loadPlaces() async {
        isLoading = true
        if NetworkMonitor.shared.isConnected {
            do {
                let experiences = try await api.fetchRecentExperiences()
                let withLiked = applyLikedState(to: experiences)
                self.experiences = withLiked
                self.cache.saveExperiences(withLiked)
            } catch {
                self.errorMessage = "Failed to load recent experiences. Please try again."
            }
        } else {
            let cached = cache.fetchCachedExperiences()
            self.experiences = applyLikedState(to: cached)
            if cached.isEmpty {
                self.errorMessage = "No cached experiences available offline."
            }
        }
        isLoading = false
    }

    func loadRecommended() async {
        isLoading = true
        if NetworkMonitor.shared.isConnected {
            do {
                let recs = try await api.fetchRecommendedExperiences()
                let withLiked = applyLikedState(to: recs)
                self.recommended = withLiked
                self.cache.saveRecommendedExperiences(withLiked)
            } catch {
                self.errorMessage = "Failed to load recommended experiences. Please try again."
            }
        } else {
            let cached = cache.fetchCachedRecommendedExperiences()
            self.recommended = applyLikedState(to: cached)
            if cached.isEmpty {
                self.errorMessage = "No cached recommended experiences available offline."
            }
        }
        isLoading = false
    }

    @MainActor
    func searchExperiences(query: String) async {
        isLoading = true
        if NetworkMonitor.shared.isConnected {
            do {
                let results = try await api.searchExperiences(query: query)
                self.experiences = applyLikedState(to: results)
                if results.isEmpty {
                    self.errorMessage = "No experiences found for your search."
                }
            } catch {
                self.errorMessage = "Failed to search experiences. Please try again."
            }
        } else {
            let cached = cache.fetchCachedExperiences()
            let filtered = cached.filter { $0.title.localizedCaseInsensitiveContains(query) }
            self.experiences = applyLikedState(to: filtered)
            if filtered.isEmpty {
                self.errorMessage = "No cached experiences found for your search."
            }
        }
        isLoading = false
    }

    func fetchExperienceDetails(id: String) async -> Experience? {
        if NetworkMonitor.shared.isConnected {
            do {
                return try await api.fetchSingleExperience(id: id)
            } catch {
                self.errorMessage = "Failed to load experience details. Please try again."
            }
        }
        let cached = cache.fetchCachedExperiences()
        let exp = cached.first(where: { $0.id == id })
        if exp == nil {
            self.errorMessage = "No cached details available for this experience."
        }
        return exp
    }

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
            self.errorMessage = "Failed to like experience. Please try again."
        }
    }
    func clearError() {
        self.errorMessage = nil
    }
}

