//
//  Constants.swift
//  Test
//
//  Created by Maksim Zakharov on 27.02.2025.
//

enum Constants: String {
    // MARK: - API URLs
    case baseURL = "https://api.example.com"
    case loginEndpoint = "/auth/login"
    case registerEndpoint = "/auth/register"
    case userProfileEndpoint = "/user/profile"
    
    // MARK: - Asset Names
    case logoImage = "logo"
    case backgroundGradient = "background_gradient"
    case iconSettings = "icon_settings"
    
    // MARK: - Other Constants
    case appName = "My Awesome App"
    case avatarPlaceholder = "avatarPlaceholder"
    
    // MARK: - Helper Method
    /// Возвращает значение константы как строку
    var value: String {
        return self.rawValue
    }
}
