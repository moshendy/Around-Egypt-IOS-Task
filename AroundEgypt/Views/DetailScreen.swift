//
//  DetailScreen.swift
//  AroundEgypt
//
//  Created by Mohamed Shendy on 18/07/2025.
//
import SwiftUI
import Kingfisher

struct DetailView: View {
    let experienceID: String
    @EnvironmentObject var viewModel: ExperiencesViewModel
    @Environment(\.presentationMode) var presentationMode

    var experience: Experience? {
        viewModel.experiences.first(where: { $0.id == experienceID }) ??
        viewModel.recommended.first(where: { $0.id == experienceID })
    }

    var body: some View {
        if let experience = experience {
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    KFImage(URL(string: experience.coverPhoto))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        .overlay(
                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title)
                                            .foregroundColor(.white)
                                            .padding()
                                    }
                                }
                                Spacer()
                            }
                        )
                        .overlay(
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.8))
                                            .frame(width: 48, height: 48)
                                        Text("360°")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                    }
                                    .padding()
                                }
                            }
                        )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(experience.title)
                        .font(.title)
                        .bold()
                    if let city = experience.city?.name {
                        Text(city)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    HStack(spacing: 24) {
                        Label("\(experience.viewsNo)", systemImage: "eye")
                        Button(action: {
                            Task { await viewModel.likeExperience(experience) }
                        }) {
                            HStack(spacing: 4) {
                                Text("\(experience.likesNo)")
                                Image(systemName: "heart.fill")
                                    .foregroundColor(experience.isLiked ? .red : .gray)
                            }
                        }
                        .disabled(experience.isLiked)
                    }
                    .font(.subheadline)

                    Divider()

                    Text(experience.description)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding()
                Spacer()
            }
            .background(Color(.systemBackground))
            .ignoresSafeArea(edges: .top)
        } else {
            Text("Experience not found")
                .padding()
        }
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
