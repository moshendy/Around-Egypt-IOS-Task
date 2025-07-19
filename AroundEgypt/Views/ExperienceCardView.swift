//
//  ExperienceCardView.swift
//  AroundEgypt
//
//  Created by Mohamed Shendy on 18/07/2025.
//
import SwiftUI
import Kingfisher

struct ExperienceCard: View {
    let experience: Experience
    @EnvironmentObject var viewModel: ExperiencesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                // Main image
                KFImage(URL(string: experience.coverPhoto))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 260, height: 160)
                    .clipped()
                    .cornerRadius(12)

                // Top overlay elements
                VStack {
                    HStack {
                        // RECOMMENDED badge (only show if recommended)
                        if experience.recommended != 0 {
                            Text("RECOMMENDED")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue)
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                        
                        // Info button
                        Button(action: {
                            // Info action
                        }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    
                    Spacer()
                }
                
                // Center 360° icon
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 50, height: 50)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                    
                    Text("360°")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Bottom stats overlay
                VStack {
                    Spacer()
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "eye")
                                .foregroundColor(.white)
                                .font(.system(size: 12))
                            Text("\(experience.viewsNo)")
                                .foregroundColor(.white)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        
                        Spacer()
                        
                        Image(systemName: "photo.on.rectangle.angled")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .padding(6)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                }
            }
            .frame(width: 260, height: 160)

            // Bottom content
            HStack {
                Text(experience.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Like button with count
                Button(action: {
                    Task { await viewModel.likeExperience(experience) }
                }) {
                    HStack(spacing: 4) {
                        Text("\(experience.likesNo)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Image(systemName: experience.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(.orange)

                    }
                }
                .disabled(experience.isLiked)
            }
        }
        .frame(width: 260)
    }
}
