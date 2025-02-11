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

                // Test logging button
                Button(
                    action: {
                        UnifiedLogger.log("Test log message from ContentView", level: .info)

                        // Example error handling
                        do {
                            throw GlobalError.networkFailure
                        } catch let error as GlobalError {
                            UnifiedLogger.log(
                                "Caught error: \(error.localizedDescription)",
                                level: .error
                            )
                        } catch {
                            UnifiedLogger.log(
                                "Unexpected error: \(error.localizedDescription)",
                                level: .error
                            )
                        }
                    },
                    label: {
                        Text("Test Logging")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                )
                .padding(.top, 20)
            }
            .padding()
            .navigationTitle("AiAiO")
        }
    }
}

#Preview {
    ContentView()
}
