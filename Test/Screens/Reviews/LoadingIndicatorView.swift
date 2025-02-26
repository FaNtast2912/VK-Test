//
//  LoadingIndicatorView.swift
//  Test
//
//  Created by Maksim Zakharov on 26.02.2025.
//

import UIKit

final class LoadingIndicatorView: UIView {
    
    private let replicatorLayer = CAReplicatorLayer()
    private let dotLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let dotSize: CGFloat = 10.0
        let dotSpacing: CGFloat = 15.0
        
        replicatorLayer.instanceCount = 3
        replicatorLayer.instanceTransform = CATransform3DMakeTranslation(dotSpacing, 0, 0)
        replicatorLayer.instanceDelay = 0.2
        
        dotLayer.frame = CGRect(x: 0, y: 0, width: dotSize, height: dotSize)
        dotLayer.cornerRadius = dotSize / 2
        dotLayer.backgroundColor = UIColor.systemBlue.cgColor
        
        replicatorLayer.addSublayer(dotLayer)
        layer.addSublayer(replicatorLayer)
    }
    
    func startAnimating() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.3
        animation.duration = 0.6
        animation.autoreverses = true
        animation.repeatCount = .infinity
        dotLayer.add(animation, forKey: "loading")
    }
    
    func stopAnimating() {
        dotLayer.removeAllAnimations()
    }
}
