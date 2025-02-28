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
    
    private let dotSize: CGFloat
    private let dotSpacing: CGFloat
    private let dotColor: UIColor
    private let horizontalPadding: CGFloat
    
    init(
        frame: CGRect = .zero,
        dotSize: CGFloat = 10.0,
        dotSpacing: CGFloat = 15.0,
        dotColor: UIColor = .systemBlue,
        horizontalPadding: CGFloat = 8.0
    ) {
        self.dotSize = dotSize
        self.dotSpacing = dotSpacing
        self.dotColor = dotColor
        self.horizontalPadding = horizontalPadding
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayersLayout()
    }
    
    override var intrinsicContentSize: CGSize {
        let dotsWidth = CGFloat(replicatorLayer.instanceCount) * dotSize
        let spacingWidth = CGFloat(replicatorLayer.instanceCount - 1) * dotSpacing
        let width = dotsWidth + spacingWidth + (2 * horizontalPadding)
        let height = dotSize + (2 * horizontalPadding)
        return CGSize(width: width, height: height)
    }
    
    private func setupView() {
        replicatorLayer.instanceCount = 3
        replicatorLayer.instanceTransform = CATransform3DMakeTranslation(dotSpacing + dotSize, 0, 0)
        replicatorLayer.instanceDelay = 0.2
        
        dotLayer.bounds = CGRect(origin: .zero, size: CGSize(width: dotSize, height: dotSize))
        dotLayer.cornerRadius = dotSize / 2
        dotLayer.backgroundColor = dotColor.cgColor
        
        replicatorLayer.addSublayer(dotLayer)
        layer.addSublayer(replicatorLayer)
        
        backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
        layer.cornerRadius = 10
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4
        
        invalidateIntrinsicContentSize()
    }
    
    private func updateLayersLayout() {
        let dotsWidth = CGFloat(replicatorLayer.instanceCount) * dotSize
        let spacingWidth = CGFloat(replicatorLayer.instanceCount - 1) * dotSpacing
        let totalWidth = dotsWidth + spacingWidth

        replicatorLayer.frame = CGRect(
            x: horizontalPadding,
            y: (bounds.height - dotSize) / 2,
            width: totalWidth,
            height: dotSize
        )
        
        dotLayer.position = CGPoint(x: dotSize / 2, y: dotSize / 2)
    }
    
    func startAnimating() {
        isHidden = false
        
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.3
        animation.duration = 0.6
        animation.autoreverses = true
        animation.repeatCount = .infinity
        
        dotLayer.add(animation, forKey: "loading")
    }
    
    func stopAnimating() {
        isHidden = true
        dotLayer.removeAllAnimations()
    }
}
