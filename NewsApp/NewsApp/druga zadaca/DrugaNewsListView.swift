import SwiftUI

struct DrugaNewsItem: Identifiable, Hashable {
    let id = UUID()
    let url: String
    let caption: DrugaNewsCategory
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

struct DrugaNewsCategory: Hashable {
    let main: DrugaNewsMainCategory
    let sub: String?
}

enum DrugaNewsMainCategory: String {
    case Sport
    case Lifestyle
    case Svijet

    var color: Color {
        switch self {
        case .Sport:
            return .green
        case .Lifestyle:
            return .purple
        case .Svijet:
            return .blue
        }
    }
}

struct DrugaNewsListView: View {

    @State private var selectedArticle: DrugaNewsItem?
    @State private var readArticleIDs: Set<UUID> = []

    @State var news = [
        DrugaNewsItem(url: "https://www.jabuka.tv/wp-content/uploads/2018/06/luka_modric_231412411-810x446.jpg",
             caption: DrugaNewsCategory(main: .Sport, sub: "Football"),
             date: Calendar.current.date(from: DateComponents(year: 2018, month: 7, day: 15))!,
             headline: "Hrvatska osvojila svjetsko prvenstvo 2026. – Modrić (40) zabio odlučujući gol pa rekao ajde još 4 godine",
             footnote: "Nakon finalne pobjede nad Brazilom 3:2, Luka Modrić je u produžecima...",
             author: "Marko Bošnjak",
             ratings: [5,4,4,5]),
        DrugaNewsItem(url: "https://media.cntraveller.com/photos/68541e33e1e513cae18f6c1d/16:9/w_5312,h_2988,c_limit/Dubrovnik_190625_GettyImages-1032802174.jpg",
             caption: DrugaNewsCategory(main: .Lifestyle, sub: "Putovanje"),
             date: Calendar.current.date(from: DateComponents(year: 2020, month: 7, day: 20))!,
             headline: "Dubrovnik uveo dnevnu kvotu turista - gradonacelnik osobno dao govor",
             footnote: "Od lipnja 2025. u stari grad Dubrovnika smije ući točno 4000 ljudi",
             author: nil,
            ratings: [4,3,5,5]),
        DrugaNewsItem(url: "https://www.tportal.hr/media/thumbnail/w1000/2699126.jpeg",
             caption: DrugaNewsCategory(main: .Svijet, sub: "Politika"),
             date: Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 10))!,
             headline: "Trump objavio - Uvodim nove carine",
             footnote: "Od 1. sljedeceg mjeseca Amerika svim zemljama uvodi carine od 20 posto",
             author: "Pero Peric",
             ratings: [5,5,5,4,4]),
        DrugaNewsItem(url: "https://green.hr/wp-content/uploads/2023/01/jason-briscoe-n4ymhyyFY7A-unsplash-scaled.jpg",
             caption: DrugaNewsCategory(main: .Lifestyle, sub: "Kuhinja"),
             date: Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 21))!,
             headline: "Kuhajte uz nas - nova kuharica",
             footnote: "Novi show kuharica mozete pratiti na rtl-u od 1.svibnja. Uzivajte uz svoje najbolje kuhare",
             author: nil,
            ratings: [4]),
        DrugaNewsItem(url: "https://wereldreizigers.nl/wp-content/uploads/1-year-roadtrip-usa-and-canada-scaled.jpg",
             caption: DrugaNewsCategory(main: .Lifestyle, sub: "Putovanje"),
             date: Calendar.current.date(from: DateComponents(year: 2021, month: 7, day: 15))!,
             headline: "Put oko Amerike u 15 dana!",
             footnote: "Naš reporter otputovo cijelu Ameriku u samo 15 dana. Doznajte kako je to izveo.",
             author: nil,
            ratings: [5,4,4]),
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(news) { paper in
                    DrugaNewsRowView(article: paper, isRead: readArticleIDs.contains(paper.id))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        readArticleIDs.insert(paper.id)
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
            .navigationTitle("Novosti")
            .navigationDestination(item: $selectedArticle) { article in
                DrugaNewsDetailView(article: article)
            }
        }
    }
}

struct DrugaNewsRowView: View {
    let article: DrugaNewsItem
    let isRead: Bool

    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: URL(string: article.url)!) { phase in
                switch phase {
                case .empty:
                    Text("Loading...")
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipped()
                case .failure:
                    Text("Failed to load image.")
                }
            }
            .overlay(alignment: .topLeading) {
                if !isRead {
                    Text("NEW")
                        .font(.caption)
                        .padding(4)
                        .foregroundColor(.white)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(5)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(article.caption.main.rawValue +
                              (article.caption.sub != nil ? ", \(article.caption.sub!)" : ""))
                        .font(.caption)
                        .padding(4)
                        .foregroundColor(.gray)
                        .background(article.caption.main.color.opacity(0.2))
                        .cornerRadius(5)

                    Spacer()

                    Text(article.date, style: .date)
                        .font(.caption2)
                        .padding(2)
                        .foregroundColor(.gray)
                        .background(article.caption.main.color.opacity(0.2))
                        .cornerRadius(5)
                }

                Text(article.headline)
                    .font(.headline)
                    .foregroundColor(article.caption.main.color)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(article.footnote)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .lineLimit(2)

                if let author = article.author {
                    Text(author)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .background(.yellow.opacity(0.2))
                        .cornerRadius(5)
                        .lineLimit(1)
                }
            }
        }
    }
}

#Preview {
    DrugaNewsListView()
}
