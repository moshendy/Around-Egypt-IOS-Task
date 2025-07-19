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
    @State private var showTour: Bool = false

    var experience: Experience? {
        viewModel.experiences.first(where: { $0.id == experienceID }) ??
        viewModel.recommended.first(where: { $0.id == experienceID })
    }

    var body: some View {
        if let experience = experience {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ZStack(alignment: .topTrailing) {
                        ZStack(alignment: .center) {
                            KFImage(URL(string: experience.coverPhoto))
                                .placeholder {
                                    Color(.systemGray5)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 260)
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .frame(height: 260)
                                .clipped()
                            // EXPLORE NOW button
                            if !experience.tourHTML.isEmpty {
                                Button(action: { showTour = true }) {
                                    Text("EXPLORE NOW")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 32)
                                        .background(Color.white)
                                        .foregroundColor(.orange)
                                        .cornerRadius(12)
                                        .shadow(radius: 4)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        // Close button
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(8)
                        }
                    }
                    .background(Color.white)

                    // Stats row overlay at bottom of image
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "eye")
                                .foregroundColor(.white)
                            Text("\(experience.viewsNo) views")
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Image(systemName: "photo.on.rectangle.angled")
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .offset(y: -24)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(experience.title.isEmpty ? "Unknown Title" : experience.title)
                                    .font(.title3)
                                    .bold()
                                if let city = experience.city?.name, !city.isEmpty {
                                    Text("\(city), Egypt.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                } else {
                                    Text("Unknown City")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            HStack(spacing: 16) {
                                Button(action: {
                                    // Share action (implement if needed)
                                }) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.title3)
                                        .foregroundColor(.orange)
                                }
                                Button(action: {
                                    Task { await viewModel.likeExperience(experience) }
                                }) {
                                    HStack(spacing: 4) {
                                        Text("\(experience.likesNo)")
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(experience.isLiked ? .red : .orange)
                                    }
                                }
                                .disabled(experience.isLiked)
                            }
                        }
                        Divider()
                        Text("Description")
                            .font(.headline)
                        Text(experience.description.isEmpty ? "No description available." : experience.description)
                            .font(.body)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    Spacer()
                }
            }
            .background(Color(.systemBackground))
            .ignoresSafeArea(edges: .top)
            .sheet(isPresented: $showTour) {
                if let url = URL(string: experience.tourHTML) {
                    SafariView(url: url)
                } else {
                    Text("Invalid tour link")
                        .padding()
                }
            }
        } else {
            Text("Experience not found")
                .padding()
        }
    }
}

// SafariView for opening virtual tour links
import SafariServices
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
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
