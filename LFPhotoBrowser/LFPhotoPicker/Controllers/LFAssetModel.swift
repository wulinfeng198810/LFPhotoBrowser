//
//  LFAssetModel.swift
//  LFPhotoBrowser
//
//  Created by Leo on 16/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit
import Photos

enum LFAssetModelMediaType:Int {
    case photo
    case livePhoto
    case photoGIF
    case video
    case audio
}

class LFAssetModel: NSObject {
    var asset: PHAsset              ///< PHAsset or ALAsset
    var isSelected: Bool = false    ///< The select status of a photo, default is No
    var type: LFAssetModelMediaType = .photo
    var timeLength: String?
    
    init(asset:PHAsset, type:LFAssetModelMediaType = .photo, timeLength:String? = nil) {
        
        self.asset = asset
        self.isSelected = false
        self.type = type
        self.timeLength = timeLength
        
        super.init()
    }
    
    /*
    class func modelWithAsset(asset:PHAsset, type:LFAssetModelMediaType, timeLength:String) -> LFAssetModel {
        let model = LFAssetModel()
        model.asset = asset
        model.isSelected = false
        model.type = type
        model.timeLength = timeLength
        return model;
    }
     */
}

class LFAlbumModel: NSObject {
    var name: String       ///< The album name
    var result: PHFetchResult<PHAsset>
    
    var count:Int = 0       ///< Count of photos the album contain
    
    var models: Array<LFAssetModel>? 
    
    var selectedCount:Int = 0
    
    init(name:String, result:PHFetchResult<PHAsset>) {
        
        self.name = name
        self.result = result
        
        super.init()
        
        LFImageManager.manager.getAssetsFromFetchResult(result: result, allowPickingVideo: false, allowPickingImage: true) { (array:Array<LFAssetModel>) in
            models = array
            count = models?.count ?? 0 
            self.checkSelectedModels()
        }
    }
    /*
    var result: PHFetchResult<PHAsset>?  ///< PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>
    {
        didSet {
            LFImageManager.manager.getAssetsFromFetchResult(result: result!, allowPickingVideo: false, allowPickingImage: true) { (array:Array<LFAssetModel>) in
                models = array
            }
        }
    }
 */
    
    var selectedModels: Array<LFAssetModel>?
    {
        didSet {
            checkSelectedModels()
        }
    }
    
    fileprivate func checkSelectedModels() {
        selectedCount = 0
        var selectedAssets = Array<PHAsset>()
        
        // TODO: - 需简化
        if let selectedModels = selectedModels {
            for model in selectedModels {
                selectedAssets.append(model.asset)
            }
        }
        
        // TODO: - 需简化
        if let models = models {
            for model in models {
                if selectedAssets.contains(model.asset) {
                    selectedCount += 1
                }
            }
        }
    }
    
}
