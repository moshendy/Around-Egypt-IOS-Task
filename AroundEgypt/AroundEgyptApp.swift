//
//  AroundEgyptApp.swift
//  AroundEgypt
//
//  Created by Mohamed Shendy on 18/07/2025.
//

import SwiftUI

@main
struct AroundEgyptApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            showSplash = false
                        }
                    }
            } else {
                HomeView()
            }
        }
    }
}
