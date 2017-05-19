//
//  LFPhotoPickerController.swift
//  LFPhotoBrowser
//
//  Created by Leo on 15/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit

private let kLFAssetCell = "LFAssetCell"

/// grid thumbnail photo
/// 缩略图
class LFPhotoPickerController: UIViewController {

    var isFirstAppear:Bool = true
    var columnNumber:Int = LFImageManager.manager.columnNumber
    var albumModel:LFAlbumModel?
    
    var modelArray:Array<LFAssetModel>?
    
    var collectionView:UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = albumModel?.name
        let imagePickerNAV = navigationController as! LFImagePickerNavgationController
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: imagePickerNAV.cancelBtnTitleStr,
                            style: .plain,
                            target: imagePickerNAV,
                            action: #selector(imagePickerNAV.cancelButtonClick))
        
        initSubviews()
        
        reloadDatas()
    }
    
    private func initSubviews() {
        configCollectionView()
    }
    
    private func configCollectionView() {
        let flow = UICollectionViewFlowLayout()
        
        let columnNumber = LFImageManager.manager.columnNumber
        let itemWH:CGFloat = (UIScreen.main.bounds.width - CGFloat(columnNumber - 1) * kGridMargin) / CGFloat(columnNumber)
        flow.itemSize = CGSize(width: itemWH, height: itemWH)
        flow.minimumLineSpacing = kGridMargin
        flow.minimumInteritemSpacing = kGridMargin
        flow.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        collectionView = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: flow)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.dataSource = self
        collectionView?.delegate = self
        //collectionView?.alwaysBounceHorizontal = false
        collectionView?.register(LFAssetCell.self, forCellWithReuseIdentifier: kLFAssetCell)
        view.addSubview(collectionView!)
    }
    
    private func reloadDatas() {
        
        let imagePickerNAV = navigationController as! LFImagePickerNavgationController
        guard let result = albumModel?.result else {
            return
        }
        
        LFImageManager.manager.getAssetsFromFetchResult(result: result, allowPickingVideo: imagePickerNAV.allowPickingVideo, allowPickingImage: imagePickerNAV.allowPickingImage) { (assets:Array<LFAssetModel>) in
            
            modelArray = assets
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }

}


extension LFPhotoPickerController:UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return modelArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kLFAssetCell, for: indexPath) as? LFAssetCell,
        let asset = albumModel?.result[indexPath.row] else {
            return UICollectionViewCell()
        }
        
        cell.model = modelArray?[indexPath.row]
        cell.backgroundColor = UIColor.lightGray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoPreviewVC = LFPhotoPreviewController()
        photoPreviewVC.currentIndex = indexPath.row
        photoPreviewVC.albumModel = albumModel
        navigationController?.pushViewController(photoPreviewVC, animated: true)
    }
    
}
