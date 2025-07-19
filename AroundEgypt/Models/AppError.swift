import Foundation

enum AppError: Error, CustomStringConvertible {
    case network
    case noCache
    case searchNoResults
    case details
    case like
    case unknown

    var description: String {
        switch self {
        case .network:
            return "Failed to load data. Please check your connection and try again."
        case .noCache:
            return "No cached data available offline."
        case .searchNoResults:
            return "No experiences found for your search."
        case .details:
            return "Failed to load experience details. Please try again."
        case .like:
            return "Failed to like experience. Please try again."
        case .unknown:
            return "An unknown error occurred."
        }
    }
} 