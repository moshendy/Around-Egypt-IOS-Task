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

    private let cache = ExperienceCacheManager()
    private let network = APIService.shared

    func loadPlaces() async {
        // Step 1: Show cached
        self.experiences = cache.fetchCachedExperiences()

        // Step 2: Fetch from API
        isLoading = true

        do {
            let experiences = try await APIService.shared.fetchRecentExperiences()
            self.experiences = experiences
            self.cache.saveExperiences(experiences)
        } catch {
            print("Recommended error:", error)
        }
        

    }
}

