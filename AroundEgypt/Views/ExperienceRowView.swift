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
                    .placeholder {
                            Image(systemName: "photo.on.rectangle.angled")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(height: 180)
                    .clipped()
                    .overlay(Color.black.opacity(0.2))
                    .cornerRadius(16)
                    
                
                // Info icon
                HStack {
                    Spacer()
                    Button(action: { /* info action */ }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.white)
                    }
                    .padding(8)
                }
                // Centered 360 badge
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.85))
                                .frame(width: 44, height: 44)
                            Text("360°")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        Spacer()
                    }
                    Spacer()
                }

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

