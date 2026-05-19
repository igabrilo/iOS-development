import SwiftUI

struct TrecaNews: Identifiable, Hashable, Codable {
    let id = UUID()
    let url: String
    let caption: TrecaCategory
    let date: Date
    let headline: String
    let footnote: String
    let author: String?
    let ratings: [Int]

    var averageRating: Double {
        guard !ratings.isEmpty else { return 0 }
        return Double(ratings.reduce(0, +)) / Double(ratings.count)
    }
}

struct TrecaCategory: Hashable, Codable {
    let main: TrecaMainCategory
    let sub: String?
}

enum TrecaMainCategory: String, Codable {
    case Sport
    case Lifestyle
    case Svijet

    var color: Color {
        switch self {
        case .Sport: return .green
        case .Lifestyle: return .purple
        case .Svijet: return .blue
        }
    }
}

struct TrecaNewsListView: View {

    @State private var selectedArticle: TrecaNews?
    @State private var readArticleIDs: Set<UUID> = TrecaReadArticlesStore.shared.loadReadIDs()
    @State private var state: TrecaLoadingState<[TrecaNews]> = .loading

    var body: some View {
        NavigationStack {
            Group {
                switch state {
                case .loading:
                    ProgressView("Učitavanje članaka...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .failure(let message):
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("Greška pri učitavanju")
                            .font(.headline)
                        Text(message)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Pokušaj ponovo") {
                            Task { await loadNews() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .success(let articles):
                    List {
                        ForEach(articles) { paper in
                            TrecaNewsRowView(article: paper, isRead: readArticleIDs.contains(paper.id))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    readArticleIDs.insert(paper.id)
                                    TrecaReadArticlesStore.shared.markAsRead(paper.id)
                                    selectedArticle = paper
                                }
                                .swipeActions {
                                    Button {
                                    } label: {
                                        Label(String(format: "%.1f", paper.averageRating), systemImage: "star.fill")
                                    }
                                    .tint(.yellow)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Novosti")
            .navigationDestination(item: $selectedArticle) { article in
                TrecaNewsDetailView(article: article)
            }
        }
        .task {
            await loadNews()
        }
    }

    private func loadNews() async {
        if let cached = TrecaNewsCache.shared.load() {
            state = .success(cached)
        } else {
            state = .loading
        }

        do {
            let fresh = try await TrecaNewsService.shared.fetchLatestNews()
            TrecaNewsCache.shared.save(fresh)
            state = .success(fresh)
        } catch {
            if case .success = state { return }
            state = .failure(error.localizedDescription)
        }
    }
}

struct TrecaNewsRowView: View {
    let article: TrecaNews
    let isRead: Bool

    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: URL(string: article.url)) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.2)
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    Image(systemName: "photo").foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 120, height: 80)
            .clipped()
            .cornerRadius(6)
            .overlay(alignment: .topLeading) {
                if !isRead {
                    Text("NEW")
                        .font(.caption)
                        .padding(4)
                        .foregroundColor(.white)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(5)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(article.caption.main.rawValue +
                         (article.caption.sub != nil ? ", \(article.caption.sub!)" : ""))
                        .font(.caption).padding(4).foregroundColor(.gray)
                        .background(article.caption.main.color.opacity(0.2)).cornerRadius(5)
                    Spacer()
                    Text(article.date, style: .date)
                        .font(.caption2).padding(2).foregroundColor(.gray)
                        .background(article.caption.main.color.opacity(0.2)).cornerRadius(5)
                }
                Text(article.headline)
                    .font(.headline).foregroundColor(article.caption.main.color)
                    .lineLimit(2).minimumScaleFactor(0.8)
                Text(article.footnote)
                    .font(.footnote).foregroundColor(.gray).lineLimit(2)
                if let author = article.author {
                    Text(author)
                        .font(.footnote).foregroundColor(.gray)
                        .background(.yellow.opacity(0.2)).cornerRadius(5).lineLimit(1)
                }
            }
        }
    }
}

#Preview {
    TrecaNewsListView()
}
