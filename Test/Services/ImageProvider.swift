//
//  ImageProvider.swift
//  Test
//
//  Created by Maksim Zakharov on 27.02.2025.
//

import UIKit

/// Класс для асинхронной загрузки и кэширования изображений
final class ImageProvider {
    

    static let shared = ImageProvider()
    
    /// Кэш изображений
    private let imageCache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        
        let urlString = url.absoluteString as NSString
        
        if let cachedImage = imageCache.object(forKey: urlString) {
            completion(cachedImage)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard
                let self = self,
                let data = data,
                let image = UIImage(data: data),
                error == nil,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200
            else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            self.imageCache.setObject(image, forKey: urlString)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
        
        task.resume()
    }
    
    func clearCache() {
        imageCache.removeAllObjects()
    }
}
