//
//  UIImageView+Ext.swift
//  Test
//
//  Created by Maksim Zakharov on 26.02.2025.
//

import UIKit

extension UIImage {
    static func load(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = ImageCache.shared.image(for: url) {
            completion(cachedImage)
            return
        }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                ImageCache.shared.setImage(image, for: url)
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
