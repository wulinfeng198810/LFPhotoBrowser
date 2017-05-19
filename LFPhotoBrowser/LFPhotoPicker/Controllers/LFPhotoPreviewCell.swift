//
//  LFPhotoPreviewCell.swift
//  LFPhotoBrowser
//
//  Created by Leo on 19/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit

class LFPhotoPreviewCell: UICollectionViewCell {
    
    var assetModel:LFAssetModel?
    {
        didSet {
            setModel()
        }
    }
    
    var previewView:LFPhotoPreviewView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        previewView = LFPhotoPreviewView(frame: (UIApplication.shared.keyWindow?.frame)!)
        contentView.addSubview(previewView!)
    }
    
    func setModel() {
        previewView?.assetModel = assetModel
    }
}
