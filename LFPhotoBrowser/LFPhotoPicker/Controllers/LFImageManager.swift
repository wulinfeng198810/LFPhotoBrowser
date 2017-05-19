//
//  LFImageManager.swift
//  LFPhotoBrowser
//
//  Created by Leo on 16/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

private let LFScreenWidth:CGFloat = UIScreen.main.bounds.width

// 测试发现，如果scale在plus真机上取到3.0，内存会增大特别多。故这里写死成2.0
private let LFScreenScale:CGFloat = LFScreenWidth > 700 ? 1.5 : 2.0

class LFImageManager: NSObject {
    
    static let manager: LFImageManager = LFImageManager()
    
    var shouldFixOrientation:Bool = false
    
    /// Default is 600px / 默认600像素宽
    var photoPreviewMaxWidth:CGFloat = 600
    
    /// Default is 4, Use in photos collectionView in TZPhotoPickerController
    /// 默认4列, TZPhotoPickerController中的照片collectionView
    var columnNumber:Int = 3
    
    /// Sort photos ascending by modificationDate，Default is YES
    /// 对照片排序，按修改时间升序，默认是YES。如果设置为NO,最新的照片会显示在最前面，内部的拍照按钮会排在第一个
    var sortAscendingByModificationDate:Bool = true
    
    /// Minimum selectable photo width, Default is 0
    /// 最小可选中的图片宽度，默认是0，小于这个宽度的图片不可选中
    var minPhotoWidthSelectable:Int = 0
    var minPhotoHeightSelectable:Int = 0
    var hideWhenCanNotSelect:Bool = true
    
    var AssetGridThumbnailSize:CGSize? {
        let itemWH:CGFloat = (LFScreenWidth - CGFloat(columnNumber - 1) * kGridMargin) / CGFloat(columnNumber)
        
        //return CGSize(width: itemWH * LFScreenScale, height: itemWH * LFScreenScale)
        return CGSize(width: itemWH * LFScreenScale, height: itemWH * LFScreenScale)
    }
    
    /// author
    func authorizationStatusAuthorized() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            requestAuthorizationWhenNotDetermined()
        }
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    private func requestAuthorizationWhenNotDetermined() {
        DispatchQueue.global().async { 
            PHPhotoLibrary.requestAuthorization({ (status:PHAuthorizationStatus) in
                
            })
        }
    }
    
    // MARK: - get album
    
    /// Get Album 获得 Camera Roll 相册组
    func getCameraRollAlbum(allowPickingVideo:Bool, allowPickingImage:Bool, completeHandler:(_ model:LFAlbumModel)->()) {
        
        let option = PHFetchOptions()
        
        if !allowPickingVideo {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        
        if !allowPickingImage {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        }

        if (!self.sortAscendingByModificationDate) {
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: self.sortAscendingByModificationDate)
            option.sortDescriptors = [sortDescriptor]
        }
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        
        for i in 0..<smartAlbums.count {
            let collection = smartAlbums[i]
            if !collection.isKind(of: PHAssetCollection.self) {
                continue
            }
            if isCameraRollAlbum(albumName: collection.localizedTitle ?? "") {
                let fetchResult = PHAsset.fetchAssets(in: collection, options: option)
                let model = modelWithResult(result: fetchResult,
                                            name: collection.localizedTitle ?? "")
                completeHandler(model)
                break
            }
        }
    }
    
    func getAllAlbums(allowPickingVideo:Bool, allowPickingImage:Bool, completeHandler:(_ albums:Array<LFAlbumModel>)->()) {
        
        let option = PHFetchOptions()
        
        if !allowPickingVideo {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
        }
        
        if !allowPickingImage {
            option.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
        }
        
        if (!self.sortAscendingByModificationDate) {
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: self.sortAscendingByModificationDate)
            option.sortDescriptors = [sortDescriptor]
        }
        
        let myPhotoStreamAlbum = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumMyPhotoStream, options: nil)
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        let topLevelUserCollections = PHAssetCollection.fetchTopLevelUserCollections(with: nil)
        let syncedAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumSyncedAlbum, options: nil)
        let sharedAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumCloudShared, options: nil)
        
        let allAlbums = [myPhotoStreamAlbum,
                         smartAlbums,
                         topLevelUserCollections,
                         syncedAlbums,
                         sharedAlbums] as! [PHFetchResult<PHAssetCollection>]
        
        var albumArr = Array<LFAlbumModel>()
        
        for fetch in allAlbums {
            
            for i in 0..<fetch.count {
                
                let collection = fetch[i]
                
                if !collection.isKind(of: PHAssetCollection.self) {
                    continue
                }
                
                guard let locTitle = collection.localizedTitle else {
                    continue
                }
                
                
                if locTitle.contains("Deleted")
                    || locTitle.contains("最近删除") {
                    continue
                }
                
                if isCameraRollAlbum(albumName: locTitle) {
                    let fetchResult = PHAsset.fetchAssets(in: collection, options: option)
                    let album = modelWithResult(result: fetchResult, name: locTitle)
                    if album.count < 1 {continue}
                    albumArr.insert(album, at:0)
                } else {
                    let fetchResult = PHAsset.fetchAssets(in: collection, options: option)
                    
                    let album = modelWithResult(result: fetchResult, name: locTitle)
                    if album.count < 1 {continue}
                    albumArr.append(album)
                }
            }
        }
        
        completeHandler(albumArr)
    }
    
    
}


