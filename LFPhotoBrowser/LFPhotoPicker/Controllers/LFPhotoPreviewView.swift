//
//  LFPhotoPreviewView.swift
//  scroll
//
//  Created by Leo on 19/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit
import Photos

class LFPhotoPreviewView: UIView,UIScrollViewDelegate {

    var assetModel:LFAssetModel?
    {
        didSet {
            setModel()
        }
    }
    
    var representedAssetIdentifier:String?
    
    let scrollView = UIScrollView()
    
    let imgView = UIImageView()
    
    var imgShowSize = CGSize.zero
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        addSubview(scrollView)
        scrollView.frame = frame
        scrollView.isMultipleTouchEnabled = true
        scrollView.clipsToBounds = true
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.5
        scrollView.delegate = self
        
        scrollView.zoomScale = 1.0
        
        scrollView.addSubview(imgView)
        imgView.frame = scrollView.frame
        imgView.contentMode = .scaleAspectFit
        
        
        let singleTapGestrue = UITapGestureRecognizer(target: self,
                                                      action: #selector(singleTap))
        
        let doubleTapGestrue = UITapGestureRecognizer(target: self,
                                                      action: #selector(doubleTap))
        doubleTapGestrue.numberOfTapsRequired = 2
        
        singleTapGestrue.require(toFail: doubleTapGestrue)
        
        addGestureRecognizer(doubleTapGestrue)
        addGestureRecognizer(singleTapGestrue)
    }
    
    private func setModel() {
        imgView.image = nil
        scrollView.zoomScale = 1.0
        
        guard let asset = assetModel?.asset else {
            return
        }
        
        representedAssetIdentifier = LFImageManager.manager.getAssetIdentifier(asset: asset)
        
        guard let representedAssetIdentifier = representedAssetIdentifier else {
            return
        }
        
        _ = LFImageManager.manager.getPreviewPhotoWith(asset: asset, networkAccessAllowed: true, completion:
            { (photo, _, _) in
            
            if representedAssetIdentifier == LFImageManager.manager.getAssetIdentifier(asset: asset) {
                
                self.imgView.image = photo
                self.calculateImageShowSize()
            }
        })
    }

    /// calculate the image show-size
    private func calculateImageShowSize() {
        
        let scrollViewProportion = scrollView.bounds.size.width/scrollView.bounds.size.height
        var imgProportion:CGFloat = 0
        
        if let img = imgView.image {
            imgProportion = img.size.width/img.size.height
        }
        
        if imgProportion > scrollViewProportion {
            imgShowSize = CGSize(width: scrollView.bounds.width,
                                 height: scrollView.bounds.width/imgProportion)
        } else {
            imgShowSize = CGSize(width: scrollView.bounds.height * imgProportion,
                                 height: scrollView.bounds.height)
        }
        
        debugPrint("image show size:",
                   NSStringFromCGSize(imgShowSize))
    }
    
    deinit {
        guard let gestures = gestureRecognizers else {
            return
        }
        
        for ges in gestures {
            removeGestureRecognizer(ges)
        }
    }
    
    // MARK: - tap gesture
    
    func singleTap() {
        
    }
    
    func doubleTap() {
        if scrollView.zoomScale != 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            scrollView.setZoomScale(1.5, animated: true)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        // control the scroll, like: wide image / long image
        // 控制滚动，宽图／长图
        var conSize = CGSize(width: imgShowSize.width * scrollView.zoomScale,
                             height: imgShowSize.height * scrollView.zoomScale)
        
        if conSize.width < scrollView.bounds.size.width {
            conSize.width = scrollView.bounds.size.width
        }
        
        if conSize.height < scrollView.bounds.size.height {
            conSize.height = scrollView.bounds.size.height
        }
        
        scrollView.contentSize = conSize
        
        
        let offsetX = scrollView.zoomScale < 1 ?
            (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0
        
        let offsetY = scrollView.zoomScale < 1 ?
            (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0
        
        imgView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
                                 y: scrollView.contentSize.height * 0.5  + offsetY)
    }
    
}
