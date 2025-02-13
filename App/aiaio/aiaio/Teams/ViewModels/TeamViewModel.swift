import Foundation
@preconcurrency import FirebaseFirestore
import SwiftUI

@MainActor
class TeamViewModel: ObservableObject {
    /// Published array of teams for UI updates.
    @Published private(set) var teams: [Team] = []
    
    /// A computed property returning teams in alphabetical order by name.
    var alphabeticalTeams: [Team] {
        teams.sorted { $0.name < $1.name }
    }
    
    /// Loading state for UI feedback.
    @Published private(set) var isLoading = false
    
    /// Error state for UI feedback.
    @Published var error: GlobalError?
    
    /// Firestore reference.
    private let db = Firestore.firestore()
    
    /// Reference to the teams collection.
    private var teamsRef: CollectionReference {
        db.collection("teams")
    }
    
    /// Any active listeners that need to be cleaned up.
    private var listeners: [ListenerRegistration] = []
    
    /// The session manager providing the current user's UID.
    private let sessionManager: SessionManager
    
    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }
    
    deinit {
        listeners.forEach { $0.remove() }
    }
    
    /// Creates a new team.
    /// - Parameters:
    ///   - name: Team name.
    ///   - description: Team description.
    /// - Returns: The created Team or nil if creation failed.
    func createTeam(name: String, description: String) async -> Team? {
        guard let ownerUID = sessionManager.currentUser?.uid else {
            self.error = .authenticationFailed
            UnifiedLogger.error("No authenticated user found.", context: "Teams")
            return nil
        }
        isLoading = true
        defer { isLoading = false }
        
        let team = Team(
            id: UUID().uuidString,
            name: name,
            description: description,
            ownerUID: ownerUID,
            memberUIDs: [ownerUID],
            createdAt: Date(),
            updatedAt: Date()
        )
        
        do {
            let docRef = try await teamsRef.addDocument(data: team.asDictionary)
            var newTeam = team
            newTeam.id = docRef.documentID
            teams.append(newTeam)
            UnifiedLogger.info("Created new team: \(newTeam.id)", context: "Teams")
            return newTeam
        } catch let err as NSError {
            UnifiedLogger.error(err, context: "Teams")
            if err.domain == FirestoreErrorDomain {
                switch err.code {
                case FirestoreErrorCode.unavailable.rawValue:
                    self.error = .networkFailure
                case FirestoreErrorCode.permissionDenied.rawValue:
                    self.error = .authenticationFailed
                default:
                    self.error = .serverError
                }
            } else {
                self.error = .unknown(err.localizedDescription)
            }
            return nil
        }
    }

    /// Fetches all teams for the current user.
    /// - Returns: An array of Team objects.
    func fetchTeams() async {
        isLoading = true
        defer { isLoading = false }
        do {
            if let uid = sessionManager.currentUser?.uid {
                let query = teamsRef.whereField("memberUIDs", arrayContains: uid)
                let snapshot = try await query.getDocuments()
                let fetchedTeams = snapshot.documents.compactMap { try? Team.from($0) }
                self.teams = fetchedTeams
            }
        } catch {
            UnifiedLogger.error("Failed to fetch teams: \(error.localizedDescription)", context: "Teams")
            self.error = GlobalError.unknown(error.localizedDescription)
        }
    }
    
    /// Updates an existing team.
    /// - Parameters:
    ///   - team: The team to update.
    ///   - userUID: The current user's UID (must be owner).
    /// - Returns: A Boolean indicating success.
    func updateTeam(_ team: Team, userUID: String) async -> Bool {
        guard team.ownerUID == userUID else {
            self.error = .authenticationFailed
            UnifiedLogger.error("User \(userUID) not authorized to update team \(team.id)", context: "Teams")
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        var updatedTeam = team
        updatedTeam.updatedAt = Date()
        
        do {
            try await teamsRef.document(team.id).setData(updatedTeam.asDictionary, merge: true)
            
            if let index = teams.firstIndex(where: { $0.id == team.id }) {
                teams[index] = updatedTeam
            }
            UnifiedLogger.info("Updated team: \(team.id)", context: "Teams")
            return true
        } catch let err as NSError {
            UnifiedLogger.error(err, context: "Teams")
            if err.domain == FirestoreErrorDomain {
                switch err.code {
                case FirestoreErrorCode.unavailable.rawValue:
                    self.error = .networkFailure
                case FirestoreErrorCode.permissionDenied.rawValue:
                    self.error = .authenticationFailed
                case FirestoreErrorCode.notFound.rawValue:
                    self.error = .invalidData
                default:
                    self.error = .serverError
                }
            } else {
                self.error = .unknown(err.localizedDescription)
            }
            return false
        }
    }
    
    /// Adds a member to a team.
    /// - Parameters:
    ///   - userUID: The UID of the user to add.
    ///   - teamID: The team ID.
    ///   - ownerUID: The current user's UID (must be owner).
    /// - Returns: A Boolean indicating success.
    func addMember(_ userUID: String, to teamID: String, ownerUID: String) async -> Bool {
        guard let team = teams.first(where: { $0.id == teamID }),
              team.ownerUID == ownerUID else {
            self.error = .authenticationFailed
            UnifiedLogger.error("User \(ownerUID) not authorized to modify team \(teamID)", context: "Teams")
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await teamsRef.document(teamID).updateData([
                "memberUIDs": team.memberUIDs + [userUID],
                "updatedAt": Timestamp(date: Date())
            ])
            
            if let index = teams.firstIndex(where: { $0.id == teamID }) {
                var updatedTeam = teams[index]
                updatedTeam.memberUIDs.append(userUID)
                updatedTeam.updatedAt = Date()
                teams[index] = updatedTeam
            }
            UnifiedLogger.info("Added member \(userUID) to team \(teamID)", context: "Teams")
            return true
        } catch let err as NSError {
            UnifiedLogger.error(err, context: "Teams")
            if err.domain == FirestoreErrorDomain {
                switch err.code {
                case FirestoreErrorCode.unavailable.rawValue:
                    self.error = .networkFailure
                case FirestoreErrorCode.permissionDenied.rawValue:
                    self.error = .authenticationFailed
                default:
                    self.error = .serverError
                }
            } else {
                self.error = .unknown(err.localizedDescription)
            }
            return false
        }
    }
}
