//
//  AroundEgyptTests.swift
//  AroundEgyptTests
//
//  Created by Mohamed Shendy on 19/07/2025.
//

import XCTest
@testable import AroundEgypt

@MainActor
final class ExperiencesViewModelTests: XCTestCase {
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
        viewModel.experiences = [
            Experience(id: "1", title: "Pyramids", coverPhoto: "", description: "", viewsNo: 0, likesNo: 0, recommended: 0, hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: ""),
            Experience(id: "2", title: "Luxor Temple", coverPhoto: "", description: "", viewsNo: 0, likesNo: 0, recommended: 0, hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: "")
        ]
        viewModel.searchText = "Luxor"
        NetworkMonitor.shared.setTestConnection(false)
        await viewModel.submitSearch()
        XCTAssertEqual(viewModel.searchResults?.count, 1)
        XCTAssertEqual(viewModel.searchResults?.first?.title, "Luxor Temple")
        XCTAssertNil(viewModel.searchError)
    }

    func testSearchNoResults() async {
        viewModel.experiences = [
            Experience(id: "1", title: "Pyramids", coverPhoto: "", description: "", viewsNo: 0, likesNo: 0, recommended: 0, hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: "")
        ]
        viewModel.searchText = "Luxor"
        await viewModel.submitSearch()
        XCTAssertTrue(viewModel.searchResults?.isEmpty ?? false)
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
        XCTAssertNotNil(viewModel.error)
        XCTAssertEqual(viewModel.error, .network)
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

    func testLikeExperienceErrorHandling() async {
        mockAPI.shouldThrow = true
        let exp = Experience(id: "1", title: "Pyramids", coverPhoto: "", description: "", viewsNo: 0, likesNo: 0, recommended: 0, hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: "")
        viewModel.experiences = [exp]
        await viewModel.likeExperience(exp)
        XCTAssertNotNil(viewModel.error)
        XCTAssertEqual(viewModel.error, .like)
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
        XCTAssertNil(viewModel.error)
    }

    func testFetchExperienceDetailsError() async {
        mockAPI.shouldThrow = true
        mockAPI.experiences = [] // Clear the mock cache
        let result = await viewModel.fetchExperienceDetails(id: "1")
        XCTAssertNil(result)
        XCTAssertNotNil(viewModel.error)
        XCTAssertEqual(viewModel.error, .details)
    }

    func testHybridSearch_LocalFiltering() async {
        viewModel.experiences = [
            Experience(id: "1", title: "Pyramids", coverPhoto: "", description: "", viewsNo: 0, likesNo: 0, recommended: 0, hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: ""),
            Experience(id: "2", title: "Luxor Temple", coverPhoto: "", description: "", viewsNo: 0, likesNo: 0, recommended: 0, hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: "")
        ]
        viewModel.searchText = "Luxor"
        NetworkMonitor.shared.setTestConnection(false)
        await viewModel.submitSearch()
        XCTAssertEqual(viewModel.searchResults?.count, 1)
        XCTAssertEqual(viewModel.searchResults?.first?.title, "Luxor Temple")
        XCTAssertNil(viewModel.searchError)
    }
    
    func testHybridSearch_NoResults_Local() async {
        viewModel.experiences = [
            Experience(id: "1", title: "Pyramids", coverPhoto: "", description: "", viewsNo: 0, likesNo: 0, recommended: 0, hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: "")
        ]
        viewModel.searchText = "Luxor"
        NetworkMonitor.shared.setTestConnection(false)
        await viewModel.submitSearch()
        XCTAssertEqual(viewModel.searchResults?.count, 0)
        XCTAssertEqual(viewModel.searchError, .searchNoResults)
    }
    
    func testHybridSearch_RemoteSuccess() async {
        NetworkMonitor.shared.setTestConnection(true)
        mockAPI.shouldThrow = false
        mockAPI.experiences = [
            Experience(id: "1", title: "Cairo Tower", coverPhoto: "", description: "", viewsNo: 0, likesNo: 0, recommended: 0, hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: "")
        ]
        viewModel.searchText = "Cairo"
        await viewModel.submitSearch()
        XCTAssertEqual(viewModel.searchResults?.count, 1)
        XCTAssertEqual(viewModel.searchResults?.first?.title, "Cairo Tower")
        XCTAssertNil(viewModel.searchError)
    }
    
    func testHybridSearch_RemoteNoResults() async {
        NetworkMonitor.shared.setTestConnection(true)
        mockAPI.shouldThrow = false
        mockAPI.experiences = []
        viewModel.searchText = "Cairo"
        await viewModel.submitSearch()
        XCTAssertEqual(viewModel.searchResults?.count, 0)
        XCTAssertEqual(viewModel.searchError, .searchNoResults)
    }
    
    func testHybridSearch_RemoteError() async {
        NetworkMonitor.shared.setTestConnection(true)
        mockAPI.shouldThrow = true
        viewModel.searchText = "Cairo"
        await viewModel.submitSearch()
        XCTAssertEqual(viewModel.searchResults?.count, 0)
        XCTAssertEqual(viewModel.searchError, .network)
    }
}
