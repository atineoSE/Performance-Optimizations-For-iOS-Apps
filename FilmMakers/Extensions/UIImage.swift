import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func resized(longestSide: CGFloat) -> UIImage {
        let w = size.width
        let h = size.height
        let ratio = w/h
        
        let newSize: CGSize
        if w > h {
            newSize = CGSize(width: longestSide, height: longestSide / ratio)
        } else {
            newSize = CGSize(width: longestSide * ratio, height: longestSide)
        }
        return resized(to: newSize)
    }
    
    func resized(newHeight: CGFloat) -> UIImage {
        let w = size.width
        let h = size.height
        let ratio = w/h
        let newSize = CGSize(width: newHeight * ratio, height: newHeight)
        return resized(to: newSize)
    }
    
    func resized(newWidth: CGFloat) -> UIImage {
        let w = size.width
        let h = size.height
        let ratio = w/h
        let newSize = CGSize(width: newWidth, height: newWidth / ratio)
        return resized(to: newSize)
    }
    
    func resized(by ratio: CGFloat) -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        return UIImage(cgImage: cgImage, scale: 1/ratio, orientation: self.imageOrientation)
    }
}
