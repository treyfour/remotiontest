import Foundation

struct AppUser: Identifiable, Codable {
    let id: String
    let displayName: String
    let email: String?
    let createdAt: Date
    var territoriesCount: Int
    var totalAreaClaimed: Double // square meters

    init(id: String, displayName: String, email: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.createdAt = createdAt
        self.territoriesCount = 0
        self.totalAreaClaimed = 0
    }

    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "displayName": displayName,
            "createdAt": createdAt,
            "territoriesCount": territoriesCount,
            "totalAreaClaimed": totalAreaClaimed
        ]
        if let email = email {
            data["email"] = email
        }
        return data
    }
}
