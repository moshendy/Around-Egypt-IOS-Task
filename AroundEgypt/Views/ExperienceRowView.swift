//
//  ExperienceRowView.swift
//  AroundEgypt
//
//  Created by Mohamed Shendy on 18/07/2025.
//


import SwiftUI
import Kingfisher

struct ExperienceRow: View {
    let experience: Experience
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
                        Image(systemName: experience.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(.orange)

                    }
                }
                .disabled(experience.isLiked)
            }
        }
    }
}

