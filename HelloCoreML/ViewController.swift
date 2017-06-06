//
//  ViewController.swift
//  HelloCoreML
//
//  Created by 郭朋 on 06/06/2017.
//  Copyright © 2017 Peng Guo. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {

    @IBOutlet weak var result: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let model = Inceptionv3()
        let inputImage = UIImage(named: "sample.jpg")!.cgImage!
        
        let pixelBuffer = getCVPixelBuffer(inputImage)
        guard let pb = pixelBuffer, let output = try? model.prediction(image: pb) else {
            fatalError("Unexpected runtime error.")
        }
        
        //print(output.classLabelProbs)
        result.text = output.classLabel
    }
    
    // MARK: helper
    
    func getCVPixelBuffer(_ image: CGImage) -> CVPixelBuffer? {
        let imageWidth = Int(image.width)
        let imageHeight = Int(image.height)
        
        let attributes : [NSObject:AnyObject] = [
            kCVPixelBufferCGImageCompatibilityKey : true as AnyObject,
            kCVPixelBufferCGBitmapContextCompatibilityKey : true as AnyObject
        ]
        
        var pxbuffer: CVPixelBuffer? = nil
        CVPixelBufferCreate(kCFAllocatorDefault,
                            imageWidth,
                            imageHeight,
                            kCVPixelFormatType_32ARGB,
                            attributes as CFDictionary?,
                            &pxbuffer)
        
        if let _pxbuffer = pxbuffer {
            let flags = CVPixelBufferLockFlags(rawValue: 0)
            CVPixelBufferLockBaseAddress(_pxbuffer, flags)
            let pxdata = CVPixelBufferGetBaseAddress(_pxbuffer)
            
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
            let context = CGContext(data: pxdata,
                                    width: imageWidth,
                                    height: imageHeight,
                                    bitsPerComponent: 8,
                                    bytesPerRow: CVPixelBufferGetBytesPerRow(_pxbuffer),
                                    space: rgbColorSpace,
                                    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
            
            if let _context = context {
                _context.draw(image, in: CGRect.init(x: 0, y: 0, width: imageWidth, height: imageHeight))
            }
            else {
                CVPixelBufferUnlockBaseAddress(_pxbuffer, flags);
                return nil
            }
            
            CVPixelBufferUnlockBaseAddress(_pxbuffer, flags);
            return _pxbuffer;
        }
        
        return nil
    }


}

