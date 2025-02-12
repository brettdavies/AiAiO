import Foundation
import SwiftUI

@MainActor
final class TeamDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var team: Team
    @Published var hasAttemptedSave = false
    @Published var showValidationError = false
    @Published var showToast = false
    @Published var toastMessage = ""
    
    // MARK: - Dependencies
    private let teamViewModel: TeamViewModel
    private let isCreating: Bool
    
    // MARK: - Computed Properties
    var isFormValid: Bool {
        !team.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !team.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var navigationTitle: String {
        isCreating ? "Create Team" : "Edit Team"
    }
    
    // MARK: - Initialization
    init(team: Team, teamViewModel: TeamViewModel) {
        self.team = team
        self.teamViewModel = teamViewModel
        let trimmedName = team.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = team.description.trimmingCharacters(in: .whitespacesAndNewlines)
        self.isCreating = trimmedName.isEmpty && trimmedDescription.isEmpty
    }
    
    // MARK: - Public Methods
    func handleSave() async -> Bool {
        hasAttemptedSave = true
        guard isFormValid else {
            showValidationError = true
            return false
        }
        
        let success: Bool = isCreating
            ? (await teamViewModel.createTeam(name: team.name, description: team.description) != nil)
            : await teamViewModel.updateTeam(team, userUID: team.ownerUID)
        
        if success {
            await showSuccessToast()
        } else {
            await showFailureToast()
        }
        
        return success
    }
    
    func clearField(_ keyPath: WritableKeyPath<Team, String>) {
        team[keyPath: keyPath] = ""
    }
    
    func validateField(_ keyPath: KeyPath<Team, String>) -> Bool {
        let isValid = !hasAttemptedSave || !team[keyPath: keyPath].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if !isValid {
            UnifiedLogger.debug("Field \(keyPath) failed validation", context: "Teams")
        }
        return isValid
    }
    
    // MARK: - Private Methods
    private func createTeam() async -> Bool {
        UnifiedLogger.info("Attempting to create team", context: "Teams")
        guard await teamViewModel.createTeam(name: team.name, description: team.description) != nil else {
            UnifiedLogger.error("Failed to create team", context: "Teams")
            return false
        }
        UnifiedLogger.info("Successfully created team", context: "Teams")
        return true
    }
    
    private func updateTeam() async -> Bool {
        UnifiedLogger.info("Attempting to update team", context: "Teams")
        let success = await teamViewModel.updateTeam(team, userUID: team.ownerUID)
        if success {
            UnifiedLogger.info("Successfully updated team", context: "Teams")
        } else {
            UnifiedLogger.error("Failed to update team", context: "Teams")
        }
        return success
    }
    
    private func showToast(message: String) async {
        UnifiedLogger.debug("Showing team operation toast: \(message)", context: "Teams")
        toastMessage = message
        withAnimation { showToast = true }
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    private func showSuccessToast() async {
        await showToast(message: isCreating ? "Team Created" : "Team Updated")
    }
    
    private func showFailureToast() async {
        await showToast(message: isCreating ? "Failed to create team" : "Failed to update team")
    }
}
