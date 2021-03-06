//
//  Extension.swift
//  PerfittPartners_iOS
//
//  Created by nick on 2020/09/18.
//

import UIKit
import Accelerate
import CoreText

enum CamMode: String {
    case KIT = "ml1"
    case A4 = "ml2"
}

extension CVPixelBuffer {
    // Returns thumbnail by cropping pixel buffer to biggest square and scaling the cropped image
    // to model dimensions.
    func resized(to size: CGSize ) -> CVPixelBuffer? {
        
        let imageWidth = CVPixelBufferGetWidth(self)
        let imageHeight = CVPixelBufferGetHeight(self)
        
        let pixelBufferType = CVPixelBufferGetPixelFormatType(self)
        
        assert(pixelBufferType == kCVPixelFormatType_32BGRA ||
                pixelBufferType == kCVPixelFormatType_32ARGB)
        
        let inputImageRowBytes = CVPixelBufferGetBytesPerRow(self)
        let imageChannels = 4
        
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        
        // Finds the biggest square in the pixel buffer and advances rows based on it.
        guard let inputBaseAddress = CVPixelBufferGetBaseAddress(self) else {
            return nil
        }
        
        // Gets vImage Buffer from input image
        var inputVImageBuffer = vImage_Buffer(data: inputBaseAddress, height: UInt(imageHeight), width: UInt(imageWidth), rowBytes: inputImageRowBytes)
        
        let scaledImageRowBytes = Int(size.width) * imageChannels
        guard  let scaledImageBytes = malloc(Int(size.height) * scaledImageRowBytes) else {
            return nil
        }
        
        // Allocates a vImage buffer for scaled image.
        var scaledVImageBuffer = vImage_Buffer(data: scaledImageBytes, height: UInt(size.height), width: UInt(size.width), rowBytes: scaledImageRowBytes)
        
        // Performs the scale operation on input image buffer and stores it in scaled image buffer.
        let scaleError = vImageScale_ARGB8888(&inputVImageBuffer, &scaledVImageBuffer, nil, vImage_Flags(0))
        
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        
        guard scaleError == kvImageNoError else {
            return nil
        }
        
        let releaseCallBack: CVPixelBufferReleaseBytesCallback = {mutablePointer, pointer in
            
            if let pointer = pointer {
                free(UnsafeMutableRawPointer(mutating: pointer))
            }
        }
        
        var scaledPixelBuffer: CVPixelBuffer?
        
        // Converts the scaled vImage buffer to CVPixelBuffer
        let conversionStatus = CVPixelBufferCreateWithBytes(nil, Int(size.width), Int(size.height), pixelBufferType, scaledImageBytes, scaledImageRowBytes, releaseCallBack, nil, nil, &scaledPixelBuffer)
        
        guard conversionStatus == kCVReturnSuccess else {
            
            free(scaledImageBytes)
            return nil
        }
        
        return scaledPixelBuffer
    }
    
}

extension UIColor {
    
    /**
     This method returns colors modified by percentage value of color represented by the current object.
     */
    func getModified(byPercentage percent: CGFloat) -> UIColor? {
        
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        // Returns the color comprised by percentage r g b values of the original color.
        let colorToReturn = UIColor(displayP3Red: min(red + percent / 100.0, 1.0), green: min(green + percent / 100.0, 1.0), blue: min(blue + percent / 100.0, 1.0), alpha: 1.0)
        
        return colorToReturn
    }
}



extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        return self
    }
    
    static func getImageResource(imageName: String) -> UIImage? {
        let podBundle = Bundle(for: PerfittPartners.self)
        guard let bundleURL = podBundle.url(forResource: "PerfittPartners_iOS", withExtension: "bundle") else {
            debugPrint("pod bundle failed")
            return nil
        }
        guard let bundle = Bundle(url: bundleURL) else {
            debugPrint("create bundle failed")
            return nil
        }
        
        return UIImage(named: imageName, in: bundle, compatibleWith: nil)
    }
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}


class CustomPickerView: UIPickerView {
    @IBInspectable var selectorColor: UIColor? = nil
    @IBInspectable var selectorWidth: CGFloat = 1
    @IBInspectable var font: UIFont? = nil
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        if let color = selectorColor {
            if subview.bounds.height <= 1.0 {
                subview.backgroundColor = color
            }
        }
        if subview.bounds.height <= 1.0 {
            subview.bounds.size.height = selectorWidth
            subview.bounds.size.width = 100
        }
    }
}
extension UIViewController {
    static func initViewController<T: UIViewController>(viewControllerClass: T.Type) -> T{
        
        let podBundle = Bundle(for: PerfittPartners.self)
        if let bundleURL = podBundle.url(forResource: "PerfittPartners_iOS", withExtension: "bundle") {
            if let bundle = Bundle(url: bundleURL) {
                let nib = UINib(nibName: "\(T.self)", bundle: bundle)
                let vc = nib.instantiate(withOwner: nil, options: nil)
                if let callViewController = vc.filter( { $0 is T } ).first as? T {
                    return callViewController
                }
            }
        }
        
        return UIViewController() as! T
    }
}


extension UIFont {

    public static func jbs_registerFont(withFilenameString filenameString: String, bundle: Bundle) {

        guard let pathForResourceString = bundle.path(forResource: filenameString, ofType: nil) else {
            print("UIFont+:  Failed to register font - path for resource not found.")
            return
        }

        guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
            print("UIFont+:  Failed to register font - font data could not be loaded.")
            return
        }

        guard let dataProvider = CGDataProvider(data: fontData) else {
            print("UIFont+:  Failed to register font - data provider could not be loaded.")
            return
        }

        guard let font = CGFont(dataProvider) else {
            print("UIFont+:  Failed to register font - font could not be loaded.")
            return
        }

        var errorRef: Unmanaged<CFError>? = nil
        if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == false) {
            print("UIFont+:  Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }

}
