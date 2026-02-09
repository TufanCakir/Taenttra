//
//  Color+Extensions.swift
//  Taenttra
//
//  Created by Tufan Cakir on 08.02.26.
//

import SwiftUI
import simd

// MARK: - Color ⇄ HEX + SIMD Extensions
extension Color {

    init(hex: String, alpha: Double? = nil) {
        var hex = hex.trimmingCharacters(in: .alphanumerics.inverted)

        if hex.count == 3 {
            hex = hex.map { "\($0)\($0)" }.joined()
        }

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            self = .black
            return
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: alpha ?? Double(a) / 255
        )
    }

    /// Gibt die Farbe als 32-Bit Float-Vektor zurück – ideal für Metal-Shader.
    var simd: SIMD4<Float> {
        #if canImport(UIKit)
            let color = UIColor(self)
            var r: CGFloat = 1
            var g: CGFloat = 1
            var b: CGFloat = 1
            var a: CGFloat = 1
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
        #else
            var r: Double = 1
            var g: Double = 1
            var b: Double = 1
            var a: Double = 1
            NSColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif
        return SIMD4(Float(r), Float(g), Float(b), Float(a))
    }

    /// Erstellt eine `Color` aus einem Metal-kompatiblen `SIMD4<Float>`-Vektor.
    init(simd vector: SIMD4<Float>) {
        self.init(
            .sRGB,
            red: Double(vector.x),
            green: Double(vector.y),
            blue: Double(vector.z),
            opacity: Double(vector.w)
        )
    }

    /// Konvertiert eine `Color` in einen hexadezimalen String (`#RRGGBB`).
    func toHexString() -> String {
        #if canImport(UIKit)
            let uiColor = UIColor(self)
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #else
            let nsColor = NSColor(self)
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            nsColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif
        return String(
            format: "#%02X%02X%02X",
            Int(r * 255),
            Int(g * 255),
            Int(b * 255)
        )
    }
}

extension LinearGradient {
    static func game(
        _ start: Color,
        _ end: Color,
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing
    ) -> LinearGradient {
        LinearGradient(
            colors: [start, end],
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}

extension RadialGradient {
    static func glow(
        color: Color,
        radius: CGFloat = 120
    ) -> RadialGradient {
        RadialGradient(
            colors: [
                color.opacity(0.9),
                color.opacity(0.4),
                .clear
            ],
            center: .center,
            startRadius: 0,
            endRadius: radius
        )
    }
}

extension Color {

    func lighter(_ amount: Double = 0.2) -> Color {
        adjust(brightness: amount)
    }

    func darker(_ amount: Double = 0.2) -> Color {
        adjust(brightness: -amount)
    }

    private func adjust(brightness: Double) -> Color {
        #if canImport(UIKit)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        return Color(
            red: min(max(Double(r) + brightness, 0), 1),
            green: min(max(Double(g) + brightness, 0), 1),
            blue: min(max(Double(b) + brightness, 0), 1),
            opacity: Double(a)
        )
        #else
        return self
        #endif
    }
}

extension View {
    func glow(color: Color, radius: CGFloat = 10) -> some View {
        self
            .shadow(color: color.opacity(0.8), radius: radius)
            .shadow(color: color.opacity(0.5), radius: radius / 2)
    }
}
