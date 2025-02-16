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
    private let originalTeam: Team
    
    // MARK: - Computed Properties
    var hasChanges: Bool {
        return team.name != originalTeam.name || team.description != originalTeam.description
    }
    
    var isFormValid: Bool {
        return !team.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !team.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var navigationTitle: String {
        isCreating ? "Create Team" : "Edit Team"
    }
    
    // MARK: - Initialization
    init(team: Team, teamViewModel: TeamViewModel) {
        self.team = team
        self.originalTeam = team  // Capture original state for change detection
        self.teamViewModel = teamViewModel
        let trimmedName = team.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = team.description.trimmingCharacters(in: .whitespacesAndNewlines)
        self.isCreating = trimmedName.isEmpty && trimmedDescription.isEmpty
    }
    
    // MARK: - Public Methods
    func handleSave() async -> Bool {
        hasAttemptedSave = true
        guard isFormValid, hasChanges else {
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
        return !hasAttemptedSave || !team[keyPath: keyPath].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Private Methods
    private func showToast(message: String) async {
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
