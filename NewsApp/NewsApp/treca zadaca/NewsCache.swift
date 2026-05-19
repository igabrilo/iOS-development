import Foundation

final class NewsCache {
    static let shared = NewsCache()
    private init() {}

    private var cacheURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("news_cache.json")
    }

    func save(_ articles: [DrugaNews]) {
        if let data = try? JSONEncoder().encode(articles) {
            try? data.write(to: cacheURL, options: .atomic) // sprjecava djelomicni upis
        }
    }

    func load() -> [DrugaNews]? {
        guard let data = try? Data(contentsOf: cacheURL),
              let articles = try? JSONDecoder().decode([DrugaNews].self, from: data),
              !articles.isEmpty else {
            return nil
        }
        return articles
    }
}
