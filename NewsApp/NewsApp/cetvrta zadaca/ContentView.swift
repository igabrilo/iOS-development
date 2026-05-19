import SwiftUI

enum AppTab: Hashable {
    case news
    case games
    case weather
}

struct ContentView: View {
    @Environment(AuthService.self) private var auth
    @State private var selectedTab: AppTab = .news

    var body: some View {
        if auth.isLoggedIn {
            TabView(selection: $selectedTab) {
                Tab("Novosti", systemImage: "newspaper", value: .news) {
                    NewsListView()
                }

                Tab("Igrice", systemImage: "gamecontroller", value: .games) {
                    GamesView()
                }

                Tab("Prognoza", systemImage: "cloud.sun.fill", value: .weather) {
                    WeatherView()
                }
            }
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthService())
}

