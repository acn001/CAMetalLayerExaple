//
//  ViewController.swift
//  EDRExample
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var targetView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let path = Bundle.main.path(forResource: "GrayRampsHorizontal", ofType: "exr") else { return }
        let image = UIImage(contentsOfFile: path)
        guard let cgImage = image?.cgImage else { return }
        
        let metalLayer = CAMetalLayer()
        metalLayer.wantsExtendedDynamicRangeContent = true
        metalLayer.pixelFormat = MTLPixelFormat.rgba16Float
        targetView.layer.addSublayer(metalLayer)
        
        guard let colorspace = CGColorSpace(name: CGColorSpace.extendedDisplayP3) else { return }
        metalLayer.colorspace = colorspace
        
        let width = cgImage.width
        let height = cgImage.height
        let info = CGBitmapInfo(rawValue: kCGBitmapByteOrder16Host.rawValue |
                                CGImageAlphaInfo.premultipliedLast.rawValue |
                                CGBitmapInfo.floatComponents.rawValue)
        
        guard let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 16, bytesPerRow: 0, space:colorspace , bitmapInfo: info.rawValue) else { return }
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        
        let desc = MTLTextureDescriptor()
        desc.pixelFormat = .rgba16Float
        desc.textureType = .type2D
        
        guard let texture = metalLayer.device?.makeTexture(descriptor: desc) else { return }
        guard var data = ctx.data else { return }
        texture.replace(region: MTLRegionMake2D(0, 0, width, height),
                        mipmapLevel: 0,
                        withBytes: &data,
                        bytesPerRow: ctx.bytesPerRow)
    }
}
