//
//  HomeView.swift
//  AroundEgypt
//
//  Created by Mohamed Shendy on 18/07/2025.
//

import SwiftUI
import Kingfisher

struct HomeView: View {
    @StateObject private var viewModel = ExperiencesViewModel()
    @State private var searchText = ""

    var body: some View {
        HStack(spacing: 12) {
            // Left button (Menu)
            Button(action: {
                print("Menu tapped")
            }) {
                Image(systemName: "line.3.horizontal")
                    .font(.title3)
                    .foregroundColor(.primary)
            }

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Try “Luxor”", text: $searchText)
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)

            // Right button (Scanner)
            Button(action: {
                print("Scanner tapped")
            }) {
                Image(systemName: "qrcode.viewfinder") // or "camera.viewfinder"
                    .font(.title3)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal)


        
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Welcome Text
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome!")
                            .font(.title2)
                            .bold()
                        Text("Now you can explore any experience in 360 degrees and get all the details about it all in one place.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)

                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }

                    // Most Recent
                    Text("Most Recent")
                        .font(.headline)
                        .padding(.horizontal)

                    VStack(spacing: 16) {
                        ForEach(viewModel.experiences, id: \.id) { exp in
                            ExperienceCard(experience: exp)
                                .padding(.horizontal)
                        }
                    }

                }
                .padding(.top)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                    Task {
                    await viewModel.loadPlaces()
                }
            }


                
            }
        }
    
}

#Preview {
    HomeView()
}
struct ExperienceCard: View {
    let experience: Experience

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                KFImage(URL(string: experience.coverPhoto))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipped()
                    .cornerRadius(12)

                if (experience.recommended != 0) {
                    Text("RECOMMENDED")
                        .font(.caption)
                        .bold()
                        .padding(6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                        .padding(8)
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
                Text("\(experience.likesNo)")
                Image(systemName: "heart.fill")
                    .foregroundColor(.orange)
            }
        }
    }
}
