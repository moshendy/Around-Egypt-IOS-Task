import Foundation

/// Service for managing liked experience IDs using UserDefaults.
class LikesService {
    private let likedKey = "likedExperienceIDs"
    /// Returns the set of liked experience IDs.
    var likedExperienceIDs: Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: likedKey) ?? [])
    }
    /// Adds an experience ID to the liked set.
    func addLikedExperienceID(_ id: String) {
        var liked = likedExperienceIDs
        liked.insert(id)
        UserDefaults.standard.set(Array(liked), forKey: likedKey)
    }
} 