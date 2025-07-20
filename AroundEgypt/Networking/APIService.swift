//
//  APIService.swift
//  AroundEgypt
//
//  Created by Mohamed Shendy on 18/07/2025.
//

import Alamofire

protocol APIServiceProtocol {
    func fetchRecommendedExperiences() async throws -> [Experience]
    func fetchRecentExperiences() async throws -> [Experience]
    func searchExperiences(query: String) async throws -> [Experience]
    func fetchSingleExperience(id: String) async throws -> Experience
    func likeExperience(id: String) async throws -> Int
}

class APIService: APIServiceProtocol {
    static let shared = APIService()
    private let baseURL = "https://aroundegypt.34ml.com"

    private init() {}
    
    func fetchRecommendedExperiences() async throws -> [Experience] {
        let url = baseURL + "/api/v2/experiences?filter[recommended]=true"
        return try await fetchExperiences(from: url)
    }
    
    func fetchRecentExperiences() async throws -> [Experience] {
        let url = baseURL + "/api/v2/experiences"
        return try await fetchExperiences(from: url)
    }
    
    func searchExperiences(query: String) async throws -> [Experience] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return []
        }
        let url = baseURL + "/api/v2/experiences?filter[title]=\(encodedQuery)"
        return try await fetchExperiences(from: url)
    }
    
    func fetchSingleExperience(id: String) async throws -> Experience {
        let url = baseURL + "/api/v2/experiences/\(id)"
        let response = try await AF.request(url)
            .serializingDecodable(APIResponse<Experience>.self).value
        return response.data
    }
    
    func likeExperience(id: String) async throws -> Int {
        let url = baseURL + "/api/v2/experiences/\(id)/like"
        let response = try await AF.request(url, method: .post)
            .serializingDecodable(APIResponse<Int>.self).value
        return response.data
    }
    private func fetchExperiences(from urlString: String) async throws -> [Experience] {
        let response = try await AF.request(urlString)
            .serializingDecodable(APIResponse<[Experience]>.self).value
        return response.data
    }
}
