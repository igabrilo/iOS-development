import SwiftUI

struct TrecaNewsDetailView: View {
    let article: TrecaNews

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: article.url)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 220)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: 250)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, minHeight: 220)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(article.caption.main.rawValue +
                                  (article.caption.sub != nil ? ", \(article.caption.sub!)" : ""))
                            .font(.caption)
                            .padding(6)
                            .foregroundColor(.white)
                            .background(article.caption.main.color)
                            .cornerRadius(6)

                        Spacer()

                        Text(article.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Text(article.headline)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(article.caption.main.color)

                    if let author = article.author {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.caption)
                            Text(author)
                                .font(.subheadline)
                        }
                        .foregroundColor(.gray)
                    }

                    Divider()

                    Text(article.footnote)
                        .font(.body)
                        .lineSpacing(6)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", article.averageRating))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("(\(article.ratings.count))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Članak")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TrecaNewsDetailView(article: TrecaNews(
            url: "https://www.jabuka.tv/wp-content/uploads/2018/06/luka_modric_231412411-810x446.jpg",
            caption: TrecaCategory(main: .Sport, sub: "Football"),
            date: Calendar.current.date(from: DateComponents(year: 2018, month: 7, day: 15))!,
            headline: "Hrvatska osvojila svjetsko prvenstvo 2026.",
            footnote: "Nakon finalne pobjede nad Brazilom 3:2, Luka Modrić je u produžecima zabio gol koji je osigurao pobjedu.",
            author: "Marko Bošnjak",
            ratings: [5, 4, 4, 5]
        ))
    }
}
