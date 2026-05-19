import SwiftUI

enum TrecaAppTab: Hashable {
    case news
    case games
}

struct TrecaContentView: View {
    @Environment(TrecaAuthService.self) private var auth
    @State private var selectedTab: TrecaAppTab = .news

    var body: some View {
        if auth.isLoggedIn {
            TabView(selection: $selectedTab) {
                Tab("Novosti", systemImage: "newspaper", value: TrecaAppTab.news) {
                    TrecaNewsListView()
                }
                Tab("Igrice", systemImage: "gamecontroller", value: TrecaAppTab.games) {
                    TrecaGamesView()
                }
            }
        } else {
            TrecaLoginView()
        }
    }
}

#Preview {
    TrecaContentView()
        .environment(TrecaAuthService())
}
