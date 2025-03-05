import SwiftUI

struct FontManagerHBS {
    static func createHBS(sizeHBS: CGFloat, weightHBS: Font.Weight) -> Font { .custom("Digitalt", size: sizeHBS).weight(weightHBS) }
    static let h12 = createHBS(sizeHBS: 12, weightHBS: .bold)
    static let h16 = createHBS(sizeHBS: 16, weightHBS: .bold)
    static let h18 = createHBS(sizeHBS: 18, weightHBS: .bold)
    static let h20 = createHBS(sizeHBS: 20, weightHBS: .bold)
    static let h23 = createHBS(sizeHBS: 23, weightHBS: .bold)
    static let h25 = createHBS(sizeHBS: 25, weightHBS: .bold)
    static let h28 = createHBS(sizeHBS: 28, weightHBS: .bold)
    static let h30 = createHBS(sizeHBS: 30, weightHBS: .bold)
    static let h32 = createHBS(sizeHBS: 32, weightHBS: .bold)
    static let h34 = createHBS(sizeHBS: 34, weightHBS: .bold)
    static let h40 = createHBS(sizeHBS: 40, weightHBS: .bold)
    static let h44 = createHBS(sizeHBS: 44, weightHBS: .bold)
    static let h48 = createHBS(sizeHBS: 48, weightHBS: .bold)
}

