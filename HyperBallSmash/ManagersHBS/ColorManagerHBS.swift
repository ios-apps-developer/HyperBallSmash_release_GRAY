import SwiftUI

struct ColorManagerHBS {
    static let primaryHBS = Color(hex: "#FF6B6B")
    static let secondaryHBS = Color(hex: "#4ECDC4")
    static let backgroundHBS = Color(hex: "#2C3E50")
    static let accentHBS = Color(hex: "#FFE66D")
    static let textPrimaryHBS = Color(hex: "#FFFFFF")
    static let textSecondaryHBS = Color(hex: "#95A5A6")
    static let successHBS = Color(hex: "#2ECC71")
    static let warningHBS = Color(hex: "#F1C40F")
    static let errorHBS = Color(hex: "#E74C3C")
    static let ballDefaultHBS = Color(hex: "#FF4757")
    static let blockDefaultHBS = Color(hex: "#2ED573")
    static let scoreTextHBS = Color(hex: "#FECA57")
    static let menuBackgroundHBS = Color(hex: "#222F3E")
    static let buttonHighlightHBS = Color(hex: "#FF6348")
}

extension Color {
    init(hex: String) {
        let hexHBS = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var intHBS: UInt64 = 0
        Scanner(string: hexHBS).scanHexInt64(&intHBS)
        
        let redHBS, greenHBS, blueHBS, alphaHBS: Double
        
        switch hexHBS.count {
        case 3:
            redHBS = Double((intHBS >> 8) & 0xF) / 15.0
            greenHBS = Double((intHBS >> 4) & 0xF) / 15.0
            blueHBS = Double(intHBS & 0xF) / 15.0
            alphaHBS = 1.0
        case 6:
            redHBS = Double((intHBS >> 16) & 0xFF) / 255.0
            greenHBS = Double((intHBS >> 8) & 0xFF) / 255.0
            blueHBS = Double(intHBS & 0xFF) / 255.0
            alphaHBS = 1.0
        case 8:
            redHBS = Double((intHBS >> 24) & 0xFF) / 255.0
            greenHBS = Double((intHBS >> 16) & 0xFF) / 255.0
            blueHBS = Double((intHBS >> 8) & 0xFF) / 255.0
            alphaHBS = Double(intHBS & 0xFF) / 255.0
        default:
            self.init(.black)
            return
        }
        
        self.init(red: redHBS, green: greenHBS, blue: blueHBS, opacity: alphaHBS)
    }
    
    func withOpacityHBS(_ opacityHBS: Double) -> Color { self.opacity(opacityHBS) }
    
    func lighterHBS(by amountHBS: CGFloat = 0.2) -> Color { self.opacity(1.0 - amountHBS) }
    
    func darkerHBS(by amountHBS: CGFloat = 0.2) -> Color {
        guard let componentsHBS = UIColor(self).cgColor.components else { return self }
        let redHBS = max(0, componentsHBS[0] - amountHBS)
        let greenHBS = max(0, componentsHBS[1] - amountHBS)
        let blueHBS = max(0, componentsHBS[2] - amountHBS)
        
        return Color(red: redHBS, green: greenHBS, blue: blueHBS)
    }
}
