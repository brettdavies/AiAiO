//
//  ContentView.swift
//  aiaio
//
//  Created by Brett on 2/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "video.fill")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Welcome to AiAiO")
                    .font(.title)
                Text("Your AI-powered video platform")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("AiAiO")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
