import SwiftUI

enum DrugaAppTab: Hashable {
    case news
    case games
}

struct DrugaContentView: View {
    @State private var selectedTab: DrugaAppTab = .news

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Novosti", systemImage: "newspaper", value: DrugaAppTab.news) {
                DrugaNewsListView()
            }

            Tab("Igrice", systemImage: "gamecontroller", value: DrugaAppTab.games) {
                DrugaGamesView()
            }
        }
    }
}

#Preview {
    DrugaContentView()
}
