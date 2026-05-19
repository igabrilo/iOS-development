import Foundation

final class TrecaReadArticlesStore {
    static let shared = TrecaReadArticlesStore()
    private init() {}

    private let key = "trecaReadArticleIDs"

    func markAsRead(_ id: UUID) {
        var ids = loadReadIDs()
        ids.insert(id)
        if let data = try? JSONEncoder().encode(ids) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func loadReadIDs() -> Set<UUID> {
        guard let data = UserDefaults.standard.data(forKey: key),
              let ids = try? JSONDecoder().decode(Set<UUID>.self, from: data) else {
            return []
        }
        return ids
    }
}
