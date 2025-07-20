import Foundation
@testable import AroundEgypt

class MockAPIService: APIServiceProtocol {
    var shouldThrow = false
    var experiences: [Experience] = []

    func fetchRecommendedExperiences() async throws -> [Experience] {
        if shouldThrow { throw URLError(.badServerResponse) }
        return experiences
    }
    func fetchRecentExperiences() async throws -> [Experience] {
        if shouldThrow { throw URLError(.badServerResponse) }
        return experiences
    }
    func searchExperiences(query: String) async throws -> [Experience] {
        if shouldThrow { throw URLError(.badServerResponse) }
        return experiences.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
    func fetchSingleExperience(id: String) async throws -> Experience {
        if shouldThrow { throw URLError(.badServerResponse) }
        guard let exp = experiences.first(where: { $0.id == id }) else { throw URLError(.fileDoesNotExist) }
        return exp
    }
    func likeExperience(id: String) async throws -> Int {
        if shouldThrow { throw URLError(.badServerResponse) }
        return 42
    }
} 