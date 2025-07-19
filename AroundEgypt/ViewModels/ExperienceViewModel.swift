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
    @Published var isLoading = false
    @Published var searchText: String = ""
    var filteredExperiences: [Experience] {
        if searchText.isEmpty {
            return experiences
        } else {
            return experiences.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    @Published var recommended: [Experience] = []
    var isSearching: Bool { !searchText.isEmpty }

    private let cache = ExperienceCacheManager()
    private let network = APIService.shared
    private let likedKey = "likedExperienceIDs"
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
                let experiences = try await APIService.shared.fetchRecentExperiences()
                let withLiked = applyLikedState(to: experiences)
                self.experiences = withLiked
                self.cache.saveExperiences(withLiked)
            } catch {
                print("Recommended error:", error)
            }
        } else {
            // Load from cache if offline
            let cached = cache.fetchCachedExperiences()
            self.experiences = applyLikedState(to: cached)
        }
        isLoading = false
    }

    func loadRecommended() async {
        isLoading = true
        if NetworkMonitor.shared.isConnected {
            do {
                let recs = try await APIService.shared.fetchRecommendedExperiences()
                let withLiked = applyLikedState(to: recs)
                self.recommended = withLiked
                self.cache.saveRecommendedExperiences(withLiked)
            } catch {
                print("Failed to load recommended experiences:", error)
            }
        } else {
            // Load from cache if offline
            let cached = cache.fetchCachedRecommendedExperiences()
            self.recommended = applyLikedState(to: cached)
        }
        isLoading = false
    }

    @MainActor
    func searchExperiences(query: String) async {
        isLoading = true
        
        if NetworkMonitor.shared.isConnected {
            do {
                let results = try await APIService.shared.searchExperiences(query: query)
                self.experiences = applyLikedState(to: results)
            } catch {
                print("Search error:", error)
            }
        } else {
            let cached = cache.fetchCachedExperiences()
            self.experiences = applyLikedState(to: cached.filter { $0.title.localizedCaseInsensitiveContains(query) })
        }
        isLoading = false
    }

    func fetchExperienceDetails(id: String) async -> Experience? {
        if NetworkMonitor.shared.isConnected {
            do {
                return try await APIService.shared.fetchSingleExperience(id: id)
            } catch {
                print("Failed to fetch details from API:", error)
            }
        }
        // Fallback to cache
        let cached = cache.fetchCachedExperiences()
        return cached.first(where: { $0.id == id })
    }

    @MainActor
    func likeExperience(_ experience: Experience) async {
        guard !experience.isLiked else { return }
        do {
            let newLikes = try await APIService.shared.likeExperience(id: experience.id)
            // Update in experiences
            if let idx = experiences.firstIndex(where: { $0.id == experience.id }) {
                experiences[idx].likesNo = newLikes
                experiences[idx].isLiked = true
                addLikedExperienceID(experience.id)
            }
            // Update in recommended
            if let idx = recommended.firstIndex(where: { $0.id == experience.id }) {
                recommended[idx].likesNo = newLikes
                recommended[idx].isLiked = true
                addLikedExperienceID(experience.id)
            }
        } catch {
            print("Failed to like experience:", error)
        }
    }
}

