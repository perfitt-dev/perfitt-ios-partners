//
//  OverlayView.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/09/23.
//

import UIKit

/**
 This structure holds the display parameters for the overlay to be drawon on a detected object.
 */
struct ObjectOverlay {
    let name: String
    let borderRect: CGRect
    let nameStringSize: CGSize
    let color: UIColor
    let font: UIFont
}

/**
 This UIView draws overlay on a detected object.
 */
public class OverlayView: UIView {
    
    var objectOverlays: [ObjectOverlay] = []
    private let cornerRadius: CGFloat = 10.0
    private let stringBgAlpha: CGFloat = 0.7
    private let lineWidth: CGFloat = 3
    private let stringFontColor = UIColor.white
    private let stringHorizontalSpacing: CGFloat = 13.0
    private let stringVerticalSpacing: CGFloat = 7.0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        debugPrint("draw rect: \(rect)")
        self.clearsContextBeforeDrawing = false
        // Drawing code
        for objectOverlay in objectOverlays {

            drawBorders(of: objectOverlay)
//            drawBackground(of: objectOverlay)
//            drawName(of: objectOverlay)
        }
    }
    
    /**
     This method draws the borders of the detected objects.
     */
    func drawBorders(of objectOverlay: ObjectOverlay) {
        
        let path = UIBezierPath(rect: objectOverlay.borderRect)
        path.lineWidth = lineWidth
        objectOverlay.color.setStroke()
        
        path.stroke()
    }
    
    /**
     This method draws the background of the string.
     */
    func drawBackground(of objectOverlay: ObjectOverlay) {
        
        let stringBgRect = CGRect(x: objectOverlay.borderRect.origin.x, y: objectOverlay.borderRect.origin.y , width: 2 * stringHorizontalSpacing + objectOverlay.nameStringSize.width, height: 2 * stringVerticalSpacing + objectOverlay.nameStringSize.height
        )
        
        let stringBgPath = UIBezierPath(rect: stringBgRect)
//        objectOverlay.color.withAlphaComponent(stringBgAlpha).setFill()
        stringBgPath.fill()
    }
    
    /**
     This method draws the name of object overlay.
     */
    func drawName(of objectOverlay: ObjectOverlay) {
        
        // Draws the string.
        let stringRect = CGRect(x: objectOverlay.borderRect.origin.x + stringHorizontalSpacing, y: objectOverlay.borderRect.origin.y + stringVerticalSpacing, width: objectOverlay.nameStringSize.width, height: objectOverlay.nameStringSize.height)
        
        let attributedString = NSAttributedString(string: objectOverlay.name, attributes: [NSAttributedString.Key.foregroundColor : stringFontColor, NSAttributedString.Key.font : objectOverlay.font])
        attributedString.draw(in: stringRect)
    }
    
}
