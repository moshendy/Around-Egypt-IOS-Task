//
//  ApiResponse.swift
//  AroundEgypt
//
//  Created by Mohamed Shendy on 19/07/2025.
//

import Foundation

// MARK: - API Response
struct APIResponse<T: Codable>: Codable {
    let meta: Meta
    let data: T
    let pagination: Pagination
}

// MARK: - Meta
struct Meta: Codable {
    let code: Int
//    let errors: T
}

// MARK: - Pagination
struct Pagination: Codable {
}