// MARK: - Export video
extension LFImageManager {

    fileprivate func isCameraRollAlbum(albumName:String) -> Bool{
        
        // 目前已知8.0.0 - 8.0.2系统，拍照后的图片会保存在最近添加中
        var versionStr:String = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "")
        let vLength = (versionStr as NSString).length
        if vLength <= 1 {
            versionStr.append("00")
        } else if vLength <= 2 {
            versionStr.append("0")
        }
        
        let version = (versionStr as NSString).floatValue
        if version >= 800 && version <= 802 {
            return (albumName == "最近添加")
                || (albumName == "Recently Added")
        }
        else {
            return (albumName == "Camera Roll")
                || (albumName == "相机胶卷")
                || (albumName == "All Photos")
                || (albumName == "所有照片")
        }
    }
    
    func getAssetIdentifier(asset:PHAsset) -> String {
        return asset.localIdentifier;
    }
    
    fileprivate func modelWithResult(result:PHFetchResult<PHAsset>, name:String) -> LFAlbumModel {
        return LFAlbumModel(name: name, result: result)
    }
}

// MARK: - Get Assets 获得照片数组
extension LFImageManager {
    
    func getAssetsFromFetchResult(result:PHFetchResult<PHAsset>, allowPickingVideo:Bool, allowPickingImage:Bool, completeHandler:(_ assetModels:Array<LFAssetModel>)->() ) {
        
        var array = Array<LFAssetModel>()
        
        result.enumerateObjects({ (asset, index, _) in
            
            let assetModdel = self.assetModelWithAsset(asset: asset,
                                                       allowPickingVideo: allowPickingVideo,
                                                       allowPickingImage: allowPickingImage)
            if let assetModdel = assetModdel {
                array.append(assetModdel)
            }
        })
        
        completeHandler(array)
    }
    
    func assetModelWithAsset(asset:PHAsset, allowPickingVideo:Bool, allowPickingImage:Bool) -> LFAssetModel? {
        
        var type:LFAssetModelMediaType = .photo
        
        if asset.mediaType == .audio {
            type = .audio
        }
        else if asset.mediaType == .video {
            type = .video
        }
        else if asset.mediaType == .image {
            
            if let filename = asset.value(forKey: "filename") as? String {
                if filename.hasSuffix(".GIF") || filename.hasSuffix(".gif") {
                    type = .photoGIF
                }
            }
        }
        
        if !allowPickingVideo && type == .video {
            return nil
        }
        if !allowPickingImage && type == .photo {
            return nil
        }
        if !allowPickingImage && type == .photoGIF {
            return nil
        }
        
        // TODO: - hideWhenCanNotSelect
        
        
        // let timeLength = type == .video ? String(format:"%0.0f",asset.duration) : ""
        // TODO: - timeLength
        return LFAssetModel(asset: asset,
                            type: type,
                            timeLength: "0")
    }
    
}

// MARK: - Get photo
extension LFImageManager {
    
    func getPreviewPhotoWith(asset:PHAsset,
                             networkAccessAllowed:Bool? = true, completion:((_ photo:UIImage?, _ info:[AnyHashable : Any]?, _ isDegraded:Bool)->())?) -> PHImageRequestID {
        
        var fullScreenWidth:CGFloat = LFScreenWidth;
        if fullScreenWidth > photoPreviewMaxWidth {
            fullScreenWidth = photoPreviewMaxWidth
        }
        return getPhotoWithAsset(asset: asset, photoWidth: fullScreenWidth, networkAccessAllowed: networkAccessAllowed, completion: completion)
    }
    
    func getPhotoWithAsset(asset:PHAsset,
                           photoWidth:CGFloat,
                           networkAccessAllowed:Bool? = true, completion:((_ photo:UIImage?, _ info:[AnyHashable : Any]?, _ isDegraded:Bool)->())?) -> PHImageRequestID {
        
        var imageSize:CGSize = CGSize.zero
        if photoWidth < LFScreenWidth && photoWidth < photoPreviewMaxWidth {
            imageSize = AssetGridThumbnailSize!
        } else {
            let aspectRatio =  CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
            let pixelWidth = photoWidth * LFScreenScale;
            let pixelHeight = pixelWidth / aspectRatio;
            imageSize = CGSize(width:pixelWidth, height:pixelHeight)
        }
        let option = PHImageRequestOptions()
        option.resizeMode = .fast
        return PHImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: option) { (result:UIImage?, info:[AnyHashable : Any]?) in
            
            if let ret = result {
                let fixResult = ret.fixOrientation()
                completion?(fixResult, info, false)
            }
            else
            {
                completion?(result, info, true)
            }
        }
    }
}

// MARK: - Get postImage / 获取封面图
extension LFImageManager {
    
    func getPostImageWithAlbumModel(albumModel:LFAlbumModel, completeHandler:@escaping (_ image:UIImage?)->()) {
        
        var asset = albumModel.result.lastObject
        if !self.sortAscendingByModificationDate {
            asset = albumModel.result.firstObject
        }
        guard let ast = asset else {
            completeHandler(nil)
            return
        }
        
        _ = LFImageManager.manager.getPhotoWithAsset(asset: ast, photoWidth: 80) { (img, _, _) in
            completeHandler(img)
        }
    }
}
