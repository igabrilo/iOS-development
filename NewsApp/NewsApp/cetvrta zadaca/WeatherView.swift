import SwiftUI

struct WeatherView: View {
    @State private var isSunny = true

    var body: some View {
        ZStack {
            // Sloj 0 — nebo
            Color(white: 0.62)
                .ignoresSafeArea()
                .opacity(isSunny ? 0 : 1)
                .zIndex(0)
            Color(hue: 0.575, saturation: 0.70, brightness: 0.88)
                .ignoresSafeArea()
                .opacity(isSunny ? 1 : 0)
                .zIndex(0)

            // Sloj 1 — sunce
            SunView(isSunny: isSunny)
                .offset(y: isSunny ? -90 : -115)
                .zIndex(1)

            // Sloj 2 — stražnji oblak
            if !isSunny {
                Image(systemName: "cloud.fill")
                    .font(.system(size: 115))
                    .foregroundStyle(Color(white: 0.95))
                    .offset(x: 48, y: -42)
                    .zIndex(2)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }

            // Sloj 3 - prednji oblak
            if !isSunny {
                Image(systemName: "cloud.fill")
                    .font(.system(size: 148))
                    .foregroundStyle(.white)
                    .offset(x: -22, y: 22)
                    .zIndex(3)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }

            // Sloj 4 — grad i temperatura
            VStack {
                Spacer()
                VStack(spacing: 4) {
                    Text("Zagreb")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text(isSunny ? "24°" : "18°")
                        .font(.system(size: 72, weight: .thin))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText(value: isSunny ? 24.0 : 18.0))
                }
                .padding(.bottom, 60)
            }
            .zIndex(4)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.5)) {
                isSunny.toggle()
            }
        }
    }
}


private struct SunView: View {
    let isSunny: Bool
    @State private var glowScale: CGFloat = 1.0

    private var sunRadius: CGFloat  { isSunny ? 70 : 55 }
    private var rayLength: CGFloat  { isSunny ? 30 : 22 }
    private var rayWidth: CGFloat   { isSunny ? 14 : 11 }
    private var glowSize: CGFloat   { isSunny ? 270 : 200 }
    private var glowOpacity: Double { isSunny ? 0.30 : 0.18 }
    private var rayOpacity: Double  { isSunny ? 1.0 : 0.70 }

    var body: some View {
        ZStack {
            // Sjaj — pulsira neovisno o stanju
            Circle()
                .fill(Color.yellow.opacity(glowOpacity))
                .frame(width: glowSize, height: glowSize)
                .scaleEffect(glowScale)

            // Zrake
            ForEach(0..<16, id: \.self) { i in
                Capsule()
                    .fill(Color.yellow.opacity(rayOpacity))
                    .frame(width: rayWidth, height: rayLength)
                    .offset(y: -(sunRadius + rayLength / 2))
                    .rotationEffect(.degrees(Double(i) * (360.0 / 16.0)))
            }

            // Tijelo sunca
            Circle()
                .fill(Color.yellow)
                .frame(width: sunRadius * 2, height: sunRadius * 2)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowScale = 1.18
            }
        }
    }
}

#Preview {
    WeatherView()
}
