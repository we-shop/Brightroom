//
//  CropView.GuideOverlays.swift
//  PixelEditor
//
//  Created by Muukii on 2021/03/03.
//  Copyright © 2021 muukii. All rights reserved.
//

import Foundation

/// https://havecamerawilltravel.com/lightroom/crop-overlays/
extension CropView {
  public final class CropOverlayHandlesView: PixelEditorCodeBasedView {
    
    public let edgeShapeLayer = UIView()

    private let cornerTopLeftHorizontalShapeLayer = UIView()
    private let cornerTopLeftVerticalShapeLayer = UIView()

    private let cornerTopRightHorizontalShapeLayer = UIView()
    private let cornerTopRightVerticalShapeLayer = UIView()

    private let cornerBottomLeftHorizontalShapeLayer = UIView()
    private let cornerBottomLeftVerticalShapeLayer = UIView()

    private let cornerBottomRightHorizontalShapeLayer = UIView()
    private let cornerBottomRightVerticalShapeLayer = UIView()

    public init() {
      super.init(frame: .zero)

      isUserInteractionEnabled = false

      addSubview(edgeShapeLayer)
      [
        cornerTopLeftHorizontalShapeLayer,
        cornerTopLeftVerticalShapeLayer,
        cornerTopRightHorizontalShapeLayer,
        cornerTopRightVerticalShapeLayer,
        cornerBottomLeftHorizontalShapeLayer,
        cornerBottomLeftVerticalShapeLayer,
        cornerBottomRightHorizontalShapeLayer,
        cornerBottomRightVerticalShapeLayer,
      ].forEach {
        addSubview($0)
        $0.backgroundColor = UIColor.white
      }
    }

    override public func layoutSubviews() {
      super.layoutSubviews()

      edgeShapeLayer&>.do {
        $0.frame = bounds.insetBy(dx: -2, dy: -2)
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.white.cgColor
      }
      
      do {
        
        let lineWidth: CGFloat = 4
        let lineLength: CGFloat = 24
        
        do {
          cornerTopLeftHorizontalShapeLayer.frame = .init(
            origin: .init(x: -lineWidth, y: -lineWidth),
            size: .init(width: lineLength, height: lineWidth)
          )
          cornerTopLeftVerticalShapeLayer.frame = .init(
            origin: .init(x: -lineWidth, y: -lineWidth),
            size: .init(width: lineWidth, height: lineLength)
          )
        }
        
        do {
          cornerTopRightHorizontalShapeLayer.frame = .init(
            origin: .init(x: bounds.maxX - lineLength + lineWidth, y: -lineWidth),
            size: .init(width: lineLength, height: lineWidth)
          )
          cornerTopRightVerticalShapeLayer.frame = .init(
            origin: .init(x: bounds.maxX, y: -lineWidth),
            size: .init(width: lineWidth, height: lineLength)
          )
        }
        
        do {
          cornerBottomRightHorizontalShapeLayer.frame = .init(
            origin: .init(x: bounds.maxX - lineLength + lineWidth, y: bounds.maxY),
            size: .init(width: lineLength, height: lineWidth)
          )
          cornerBottomRightVerticalShapeLayer.frame = .init(
            origin: .init(x: bounds.maxX, y: bounds.maxY - lineLength + lineWidth),
            size: .init(width: lineWidth, height: lineLength)
          )
        }
        
        do {
          cornerBottomLeftHorizontalShapeLayer.frame = .init(
            origin: .init(x: -lineWidth, y: bounds.maxY),
            size: .init(width: lineLength, height: lineWidth)
          )
          cornerBottomLeftVerticalShapeLayer.frame = .init(
            origin: .init(x: -lineWidth, y: bounds.maxY - lineLength + lineWidth),
            size: .init(width: lineWidth, height: lineLength)
          )
        }
        
      }
      
    }
  }
  
  open class CropOverlayBase: PixelEditorCodeBasedView {
    // FIXME: add call-back methods
    
    open func didBeginAdjustment() {
      
    }
    
    open func didEndAdjustment() {
      
    }
  }

  public final class CropOverlayRuleOfThirds: CropOverlayBase {
    
    private let handlesView = CropOverlayHandlesView()
    
    private let verticalLine1 = UIView()
    private let verticalLine2 = UIView()
    
    private let horizontalLine1 = UIView()
    private let horizontalLine2 = UIView()
    
    private var currentAnimator: UIViewPropertyAnimator?
        
    public init() {
      super.init(frame: .zero)

      isUserInteractionEnabled = false
      addSubview(handlesView)
      AutoLayoutTools.setEdge(handlesView, self)
      
      lines()
        .forEach {
          addSubview($0)
          $0.backgroundColor = UIColor(white: 1, alpha: 0.3)
          $0.alpha = 0
        }
      
    }
    
    private func lines() -> [UIView] {
      [
        verticalLine1,
        verticalLine2,
        horizontalLine1,
        horizontalLine2,
      ]
    }
    
    public override func layoutSubviews() {
      
      super.layoutSubviews()
      
      let width = (bounds.width / 3).rounded(.down)
      let height = (bounds.height / 3).rounded(.down)
      
      do {
        
        verticalLine1.frame = .init(
          origin: .init(x: width, y: 0),
          size: .init(width: 1, height: bounds.height)
        )
        
        verticalLine2.frame = .init(
          origin: .init(x: width * 2, y: 0),
          size: .init(width: 1, height: bounds.height)
        )
      }
      
      do {
        horizontalLine1.frame = .init(
          origin: .init(x: 0, y: height),
          size: .init(width: bounds.width, height: 1)
        )
        
        horizontalLine2.frame = .init(
          origin: .init(x: 0, y: height * 2),
          size: .init(width: bounds.width, height: 1)
        )
        
      }
    }
    
    public override func didBeginAdjustment() {
      currentAnimator?.stopAnimation(true)
      currentAnimator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
        self.lines().forEach {
          $0.alpha = 1
        }
      }&>.do {
        $0.startAnimation()
      }
    }
    
    public override func didEndAdjustment() {
      currentAnimator?.stopAnimation(true)
      currentAnimator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
        self.lines().forEach {
          $0.alpha = 0
        }
      }&>.do {
        $0.startAnimation(afterDelay: 2)
      }
    }
  }
}
