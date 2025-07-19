//
//  ExperienceRowView.swift
//  AroundEgypt
//
//  Created by Mohamed Shendy on 18/07/2025.
//


import SwiftUI
import Kingfisher

/// A row view displaying a recent experience with image, title, views, and like button.
/// Used in the vertical recent experiences list on the Home screen.
struct ExperienceRow: View {
    /// The experience to display.
    let experience: Experience
    /// The shared view model for experience actions.
    @EnvironmentObject var viewModel: ExperiencesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                KFImage(URL(string: experience.coverPhoto))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipped()
                    .cornerRadius(12)

              

                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "eye")
                            .foregroundColor(.white)
                        Text("\(experience.viewsNo)")
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "photo.on.rectangle.angled")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 6)
          
                }
            }

            HStack {
                Text(experience.title)
                    .font(.subheadline)
                    .bold()
                Spacer()
                Button(action: {
                    Task { await viewModel.likeExperience(experience) }
                }) {
                    HStack(spacing: 4) {
                        Text("\(experience.likesNo)")
                            .foregroundColor(.primary)
                        Image(systemName: experience.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(experience.isLiked ? .orange : .gray)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .frame(minHeight: 44)
                    
                }
                .disabled(experience.isLiked)
            }
        }
        .accessibilityIdentifier("experienceRow_\(experience.id)")
    }
}

