//
//  ColorBoxView.swift
//  Notes
//
//  Created by dyy-mac on 07/07/2019.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

@IBDesignable
class ColorBoxView: UIView {
    
    @IBInspectable var isPaletteBox: Bool = false
    @IBInspectable var isSelectedBox: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var selectedColor: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // set default border params
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
        // fill view with colors
        if isPaletteBox {
            let saturationExponentTop:Float = 0.5
            let saturationExponentBottom:Float = 0.25
            let elementSize: CGFloat = 1.0
            let context = UIGraphicsGetCurrentContext()
            for y : CGFloat in stride(from: 0.0 ,to: rect.height, by: elementSize) {
                var saturation = y < rect.height / 2.0 ? CGFloat(2 * y) / rect.height : 2.0 * CGFloat(rect.height - y) / rect.height
                saturation = CGFloat(powf(Float(saturation), y < rect.height / 2.0 ? saturationExponentTop : saturationExponentBottom))
                let brightness = y < rect.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(rect.height - y) / rect.height
                for x : CGFloat in stride(from: 0.0 ,to: rect.width, by: elementSize) {
                    let hue = x / rect.width
                    let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
                    context!.setFillColor(color.cgColor)
                    context!.fill(CGRect(x:x, y:y, width:elementSize,height:elementSize))
                }
            }
        } else {
            let context = UIGraphicsGetCurrentContext()!
            selectedColor.setFill()
            context.fill(rect)
        }
        
        // check subview exist
        if let existView = self.viewWithTag(100) {
            existView.removeFromSuperview()
        }
        guard isSelectedBox else {
            return
        }
        // generate new subview
        let selectionSubView = getSelectionSubView(in: CGPoint(x: rect.maxX, y: rect.minY))
        // add subview and set it to front
        self.addSubview(selectionSubView)
        self.bringSubviewToFront(selectionSubView)
    }
    
    // generate subview with V and tag 100 to find later
    private func getSelectionSubView(in rightPoint: CGPoint) -> UIView {
        let shapeSize: CGSize = CGSize(width: 20, height: 20)
        let shapeOffset: CGSize = CGSize(width: 5, height: 5)
        let selectionView: UIView = UIView(frame: CGRect(x: rightPoint.x - shapeSize.width - shapeOffset.width, y: rightPoint.y + shapeOffset.height, width: shapeSize.width, height: shapeSize.height))
        selectionView.alpha = 0.5
        selectionView.tag = 100
        selectionView.isUserInteractionEnabled = false
        let layer = CAShapeLayer()
        layer.path = getVPath(in: selectionView.frame).cgPath
        layer.strokeColor = UIColor.black.cgColor
        selectionView.layer.addSublayer(layer)
        return selectionView
    }
    // draw path to get V picture
    private func getVPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.lineWidth = 3
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.stroke()
        return path
    }
}
