import SwiftUI

struct TrecaGamesView: View {
    var body: some View {
        NavigationStack {
            TrecaWordleView()
        }
    }
}

#Preview {
    TrecaGamesView()
        .environment(TrecaAuthService())
}
