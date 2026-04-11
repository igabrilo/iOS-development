import SwiftUI

enum AppTab: Hashable {
    case news
    case games
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .news

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Novosti", systemImage: "newspaper", value: .news) {
                NewsListView()
            }

            Tab("Igrice", systemImage: "gamecontroller", value: .games) {
                GamesView()
            }
        }
    }
}

#Preview {
    ContentView()
}
