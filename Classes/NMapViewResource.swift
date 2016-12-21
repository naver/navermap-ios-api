//
//  NMapViewResource.swift
//  NMapViewerLib
//
//  Created by YiSeungyoun on 2016. 12. 21..
//
//

import UIKit

enum NMapPOIflagType: UInt {
    case Base = 0x100
    case Pin
    case Spot
    case From
    case To
    case Number
    case Loaction = 10
    case LoactionOff = 11
    case Compass = 12
}

private let kCalloutTextSize = 14.0
private let kCalloutHeightForText = 34

private let kCalloutMarginHorizLeft = 13
private let kCalloutMarginHorizRight = 11

private let kCalloutGapIcon = 5
private let kCalloutOffsetLeft = 0
private let kCalloutOffsetRight = 0

private let kCalloutSizeMin = 89

private let kTestLongText = "명칭이 긴 경우에는 적당히 말줄임이 되어야 하는데 잘되나요????????"

private let kPinInfoIconOffsetX = (0.0)
private let kPinInfoIconOffsetY = (0.0)
private let kNumberIconColor = (1.0*0x77/0xFF)
private let kNumberIconColorOver = (1.0)

class NMapViewResource: NSObject {
    
    func makeNumberIconImage(backImageName: String, color: Float, iconNumber: Int) -> UIImage {
        let backImage = UIImage.init(named: backImageName)

        if let _backImage = backImage {
            let iconSize = _backImage.size
            var imageSize = iconSize
            imageSize.width += 2
            imageSize.height += 2
            
            let iconText: NSString = "\(iconNumber)" as NSString
            
            var actualFontSize: CGFloat = 10
            if iconNumber < 10 {
                actualFontSize = 12
            } else {
                actualFontSize = 11
            }
            
            let font = UIFont.boldSystemFont(ofSize: actualFontSize)
            let textParagraphStyle:NSMutableParagraphStyle  = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            textParagraphStyle.lineBreakMode = .byTruncatingTail
            
            
            let boundText = iconText.boundingRect(with: iconSize, options: ([.usesLineFragmentOrigin, .usesFontLeading]), attributes: [NSFontAttributeName: font, NSParagraphStyleAttributeName: textParagraphStyle], context: nil)
            
            let sizeText = boundText.size
            
            let systemVersion = Float(UIDevice.current.systemVersion)
            if let _systemVersion = systemVersion {
                if _systemVersion >= 4.0 {
                    UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
                } else {
                    UIGraphicsBeginImageContext(imageSize)
                }
            }
            
            var pt = CGPoint.zero
            pt.x = (imageSize.width - iconSize.width) / 2
            pt.y = (imageSize.height - iconSize.height) / 2
            
            pt.x = CGFloat(roundf(Float(pt.x)));
            pt.y = CGFloat(roundf(Float(pt.y)));
            backImage?.draw(at: pt, blendMode: .copy, alpha: 1.0)
            
            var rectText: CGRect?
            rectText?.origin.x = pt.x + (iconSize.width - sizeText.width)/2
            rectText?.origin.y = pt.y + (iconSize.height - sizeText.height)/2
            rectText?.size.width = sizeText.width
            rectText?.size.height = sizeText.height
            
            if let originX = rectText?.origin.x, let originY = rectText?.origin.y {
                rectText?.origin.x = CGFloat(roundf(Float(originX)))
                rectText?.origin.y = CGFloat(roundf(Float(originY)))
                
            }
            
            let fontColor = UIColor.init(colorLiteralRed: color, green: color, blue: color, alpha: 1.0)
            
            if let _rectText = rectText {
            iconText.draw(in: _rectText, withAttributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: fontColor, NSParagraphStyleAttributeName: textParagraphStyle])
            }
            
            let iconImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            return iconImage!
        }
        
        return UIImage()
        
    }
    
    func imageWithType(poiFlagType: NMapPOIflagType, iconIndex: Int, selected: Bool) {
        var image: UIImage?
        
        switch poiFlagType {
        case .Pin:
            break
        case .Spot:
            if
            break
        case .Loaction:
            break
        case .LoactionOff:
            break
        case .Compass:
            break
        case .From:
            break
        case .To:
            break
        case .Number:
            break
        default:
            break
        }
    }
    
    
    
    
}
