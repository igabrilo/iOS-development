import Foundation


enum LoadingState<T> {
    case loading
    case success(T)
    case failure(String)
}


struct NewsResponseDTO: Decodable {
    let status: String
    let results: [NewsArticleDTO]
}

struct NewsArticleDTO: Decodable {
    let articleId: String
    let title: String
    let description: String?
    let imageUrl: String?
    let category: [String]?
    let pubDate: String?
    let creator: [String]?

    enum CodingKeys: String, CodingKey {
        case articleId = "article_id"
        case title
        case description
        case imageUrl = "image_url"
        case category
        case pubDate
        case creator
    }
}


final class NewsService {
    static let shared = NewsService()
    private init() {}

    private let apiKey = "pub_cc4298364323428a9e8fff4667b13b60"
    private let baseURL = "https://newsdata.io/api/1/latest"

    func fetchWordleWord(token: String) async throws -> String {
        let url = URL(string: "https://ios-vjestina.flabbergast.com/word")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        struct WordResponse: Decodable { let word: String }
        return try JSONDecoder().decode(WordResponse.self, from: data).word.uppercased()
    }

    func fetchLatestNews(language: String = "hr") async throws -> [DrugaNews] {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "language", value: language)
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let dto = try JSONDecoder().decode(NewsResponseDTO.self, from: data)
        return dto.results.compactMap { mapToArticle($0) }
    }


    private func mapToArticle(_ dto: NewsArticleDTO) -> DrugaNews? {
        guard !dto.title.isEmpty else { return nil }

        let primaryCategory = dto.category?.first(where: { $0 != "top" })
        let mainCategory = mapMainCategory(primaryCategory)
        let sub = primaryCategory?.capitalized

        return DrugaNews(
            url: dto.imageUrl ?? "",
            caption: DrugaCategory(main: mainCategory, sub: sub),
            date: parseDate(dto.pubDate) ?? Date(),
            headline: dto.title,
            footnote: dto.description ?? "",
            author: dto.creator?.first,
            ratings: []
        )
    }

    private func mapMainCategory(_ category: String?) -> DrugaMainCategory {
        switch category?.lowercased() {
        case "sports":
            return .Sport
        case "entertainment", "lifestyle", "food", "travel", "health":
            return .Lifestyle
        default:
            return .Svijet
        }
    }

    private func parseDate(_ dateString: String?) -> Date? {
        guard let dateString else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: dateString)
    }
}
