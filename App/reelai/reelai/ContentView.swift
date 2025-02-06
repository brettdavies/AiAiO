//
//  ContentView.swift
//  reelai
//
//  Created by Brett on 2/4/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                VStack {
                    EmailVerificationBannerView(viewModel: authViewModel)

                    // Main content here
                    Text("Welcome \(authViewModel.currentUser?.email ?? "")")
                        .padding()

                    Button("Sign Out") {
                        Task {
                            await authViewModel.signOut()
                    }
                }
            }
            } else {
                SignInView()
                    .environmentObject(authViewModel)
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
