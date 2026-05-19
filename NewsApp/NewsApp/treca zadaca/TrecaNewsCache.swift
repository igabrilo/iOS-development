import Foundation

final class TrecaNewsCache {
    static let shared = TrecaNewsCache()
    private init() {}

    private var cacheURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("treca_news_cache.json")
    }

    func save(_ articles: [TrecaNews]) {
        if let data = try? JSONEncoder().encode(articles) {
            try? data.write(to: cacheURL, options: .atomic)
        }
    }

    func load() -> [TrecaNews]? {
        guard let data = try? Data(contentsOf: cacheURL),
              let articles = try? JSONDecoder().decode([TrecaNews].self, from: data),
              !articles.isEmpty else {
            return nil
        }
        return articles
    }
}
