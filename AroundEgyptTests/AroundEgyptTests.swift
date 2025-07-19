//
//  AroundEgyptTests.swift
//  AroundEgyptTests
//
//  Created by Mohamed Shendy on 19/07/2025.
//

import XCTest
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

@MainActor
final class AroundEgyptTests: XCTestCase {
    var viewModel: ExperiencesViewModel!
    var mockAPI: MockAPIService!

    override func setUp() {
        super.setUp()
        mockAPI = MockAPIService()
        viewModel = ExperiencesViewModel(api: mockAPI)
    }

    func testInitialExperiencesEmpty() {
        XCTAssertTrue(viewModel.experiences.isEmpty)
        XCTAssertTrue(viewModel.recommended.isEmpty)
    }

    func testSearchFiltersExperiences() async {
        await MainActor.run {
            viewModel.experiences = [
                Experience(id: "1", title: "Pyramids", coverPhoto: "", description: "", viewsNo: 0, likesNo: 0, recommended: 0, hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: ""),
                Experience(id: "2", title: "Luxor Temple", coverPhoto: "", description: "", viewsNo: 0, likesNo: 0, recommended: 0, hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: "")
            ]
            viewModel.searchText = "Luxor"
            let filtered = viewModel.filteredExperiences
            XCTAssertEqual(filtered.count, 1)
            XCTAssertEqual(filtered.first?.title, "Luxor Temple")
        }
    }

    func testSearchNoResults() {
        viewModel.experiences = [
            Experience(id: "1", title: "Pyramids", coverPhoto: "", description: "", viewsNo: 0, likesNo: 0, recommended: 0, hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: "")
        ]
        viewModel.searchText = "Luxor"
        XCTAssertTrue(viewModel.filteredExperiences.isEmpty)
    }

    func testRecommendedExperiencesFiltering() {
        let rec = Experience(id: "1", title: "Pyramids", coverPhoto: "", description: "", viewsNo: 0, likesNo: 0, recommended: 1, hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: "")
        let nonRec = Experience(id: "2", title: "Luxor", coverPhoto: "", description: "", viewsNo: 0, likesNo: 0, recommended: 0, hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: "")
        viewModel.recommended = [rec, nonRec]
        XCTAssertEqual(viewModel.recommended.filter { $0.recommended != 0 }.count, 1)
    }

    func testLikeExperienceUpdatesState() async {
        let exp = Experience(id: "1", title: "Pyramids", coverPhoto: "", description: "", viewsNo: 0, likesNo: 0, recommended: 0, hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: "")
        viewModel.experiences = [exp]
        await viewModel.likeExperience(exp)
        XCTAssertTrue(viewModel.experiences[0].isLiked)
    }

    func testLoadPlacesHandlesError() async {
        mockAPI.shouldThrow = true
        await viewModel.loadPlaces()
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testLoadPlacesLoadsExperiences() async {
        mockAPI.shouldThrow = false
        mockAPI.experiences = [
            Experience(id: "1", title: "Test", coverPhoto: "", description: "", viewsNo: 0, likesNo: 0, recommended: 0, hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: "")
        ]
        await viewModel.loadPlaces()
        XCTAssertEqual(viewModel.experiences.count, 1)
        XCTAssertEqual(viewModel.experiences.first?.title, "Test")
    }

    func testSearchExperiencesAsyncSuccess() async {
        mockAPI.shouldThrow = false
        mockAPI.experiences = [
            Experience(id: "1", title: "Cairo Tower", coverPhoto: "", description: "", viewsNo: 0, likesNo: 0, recommended: 0, hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: "")
        ]
        await viewModel.searchExperiences(query: "Cairo")
        XCTAssertEqual(viewModel.experiences.count, 1)
        XCTAssertEqual(viewModel.experiences.first?.title, "Cairo Tower")
        XCTAssertNil(viewModel.errorMessage)
    }

    func testSearchExperiencesAsyncError() async {
        mockAPI.shouldThrow = true
        await viewModel.searchExperiences(query: "Cairo")
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testLikeExperienceErrorHandling() async {
        mockAPI.shouldThrow = true
        let exp = Experience(id: "1", title: "Pyramids", coverPhoto: "", description: "", viewsNo: 0, likesNo: 0, recommended: 0, hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: "")
        viewModel.experiences = [exp]
        await viewModel.likeExperience(exp)
        XCTAssertNotNil(viewModel.errorMessage)
        // Should not be liked if error
        XCTAssertFalse(viewModel.experiences[0].isLiked)
    }

    func testFetchExperienceDetailsSuccess() async {
        mockAPI.shouldThrow = false
        let exp = Experience(id: "1", title: "Sphinx", coverPhoto: "", description: "", viewsNo: 0, likesNo: 0, recommended: 0, hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: "")
        mockAPI.experiences = [exp]
        let result = await viewModel.fetchExperienceDetails(id: "1")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.title, "Sphinx")
        XCTAssertNil(viewModel.errorMessage)
    }

    func testFetchExperienceDetailsError() async {
        mockAPI.shouldThrow = true
        mockAPI.experiences = [] // Clear the mock cache
        let result = await viewModel.fetchExperienceDetails(id: "1")
        XCTAssertNil(result)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}
