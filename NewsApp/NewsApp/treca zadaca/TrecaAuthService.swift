import Foundation
import Observation

private struct TrecaLoginResponse: Decodable {
    let token: String
    let username: String
}

enum TrecaAuthError: LocalizedError {
    case serverError(Int)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .serverError(let code):
            return "Prijava nije uspjela (HTTP \(code)). Provjerite podatke i pokušajte ponovo."
        case .decodingFailed:
            return "Neočekivan odgovor poslužitelja."
        }
    }
}

@Observable
final class TrecaAuthService {
    var token: String? = nil
    var username: String? = nil

    var isLoggedIn: Bool { token != nil }

    private let loginURL = URL(string: "https://ios-vjestina.flabbergast.com/login")!

    func login(username: String, password: String) async throws {
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["username": username, "password": password])

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw TrecaAuthError.serverError(httpResponse.statusCode)
        }

        guard let loginResponse = try? JSONDecoder().decode(TrecaLoginResponse.self, from: data) else {
            throw TrecaAuthError.decodingFailed
        }

        self.token = loginResponse.token
        self.username = loginResponse.username
    }

    func logout() {
        token = nil
        username = nil
    }
}
