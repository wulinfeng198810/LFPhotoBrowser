//
//  LFAssetCell.swift
//  LFPhotoBrowser
//
//  Created by Leo on 17/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit
import Photos

enum LFAssetCellType:Int {
    case photo
    case livePhoto
    case photoGIF
    case video
    case audio
}

class LFAssetCell: UICollectionViewCell {
    
    var selectPhotoButton:UIButton?
    
    var didSelectPhotoBlock:((_ select:Bool)->())?
    var type:LFAssetCellType?
    var allowPickingGIF:Bool?
    
    var representedAssetIdentifier:String?
    var imageRequestID:PHImageRequestID?
    var photoSelImageName:String?
    var photoDefImageName:String?
    
    var showSelectBtn:Bool?
    
    var imageView:UIImageView?
    
    var model: LFAssetModel? {
        didSet {
            reloadCell()
        }
    }
    
    
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
        imageView = UIImageView(frame: self.bounds)
        imageView?.contentMode = .scaleAspectFill
        imageView?.clipsToBounds = true
        addSubview(imageView!)
    }
    
    
    
    func reloadCell() {
        
        guard let asset = self.model?.asset else {
            return
        }
        
        self.representedAssetIdentifier = LFImageManager.manager.getAssetIdentifier(asset: asset)
        
        print(self.representedAssetIdentifier!)
        
        let imgReqID = LFImageManager.manager.getPhotoWithAsset(asset: asset, photoWidth: self.bounds.size.width ){ (photo, _, isDegraded:Bool) in
            
            guard let representedAssetIdentifier = self.representedAssetIdentifier else {
                return
            }
            
            if representedAssetIdentifier == LFImageManager.manager.getAssetIdentifier(asset: asset) {
                self.imageView?.image = photo
            } else {
                PHImageManager.default().cancelImageRequest(self.imageRequestID!)
            }
            
            if (!isDegraded) {
                self.imageRequestID = 0;
            }
        }
        
        if let imageRequestID = self.imageRequestID {
            if imageRequestID != 0 && imgReqID != imageRequestID {
                PHImageManager.default().cancelImageRequest(imageRequestID)
            }
        }
        self.imageRequestID = imgReqID
    }
    
}

class LFCameraCell: UICollectionViewCell {
    
    lazy var imageView = UIImageView()
    
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
        backgroundColor = UIColor.white
        clipsToBounds = true
        
        imageView.frame = self.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.image = Bundle.lf_image(named: "takePicture@2x.png")
        addSubview(imageView)
    }
}

class LFAlbumCell: UITableViewCell {
    
    var albumModel:LFAlbumModel? {
        didSet {
            setModel()
        }
    }

    lazy var posterImageView:UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        return imgView
    }()
    
//    lazy var arrowImageView:UIImageView = {
//        let imgView = UIImageView()
//        imgView.clipsToBounds = true
//        imgView.image = Bundle.lf_image(named: "TableViewArrow@2x.png")
//        
//        let arrowWH:CGFloat = 15
//        imgView.frame = CGRect(x: self.lf_width() - arrowWH - 12,
//                               y: 0,
//                               width: arrowWH,
//                               height: arrowWH)
//        
//        imgView.center.y = self.contentView.center.y
//        
//        return imgView
//    }()
    
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.frame = CGRect(x: 80, y: 0, width: self.lf_width() - 80 - 50, height: self.lf_height())
        label.textColor = UIColor.black
        label.textAlignment = .left
        return label
    }()
        
    lazy var selectedCountButton:UIButton = {
        let btn = UIButton()
        return btn
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
    }
    
    private func setupSubviews() {
        contentView.addSubview(posterImageView)
//        contentView.addSubview(arrowImageView)
        contentView.addSubview(titleLabel)
    }
    
    private func setModel() {
        
        let _nameString = NSMutableAttributedString.init(
            string: albumModel?.name ?? "",
            attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 16),
                         NSForegroundColorAttributeName:UIColor.black])
        
        let _count = NSString.init(format: "  (%zd)", albumModel?.count ?? 0)
        let countString = NSAttributedString.init(
            string: _count as String,
            attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 16),
                         NSForegroundColorAttributeName:UIColor.lightGray])
        _nameString.append(countString)
        titleLabel.attributedText = _nameString
        
        if let model = albumModel {
            LFImageManager.manager.getPostImageWithAlbumModel(albumModel: model, completeHandler: { (img) in
                self.posterImageView.image = img
            })
        }
    }
}
