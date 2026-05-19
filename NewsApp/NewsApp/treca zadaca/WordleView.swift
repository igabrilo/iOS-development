import SwiftUI

extension String {
    subscript(_ i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}


struct WordleWords {
    static let all = [
        "OBLAK", "STVAR", "RIJEC", "PLOCA", "KUCHA",
        "ZEMJA", "VRATA", "KNJGA", "STRAH", "DRVO!",
        "SNAGA", "ZIVOT", "TABLA", "JUNAK", "MASKA",
        "TRUBA", "BREZA", "KLUPA", "LAMPA", "PTICA"
    ]
}



struct LetterSquareView: View {
    let character: Character
    let color: Color

    var body: some View {
        Text(String(character))
            .font(.title2)
            .fontWeight(.bold)
            .frame(width: 70, height: 55)
            .background(color)
            .cornerRadius(6)
    }
}


struct AttemptRowView: View {
    let word: String
    let solution: String

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<5, id: \.self) { index in
                LetterSquareView(character: word[index], color: color(at: index))
            }
        }
    }

    func color(at index: Int) -> Color {
        let guessChar = Character(word[index].uppercased())
        let solutionChar = Character(solution[index].uppercased())

        if guessChar == solutionChar {
            return .green
        } else if solution.uppercased().contains(guessChar) {
            return .yellow
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}


struct AttemptListView: View {
    let attempts: [String]
    let solution: String

    var body: some View {
        ForEach(Array(attempts.enumerated()), id: \.offset) { _, word in
            AttemptRowView(word: word, solution: solution)
        }
    }
}

struct CurrentGuessView: View {
    @Binding var currentGuess: String

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<5, id: \.self) { index in
                if index < currentGuess.count {
                    LetterSquareView(character: currentGuess[index], color: Color.gray.opacity(0.3))
                        .onTapGesture {
                            let stringIndex = currentGuess.index(currentGuess.startIndex, offsetBy: index)
                            currentGuess.remove(at: stringIndex)
                        }
                } else {
                    LetterSquareView(character: " ", color: Color.gray.opacity(0.15))
                }
            }
        }
    }
}


struct WordleView: View {
    @Environment(AuthService.self) private var auth
    @State var attempts: [String]
    @State private var currentGuess: String = ""
    @State private var solution: String
    @State private var gameOver: Bool = false
    @State private var isLoadingWord: Bool = true

    init(attempts: [String] = []) {
        _attempts = State(initialValue: attempts)
        _solution = State(initialValue: WordleWords.all.randomElement()!)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 8) {
                    AttemptListView(attempts: attempts, solution: solution)
                    if isLoadingWord {
                        ProgressView("Učitavanje riječi...")
                            .frame(height: 55)
                    } else {
                        CurrentGuessView(currentGuess: $currentGuess)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                TextField("Pogodi...", text: $currentGuess)
                    .autocorrectionDisabled()
                    .disabled(gameOver || isLoadingWord)

                Button("Potvrdi") {
                    let guess = currentGuess.uppercased()
                    attempts.append(guess)
                    currentGuess = ""
                    if guess == solution.uppercased() {
                        gameOver = true
                    }
                }
                .disabled(currentGuess.count != 5 || gameOver || isLoadingWord)
            }
            .padding()
        }
        .alert("Bravo!", isPresented: $gameOver) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Pogodili ste riječ \(solution) u \(attempts.count) pokušaja!")
        }
        .task {
            await loadWord()
        }
    }

    private func loadWord() async {
        guard let token = auth.token else {
            isLoadingWord = false
            return
        }
        do {
            solution = try await NewsService.shared.fetchWordleWord(token: token)
        } catch {
            // fallback: zadržava nasumičnu riječ postavljenu u init-u
        }
        isLoadingWord = false
    }
}

#Preview {
    NavigationStack {
        WordleView()
            .environment(AuthService())
    }
}
