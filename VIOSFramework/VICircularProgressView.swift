//
//  VICircularProgressView.swift
//  living
//
//  Created by Nils Fischer on 05.08.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

import UIKit

@IBDesignable
public class VICircularProgressView: UIView {

    
    // MARK: - Public Attributes
    
    /// The progress to visualize. Takes values between 0 and 1.
    @IBInspectable public var progress: CGFloat = 0.5 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// The angle where the progress bar drawing starts. Takes values between 0 and 1, where 0 is the top center and 1 corresponds to one complete rotation of 2π.
    @IBInspectable public var startAngle: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    /// Whether the progress bar fills clockwise or counter-clockwise
    @IBInspectable public var clockwise: Bool = true {
        didSet {
            self.setNeedsDisplay()
        }
    }
    /// The progress bar's line width
    @IBInspectable public var lineWidth: CGFloat = 5 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    /// The progress bar's tint color. Uses the `tintColor` property of `UIView` if not set.
    @IBInspectable public var progressTintColor: UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    /// The track bar's tint color. Uses a light gray color if not set.
    @IBInspectable public var trackTintColor: UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// Show or hide the text
    @IBInspectable public var showText: Bool = true
    
    // TODO: simplify text/attributedText behaviour?
    /// Any text displayed instead of the default percentage progress. Use the `attributedText` property to specify formatting options.
    @IBInspectable public var text: String? {
        get {
            return attributedText?.string
        }
        set {
            if let text = newValue {
                attributedText = NSAttributedString(string: text)
            } else {
                attributedText = nil
            }
        }
    }
    /// Any attributed text displayed instead of the default percentage progress.
    @IBInspectable public var attributedText: NSAttributedString? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// Any image displayed inside the track bar
    @IBInspectable public var image: UIImage? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    
    // MARK: - Drawing
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        // make sure to redraw when the layout changes
        self.setNeedsDisplay()
    }
    
    override public func drawRect(rect: CGRect)
    {
        let startAngle = self.startAngle * 2 * CGFloat(M_PI) - CGFloat(M_PI_2)
        let endAngle = 2 * CGFloat(M_PI) * progress + startAngle
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let clockwise = self.clockwise
        let lineWidth = self.lineWidth
        let outerRadius = min(rect.size.width/2, rect.size.height/2);
        let innerRadius = outerRadius - lineWidth
        let radius = outerRadius - lineWidth / 2
        let circleRect = CGRectMake(center.x - radius, center.y - radius, 2 * radius, 2 * radius)
        let innerCircleRect = CGRectInset(circleRect, (radius - innerRadius), (radius - innerRadius))
        
        // Image
        if let image = self.image {
            let context = UIGraphicsGetCurrentContext()
            CGContextSaveGState(context)
            // TODO: smooth drawing possible without inset?
            let imageInset = lineWidth / 2
            UIBezierPath(ovalInRect: CGRectInset(innerCircleRect, -imageInset, -imageInset)).addClip()
            image.drawInRect(CGRectInset(innerCircleRect, -imageInset, -imageInset))
            CGContextRestoreGState(context)
        }
        
        
        // Track
        let trackPath: UIBezierPath = {
            if self.progress == 0 {
                return UIBezierPath(ovalInRect: circleRect)
            } else  {
                return UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: !clockwise)
            }
        }()
        trackPath.lineWidth = lineWidth
        if let trackTintColor = self.trackTintColor {
            trackTintColor.setStroke()
        } else {
            UIColor(white: 0.9, alpha: 1).setStroke()
        }
        trackPath.stroke()
        
        // Progress bar
        let progressPath: UIBezierPath = {
            if self.progress == 1 {
                return UIBezierPath(ovalInRect: circleRect)
            } else  {
                return UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
            }
        }()
        progressPath.lineWidth = lineWidth
        if let progressTintColor = self.progressTintColor {
            progressTintColor.setStroke()
        } else {
            tintColor.setStroke()
        }
        progressPath.stroke()
        
        // Text
        if showText {
            let attributedText = self.attributedText?.mutableCopy() as? NSMutableAttributedString ?? NSMutableAttributedString(string: "\(round(progress))%")
            let textRect = attributedText.boundingRectWithSize(innerCircleRect.size, options: .TruncatesLastVisibleLine, context: nil)
            attributedText.drawInRect(CGRect(x: innerCircleRect.origin.x + innerCircleRect.size.width / 2 - textRect.size.width / 2, y: innerCircleRect.origin.y + innerCircleRect.size.height / 2 - textRect.size.height / 2, width: textRect.size.width, height: textRect.size.height))
        }
    }

}
