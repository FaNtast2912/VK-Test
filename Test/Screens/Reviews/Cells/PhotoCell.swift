//
//  PhotoCell.swift
//  Test
//
//  Created by Maksim Zakharov on 27.02.2025.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(imageView)
        imageView.frame = contentView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
    }
    
    func loadImage(from url: URL) {
        imageView.image = nil
        ImageProvider.shared.loadImage(from: url) { [weak self] image in
            self?.imageView.image = image
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
