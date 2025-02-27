/// Модель отзыва.
struct Review: Decodable {
    
    /// Имя пользователя.
    let firstName: String
    /// Фамилия пользователя.
    let lastName: String
    /// Рейтинг.
    let rating: Int
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    /// Полное имя пользователя
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    /// Аватар пользователя
    let avatar: String
    /// Массив URL фотографий в отзыве
        let photos: [String]?
    
}
