//
//  CoreDataManager.swift
//  AroundEgypt
//
//  Created by Mohamed Shendy on 18/07/2025.
//

import CoreData

class ExperienceCacheManager {
    let context = CoreDataStack.shared.context

    func fetchCachedExperiences() -> [Experience] {
        let request: NSFetchRequest<ExperienceEntity> = ExperienceEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "apiOrder", ascending: true)]
        do {
            let entities = try context.fetch(request)
            return entities.map {
                Experience(id: $0.id ?? "", title: $0.title ?? "", coverPhoto: $0.coverPhoto ?? "", description: "", viewsNo: Int($0.viewsNo), likesNo: Int($0.likesNo), recommended: Int($0.recommended), hasVideo: 0, city: nil, tourHTML: "", detailedDescription: "", address: "")
            }
        } catch {
            print("Failed to fetch cached articles: \(error)")
            return []
        }
    }

    func saveExperiences(_ articles: [Experience]) {
        // Clear old cache first
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ExperienceEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? context.execute(deleteRequest)

        // Insert new articles
        for (index, experience) in articles.enumerated() {
            let entity = ExperienceEntity(context: context)
            entity.id = experience.id
            entity.title = experience.title
            entity.apiOrder = Int64(index)
            entity.coverPhoto = experience.coverPhoto
            entity.viewsNo = Int64(experience.viewsNo)
            entity.likesNo = Int64(experience.likesNo)
            entity.recommended = Int16(experience.recommended)

        }

        CoreDataStack.shared.saveContext()
    }
}
