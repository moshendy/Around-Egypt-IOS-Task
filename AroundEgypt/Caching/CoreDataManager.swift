//
//  CoreDataManager.swift
//  AroundEgypt
//
//  Created by Mohamed Shendy on 18/07/2025.
//

import CoreData

class ExperienceCacheManager {
    let context = CoreDataStack.shared.context


    func fetchCachedExperiences(_ predicate:String) -> [Experience] {
        let request: NSFetchRequest<ExperienceEntity> = ExperienceEntity.fetchRequest()
        if predicate != "" {
            request.predicate = NSPredicate(format: predicate)
        }
        request.sortDescriptors = [NSSortDescriptor(key: "apiOrder", ascending: true)]
        do {
            let entities = try context.fetch(request)
            return entities.map { Experience(entity: $0) }
        } catch {
            print("Failed to fetch cached recommended experiences: \(error)")
            return []
        }
    }

    func saveExperiences(_ experiences: [Experience], _ predicate:String) {
        // Delete all previously cached recommended experiences
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ExperienceEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: predicate)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? context.execute(deleteRequest)

        // Insert new recommended experiences
        for (index, experience) in experiences.enumerated() {
            let entity = ExperienceEntity(context: context)
            entity.id = experience.id
            entity.title = experience.title
            entity.apiOrder = Int64(index)
            entity.coverPhoto = experience.coverPhoto
            entity.detailedDescription = experience.detailedDescription
            entity.viewsNo = Int64(experience.viewsNo)
            entity.likesNo = Int64(experience.likesNo)
            entity.recommended = Int16(experience.recommended)
            entity.tourHTML = experience.tourHTML
            entity.cityID = Int16(experience.city?.id ?? 0)
            entity.cityName = experience.city?.name
            entity.cityTopPick = Int16(experience.city?.topPick ?? 0)
        }
        CoreDataStack.shared.saveContext()
    }
}
