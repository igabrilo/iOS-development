import SwiftUI

struct DrugaWordleWords {
    static let all = [
        "OBLAK", "STVAR", "RIJEC", "PLOCA", "KUCHA",
        "ZEMJA", "VRATA", "KNJGA", "STRAH", "DRVO!",
        "SNAGA", "ZIVOT", "TABLA", "JUNAK", "MASKA",
        "TRUBA", "BREZA", "KLUPA", "LAMPA", "PTICA"
    ]
}

struct DrugaLetterSquareView: View {
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

struct DrugaAttemptRowView: View {
    let word: String
    let solution: String

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<5, id: \.self) { index in
                DrugaLetterSquareView(character: word[index], color: color(at: index))
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

struct DrugaAttemptListView: View {
    let attempts: [String]
    let solution: String

    var body: some View {
        ForEach(Array(attempts.enumerated()), id: \.offset) { _, word in
            DrugaAttemptRowView(word: word, solution: solution)
        }
    }
}

struct DrugaCurrentGuessView: View {
    @Binding var currentGuess: String

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<5, id: \.self) { index in
                if index < currentGuess.count {
                    DrugaLetterSquareView(character: currentGuess[index], color: Color.gray.opacity(0.3))
                        .onTapGesture {
                            let stringIndex = currentGuess.index(currentGuess.startIndex, offsetBy: index)
                            currentGuess.remove(at: stringIndex)
                        }
                } else {
                    DrugaLetterSquareView(character: " ", color: Color.gray.opacity(0.15))
                }
            }
        }
    }
}

struct DrugaWordleView: View {
    @State var attempts: [String]
    @State private var currentGuess: String = ""
    @State private var solution: String
    @State private var gameOver: Bool = false

    init(attempts: [String] = []) {
        _attempts = State(initialValue: attempts)
        _solution = State(initialValue: DrugaWordleWords.all.randomElement()!)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 8) {
                    DrugaAttemptListView(attempts: attempts, solution: solution)
                    DrugaCurrentGuessView(currentGuess: $currentGuess)
                }
                .padding()
            }

            Divider()

            HStack {
                TextField("Pogodi...", text: $currentGuess)
                    .autocorrectionDisabled()
                    .disabled(gameOver)

                Button("Potvrdi") {
                    let guess = currentGuess.uppercased()
                    attempts.append(guess)
                    currentGuess = ""
                    if guess == solution.uppercased() {
                        gameOver = true
                    }
                }
                .disabled(currentGuess.count != 5 || gameOver)
            }
            .padding()
        }
        .alert("Bravo!", isPresented: $gameOver) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Pogodili ste riječ \(solution) u \(attempts.count) pokušaja!")
        }
    }
}

#Preview {
    NavigationStack {
        DrugaWordleView()
    }
}
