//
//  RGBPixelMaker.swift
//  Just
//
//  Created by dely on 2018. 5. 24..
//  Copyright © 2018년 dely. All rights reserved.
//

import UIKit

class RGBPixelMaker {
    var size: CGSize = CGSize(width: 0, height: 0)
    func makeBinaryPixel(image: UIImage) -> [RGBData] {
        var imageOfRGBData: [RGBData] = []
        size = CGSize(width: image.size.width, height: image.size.height)
        let pixelData = image.cgImage?.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        // from image to pixel 
        for x in 0..<Int(size.width) {
            for y in 0..<Int(size.height) {
                let position = CGPoint(x: x, y: y)
                let pixelInfo: Int = ((Int(x) * Int(position.y)) + Int(position.x)) * 4
                
                let r = UInt8(CGFloat(data[pixelInfo]))
                let g = UInt8(CGFloat(data[pixelInfo+1]))
                let b = UInt8(CGFloat(data[pixelInfo+2]))
                let a = UInt8(CGFloat(data[pixelInfo+3]))
                imageOfRGBData.append(RGBData.init(r: r, g: g, b: b, a: a))
                if x == 0 && y == 0 {
                    print("r: \(printByFormat(r)), g: \(printByFormat(g)), b: \(printByFormat(b)), a: \(printByFormat(a))")
                }
            }
        }
        return imageOfRGBData
    }
    
    func printByFormat(_ value: UInt8) -> String {
        var binaryValue = String(value, radix: 2)
        return binaryValue.pad()
    }
    
    func makebitMixing(imageA: [RGBData], imageB: [RGBData], bit: Int) -> [RGBData] {
        // 두 이미지 중 작은 값을 기준으로
        var imageOfMixing: [RGBData] = []
        let bitMask: UInt8 = 255
        
        for index in 0..<imageA.count {
            let shiftBitMask = bitMask << bit
            let imageAMasked = imageA[index].r & shiftBitMask
            let imageBShifted = imageB[index].r >> (8 - bit)
            
            let tmp = imageA[index].r & bitMask << bit | imageB[index].r >> (8 - bit)
            let resultR = imageA[index].r & bitMask << bit | imageB[index].r >> (8 - bit)
            let resultG = imageA[index].g & bitMask << bit | imageB[index].g >> (8 - bit)
            let resultB = imageA[index].b & bitMask << bit | imageB[index].b >> (8 - bit)
            let resultA = imageA[index].a
            imageOfMixing.append(RGBData.init(r: resultR, g: resultG, b: resultB, a: resultA))
            if index == 0 {
                print("imageBShifted: \(imageBShifted)")
                print("shiftBitMask: \(printByFormat(shiftBitMask)), imageAMasked: \(printByFormat(imageAMasked)), imageBShifted: \(printByFormat(imageBShifted))")
                print("tmp: \(printByFormat(tmp)), r: \(printByFormat(resultR)), g: \(printByFormat(resultG)), b: \(printByFormat(resultB)), a: \(printByFormat(resultA))")
            }
        }
        return imageOfMixing
    }
    
    func makeMixingImage(rgbData: [RGBData], coverImage: UIImage) -> UIImage {
        let cgImage: CGImage?
        let width = Int(size.width)
        let height = Int(size.height)
        let bitsPerComponent = 32
        let bytesPerRow = width * bitsPerComponent
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let pixelsOfMixingImage = makeRGBAPixel(rgbData: rgbData)
        let data: UnsafeMutableRawPointer = UnsafeMutableRawPointer(mutating: pixelsOfMixingImage)
        
        guard let bitmapContext = CGContext(data: data,
                                            width: width,
                                            height: height,
                                            bitsPerComponent: Int(bitsPerComponent),
                                            bytesPerRow: Int(bytesPerRow),
                                            space: colorSpace,
                                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return coverImage
        }
        guard let image = bitmapContext.makeImage() else {
            return coverImage
        }
        cgImage = image
        
        return UIImage(cgImage: cgImage!)
    }
    
    func makeRGBAPixel(rgbData: [RGBData]) -> [UInt32] {
        var pixelsOfMixingImage: [UInt32] = []
        for data in rgbData {
            let mixingImage: UInt32 = UInt32(UInt32(data.r)<<24 | UInt32(data.g)<<16 | UInt32(data.b)<<8 | UInt32(data.a))
            pixelsOfMixingImage.append(mixingImage)
        }
        return pixelsOfMixingImage
    }
}

extension String {
    mutating func pad() -> String {
        let size = 8 - self.count
        var padding = ""
        for _ in 0..<size {
            padding += "0"
        }
        self = padding + self
        return self
    }
}
