//
//  DetailScreen.swift
//  AroundEgypt
//
//  Created by Mohamed Shendy on 18/07/2025.
//
import SwiftUI
import Kingfisher

/// A sheet view displaying the details of a selected experience, including image, title, description, and like/share actions.
struct DetailView: View {
    /// The ID of the experience to display.
    let experienceID: String
    /// The shared view model for data and actions.
    @EnvironmentObject var viewModel: ExperiencesViewModel
    /// The presentation mode environment value.
    @Environment(\.presentationMode) var presentationMode
    /// State for showing the virtual tour.
    @State private var showTour: Bool = false
    /// The loaded experience details.
    @State private var loadedExperience: Experience? = nil
    /// State for showing the share sheet.
    @State private var showShareSheet = false

    var body: some View {
        Group {
            if let experience = loadedExperience {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Image and overlays
                        ZStack(alignment: .bottom) {
                            KFImage(URL(string: experience.coverPhoto))
                                .placeholder {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .resizable()
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width, height: 260)
                                .clipped()
                                .background(Color.white)
                                .ignoresSafeArea(edges: .top)

                            // EXPLORE NOW button centered
                            if !experience.tourHTML.isEmpty {
                                Button(action: { showTour = true }) {
                                    Text("EXPLORE NOW")
                                        .font(.headline)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 32)
                                        .background(Color.white)
                                        .foregroundColor(.orange)
                                        .cornerRadius(12)
                                        .shadow(radius: 4)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            }

                            // Stats row at the bottom
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
                        }
                        .frame(height: 260)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(experience.title.isEmpty ? "Unknown Title" : experience.title)
                                        .font(.title3)
                                        .bold()
                                        .accessibilityIdentifier("detailTitle")
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
                                        showShareSheet = true
                                    }) {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.title3)
                                            .foregroundColor(.orange)
                                    }
                                    Button(action: {
                                        Task {
                                            await viewModel.likeExperience(experience)
                                            // Update local state so UI updates immediately
                                            loadedExperience?.isLiked = true
                                            loadedExperience?.likesNo += 1
                                        }
                                    }) {
                                        HStack(spacing: 4) {
                                            Text("\(experience.likesNo)")
                                                .foregroundColor(.primary)
                                                .accessibilityIdentifier("likeCountLabel")
                                            Image(systemName: experience.isLiked ? "heart.fill" : "heart")
                                                .font(.system(size: 14))
                                                .foregroundColor(.orange)
                                        }
                                    }
                                    .disabled(experience.isLiked)
                                    .accessibilityIdentifier("likeButton")
                                }
                            }
                            Divider()
                            Text("Description")
                                .font(.headline)
                            Text(experience.detailedDescription.isEmpty ? "No description available." : experience.detailedDescription)
                                .font(.body)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityIdentifier("detailDescription")
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
                .sheet(isPresented: $showShareSheet) {
                    if let exp = loadedExperience, let url = URL(string: exp.tourHTML) {
                        ActivityView(activityItems: [exp.title, url])
                    } else if let exp = loadedExperience {
                        ActivityView(activityItems: [exp.title])
                    }
                }
            } else if viewModel.isLoading {
                ProgressView()
                    .transition(.opacity)
                    .accessibilityIdentifier("detailLoadingIndicator")
            } else {
                ProgressView()
                    .onAppear {
                        Task {
                            var exp = await viewModel.fetchExperienceDetails(id: experienceID)
                            if let id = exp?.id, viewModel.likedExperienceIDs.contains(id) {
                                exp?.isLiked = true
                                // Sync likes count with main array if it's higher
                                if let mainExp = (viewModel.experiences + viewModel.recommended).first(where: { $0.id == id }) {
                                    if mainExp.likesNo > (exp?.likesNo ?? 0) {
                                        exp?.likesNo = mainExp.likesNo
                                    }
                                }
                            }
                            loadedExperience = exp
                        }
                    }
            }
        }
    }
}

/// A wrapper for displaying a URL in a Safari view controller.
import SafariServices
struct SafariView: UIViewControllerRepresentable {
    /// The URL to display.
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

/// A wrapper for displaying a share sheet with activity items.
import UIKit
struct ActivityView: UIViewControllerRepresentable {
    /// The items to share.
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

