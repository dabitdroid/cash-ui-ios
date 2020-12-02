//
//  Created by Giancarlo Pacheco on 12/1/20.
//

import UIKit

public class ImageHelper {
    
    public static func ovalImage(with rect: CGRect) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
            let context = UIGraphicsGetCurrentContext()!
            
            let ovalPath = UIBezierPath()
            ovalPath.move(to: CGPoint(x: rect.minX + rect.height/2, y: rect.minY))
            ovalPath.addArc(withCenter: CGPoint(x: rect.minX + rect.height/2, y: rect.minY + rect.height/2), radius: rect.height/2, startAngle: 3*CGFloat.pi/2, endAngle: CGFloat.pi/2, clockwise: false)
            ovalPath.addLine(to: CGPoint(x: rect.maxX - rect.height/2, y: rect.maxY))
            ovalPath.addArc(withCenter: CGPoint(x: rect.maxX - rect.height/2, y: rect.maxY - rect.height/2), radius: rect.height/2, startAngle: CGFloat.pi/2, endAngle: 3*CGFloat.pi/2, clockwise: false)
            ovalPath.addLine(to: CGPoint(x: rect.minX + rect.height/2, y: rect.minY))
            
            context.saveGState()
            context.addPath(ovalPath.cgPath)
            UIColor.white.setFill()
            ovalPath.fill(with: .color, alpha: 1.0)
            context.restoreGState()
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return image
        }
}
