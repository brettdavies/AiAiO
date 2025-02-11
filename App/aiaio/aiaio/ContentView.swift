//
//  ContentView.swift
//  aiaio
//
//  Created by Brett on 2/10/25.
//

import SwiftUI
import os.log

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
                        // Example of different log levels
                        UnifiedLogger.info(
                            "User tapped test button",
                            context: "UI"
                        )

                        // Example error handling
                        do {
                            UnifiedLogger.debug(
                                "Simulating a network error",
                                context: "Network"
                            )
                            throw GlobalError.networkFailure
                        } catch let error as GlobalError {
                            UnifiedLogger.error(
                                error,
                                context: "Network"
                            )
                        } catch {
                            UnifiedLogger.error(
                                "Unexpected error occurred",
                                context: "Network"
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
