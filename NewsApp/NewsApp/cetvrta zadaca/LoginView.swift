import SwiftUI

struct LoginView: View {
    @Environment(AuthService.self) private var auth

    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "newspaper.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.blue)
                Text("NewsApp")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }

            Spacer().frame(height: 48)

            VStack(spacing: 14) {
                TextField("Korisničko ime", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.next)

                SecureField("Lozinka", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.go)
                    .onSubmit(performLogin)
            }

            Spacer().frame(height: 24)

            Button(action: performLogin) {
                Group {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Prijavi se")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
            .buttonStyle(.borderedProminent)
            .disabled(username.isEmpty || password.isEmpty || isLoading)

            Spacer()
        }
        .padding(.horizontal, 32)
        .alert("Greška pri prijavi", isPresented: .init(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("U redu", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func performLogin() {
        guard !username.isEmpty, !password.isEmpty else { return }
        isLoading = true
        Task {
            do {
                try await auth.login(username: username, password: password)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthService())
}
