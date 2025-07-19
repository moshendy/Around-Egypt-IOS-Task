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
                let city: City? = ($0.cityName != nil) ? City(
                    id: Int($0.cityID),
                    name: $0.cityName ?? "",
                    topPick: Int($0.cityTopPick)
                ) : nil
                return Experience(id: $0.id ?? "", title: $0.title ?? "", coverPhoto: $0.coverPhoto ?? "", description: "", viewsNo: Int($0.viewsNo), likesNo: Int($0.likesNo), recommended: Int($0.recommended), hasVideo: 0, city: city, tourHTML: $0.tourHTML ?? "", detailedDescription: $0.detailedDescription ?? "", address: "")
            }
        } catch {
            print("Failed to fetch cached articles: \(error)")
            return []
        }
    }

    func saveExperiences(_ articles: [Experience]) {
        // Clear only non-recommended (recent) cache first
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ExperienceEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recommended == 0")
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
            entity.tourHTML = experience.tourHTML
            entity.detailedDescription = experience.detailedDescription
            entity.cityID = Int16(experience.city?.id ?? 0)
            entity.cityName = experience.city?.name
            entity.cityTopPick = Int16(experience.city?.topPick ?? 0)
        }
        CoreDataStack.shared.saveContext()
    }

    func fetchCachedRecommendedExperiences() -> [Experience] {
        let request: NSFetchRequest<ExperienceEntity> = ExperienceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "recommended != 0")
        request.sortDescriptors = [NSSortDescriptor(key: "apiOrder", ascending: true)]
        do {
            let entities = try context.fetch(request)
            return entities.map {
                let city: City? = ($0.cityName != nil) ? City(
                    id: Int($0.cityID),
                    name: $0.cityName ?? "",
                    topPick: Int($0.cityTopPick)
                ) : nil
                return Experience(id: $0.id ?? "", title: $0.title ?? "", coverPhoto: $0.coverPhoto ?? "", description: "", viewsNo: Int($0.viewsNo), likesNo: Int($0.likesNo), recommended: Int($0.recommended), hasVideo: 0, city: city, tourHTML: $0.tourHTML ?? "", detailedDescription: "", address: "")
            }
        } catch {
            print("Failed to fetch cached recommended experiences: \(error)")
            return []
        }
    }

    func saveRecommendedExperiences(_ experiences: [Experience]) {
        // Delete all previously cached recommended experiences
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ExperienceEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recommended != 0")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? context.execute(deleteRequest)

        // Insert new recommended experiences
        for (index, experience) in experiences.enumerated() {
            let entity = ExperienceEntity(context: context)
            entity.id = experience.id
            entity.title = experience.title
            entity.apiOrder = Int64(index)
            entity.coverPhoto = experience.coverPhoto
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
