//
//  ExperienceCardView.swift
//  AroundEgypt
//
//  Created by Mohamed Shendy on 18/07/2025.
//
import SwiftUI
import Kingfisher

/// A card view displaying a recommended experience with image, title, and like button.
/// Used in the horizontal recommended experiences list on the Home screen.
struct ExperienceCard: View {
    /// The experience to display.
    let experience: Experience
    /// The shared view model for experience actions.
    @EnvironmentObject var viewModel: ExperiencesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                KFImage(URL(string: experience.coverPhoto))
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(height: 160)
                    .clipped()
                    .cornerRadius(16)
                // RECOMMENDED badge with star
                if experience.recommended != 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        Text("RECOMMENDED")
                            .font(.caption2)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.85))
                    .clipShape(Capsule())
                    .padding(8)
                }
                // Info icon
                HStack {
                    Spacer()
                    Button(action: { /* info action */ }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.black.opacity(0.4)).frame(width: 28, height: 28))
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
                // Bottom stats row
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "eye")
                        Text("\(experience.viewsNo)")
                        Spacer()
                        Image(systemName: "photo.on.rectangle.angled")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(8)
                    .padding(8)
                }
            }
            // Title and likes row
            HStack {
                Text(experience.title)
                    .font(.headline)
                    .bold()
                Spacer()
                Button(action: {
                    Task { await viewModel.likeExperience(experience) }
                }) {
                    HStack(spacing: 4) {
                        Text("\(experience.likesNo)")
                            .foregroundColor(.primary)
                        Image(systemName: experience.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundColor(experience.isLiked ? .orange : .gray)
                    }
                }
                .disabled(experience.isLiked)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.vertical, 4)
        .accessibilityIdentifier("experienceCard_\(experience.id)")
    }
}
