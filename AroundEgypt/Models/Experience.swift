//
//  Experience.swift
//  AroundEgypt
//
//  Created by Mohamed Shendy on 18/07/2025.
//
        
import Foundation


// MARK: - Experience
struct Experience: Identifiable, Codable {
    let id, title: String
    let coverPhoto: String
    let description: String
    var viewsNo, likesNo, recommended, hasVideo: Int
    let city: City?
    let tourHTML: String
    let detailedDescription, address: String
    var isLiked: Bool = false // Local-only, not Codable

    enum CodingKeys: String, CodingKey {
        case id, title
        case coverPhoto = "cover_photo"
        case description
        case viewsNo = "views_no"
        case likesNo = "likes_no"
        case recommended
        case hasVideo = "has_video"
        case city
        case tourHTML = "tour_html"
        case detailedDescription = "detailed_description"
        case address

    }
}

// MARK: - City
struct City: Codable {
    let id: Int
    let name: String
    let topPick: Int

    enum CodingKeys: String, CodingKey {
        case id, name
        case topPick = "top_pick"
    }
}



