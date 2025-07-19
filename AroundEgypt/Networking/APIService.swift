//
//  APIService.swift
//  AroundEgypt
//
//  Created by Mohamed Shendy on 18/07/2025.
//

import Alamofire

class APIService {
    static let shared = APIService()
    private let baseURL = "https://aroundegypt.34ml.com"

    private init() {}

//    func fetchExperiences(from path: String) async throws -> [Experience] {
//        let url = "\(baseURL)/api/v2/experiences"
//
//        return try await withCheckedThrowingContinuation { continuation in
//            AF.request(url)
//                .validate()
//                .responseDecodable(of: [Experience].self) { response in
//                    switch response.result {
//                    case .success(let experiences):
//                        continuation.resume(returning: experiences)
//                    case .failure(let error):
//                        continuation.resume(throwing: error)
//                    }
//                }
//        }
//    }
//
//    func fetchRecommendedxperience(id: Int) async throws -> [Experience] {
//        let url = "\(baseURL)/api/v2/experiences?filter[recommended]=true)"
//
//        return try await withCheckedThrowingContinuation { continuation in
//            AF.request(url)
//                .validate()
//                .responseDecodable(of: [Experience].self) { response in
//                    switch response.result {
//                    case .success(let experiences):
//                        continuation.resume(returning: experiences)
//                    case .failure(let error):
//                        continuation.resume(throwing: error)
//                    }
//                }
//        }
//    }
//
//    func likeExperience(id: Int) async throws -> Experience {
//        let url = "\(baseURL)/api/v2/experiences/\(id)/like"
//
//        return try await withCheckedThrowingContinuation { continuation in
//            AF.request(url, method: .post)
//                .validate()
//                .responseDecodable(of: Experience.self) { response in
//                    switch response.result {
//                    case .success(let updatedExp):
//                        continuation.resume(returning: updatedExp)
//                    case .failure(let error):
//                        continuation.resume(throwing: error)
//                    }
//                }
//        }
//    }
    
    func fetchRecommendedExperiences() async throws -> [Experience] {
        let url = baseURL + "/api/v2/experiences?filter[recommended]=true"
        return try await fetchExperiences(from: url)
    }
    
    func fetchRecentExperiences() async throws -> [Experience] {
        let url = baseURL + "/api/v2/experiences"
        return try await fetchExperiences(from: url)
    }
    
    func searchExperiences(query: String) async throws -> [Experience] {
        let url = baseURL + "/api/v2/experiences?filter[title]=\(query)"
        return try await fetchExperiences(from: url)
    }
    
//    func fetchSingleExperience(id: Int) async throws -> Experience {
//        let url = baseURL + "/api/v2/experiences/\(id)"
//        let response = try await AF.request(url)
//            .serializingDecodable(APIResponse<Experience>.self).value
//        return response.data
//    }
    
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
