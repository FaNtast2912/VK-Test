//
//  Int+Ext.swift
//  Test
//
//  Created by Maksim Zakharov on 26.02.2025.
//
import Foundation

/// Правила выбора окончания:
/// - Если число заканчивается на 11-14 или на 0, выбираем "отзывов"
/// - Если число заканчивается на 2-4, выбираем "отзыва"
/// - Если число заканчивается на 1, выбираем "отзыв"
extension Int {
    func formattedReviewsString() -> String {
        
        let endings = ["отзыв", "отзыва", "отзывов"]
        
        let lastTwoDigits = self % 100
        let lastDigit = self % 10
        
        
        let index: Int
        if (lastTwoDigits >= 11 && lastTwoDigits <= 14) || lastDigit == 0 {
            index = 2 // "отзывов"
        } else if lastDigit >= 2 && lastDigit <= 4 {
            index = 1 // "отзыва"
        } else if lastDigit == 1 {
            index = 0 // "отзыв"
        } else {
            index = 2 // "отзывов" для остальных случаев
        }
        
        return "\(self) \(endings[index])"
    }
}
