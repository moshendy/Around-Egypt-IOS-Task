//
//  HomeView.swift
//  AroundEgypt
//
//  Created by Mohamed Shendy on 18/07/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = ExperiencesViewModel()
    @ObservedObject private var networkMonitor = NetworkMonitor.shared
    @State private var searchText = ""
    @State private var selectedExperience: Experience? = nil
    @State private var showReconnectedBanner = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Network status banners
            if !networkMonitor.isConnected {
                Text("No Internet Connection")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .font(.caption)
                    .transition(.move(edge: .top))
            }
            
            if showReconnectedBanner {
                Text("Network reconnected")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .font(.caption)
                    .transition(.move(edge: .top))
            }
            
            // Top bar with consistent padding
            TopBarView(viewModel: viewModel)
                .padding(.bottom, 8)
            
            // Main content
            NavigationView {
                ZStack {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 24) {
                            if viewModel.searchText.isEmpty {
                                WelcomeSection()
                                    .padding(.horizontal, 16)
                                
                                RecommendedSection(viewModel: viewModel, selectedExperience: $selectedExperience)
                                
                                MostRecentHeader()
                                    .padding(.horizontal, 16)
                            }
                            
                            RecentSection(viewModel: viewModel, selectedExperience: $selectedExperience)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                    }
                    .navigationTitle("")
                    .navigationBarHidden(true)
                    .onAppear {
                        Task {
                            await viewModel.loadPlaces()
                            await viewModel.loadRecommended()
                        }
                    }
                    
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }
            }
            .sheet(item: $selectedExperience) { exp in
                DetailView(experienceID: exp.id)
                    .environmentObject(viewModel)
            }
        }
        .onChange(of: networkMonitor.isConnected) {
            if networkMonitor.isConnected {
                showReconnectedBanner = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showReconnectedBanner = false
                }
            }
        }
    }
}

struct TopBarView: View {
    @ObservedObject var viewModel: ExperiencesViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: { print("Menu tapped") }) {
                Image(systemName: "line.3.horizontal")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
            
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Try Luxor", text: $viewModel.searchText)
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await viewModel.searchExperiences(query: viewModel.searchText) }
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                        Task { await viewModel.loadPlaces() }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            Button(action: { print("Scanner tapped") }) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct WelcomeSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome!")
                .font(.title2)
                .bold()
            
            Text("Now you can explore any experience in 360 degrees and get all the details about it all in one place.")
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
    }
}

struct RecommendedSection: View {
    @ObservedObject var viewModel: ExperiencesViewModel
    @Binding var selectedExperience: Experience?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended Experiences")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(viewModel.recommended, id: \.id) { exp in
                        ExperienceCard(experience: exp)
                            .frame(width: UIScreen.main.bounds.width * 0.85)
                            .environmentObject(viewModel)
                            .onTapGesture { selectedExperience = exp }
                    }
                }
                .padding(.leading, 16)
            }
        }
    }
}

struct MostRecentHeader: View {
    var body: some View {
        Text("Most Recent")
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(.primary)
    }
}

struct RecentSection: View {
    @ObservedObject var viewModel: ExperiencesViewModel
    @Binding var selectedExperience: Experience?
    var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(viewModel.filteredExperiences, id: \.id) { exp in
                ExperienceRow(experience: exp)
                    .onTapGesture {
                        selectedExperience = exp
                    }
                    .environmentObject(viewModel)
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    HomeView()
}
