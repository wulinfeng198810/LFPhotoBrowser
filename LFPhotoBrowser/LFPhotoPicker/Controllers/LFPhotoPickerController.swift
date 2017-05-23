//
//  LFPhotoPickerController.swift
//  LFPhotoBrowser
//
//  Created by Leo on 15/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit
import AVFoundation

private let kLFAssetCell = "LFAssetCell"
private let kLFCameraCell = "LFCameraCell"

/// grid thumbnail photo
/// 缩略图
class LFPhotoPickerController: UIViewController {

    var isFirstAppear:Bool = true
    var columnNumber:Int = LFImageManager.manager.columnNumber
    var albumModel:LFAlbumModel?
    
    var modelArray:Array<LFAssetModel>?
    
    var collectionView:UICollectionView?
    
    var _shouldScrollToBottom:Bool = false
    var _showTakePhotoBtn:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.title = albumModel?.name
        let imagePickerNAV = navigationController as! LFImagePickerNavgationController
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: imagePickerNAV.cancelBtnTitleStr,
                            style: .plain,
                            target: imagePickerNAV,
                            action: #selector(imagePickerNAV.cancelButtonClick))
        
        _showTakePhotoBtn = LFImageManager.manager.isCameraRollAlbum(albumName: albumModel?.name) && imagePickerNAV.allowTakePicture
        
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
        collectionView?.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.dataSource = self
        collectionView?.delegate = self
        //collectionView?.alwaysBounceHorizontal = false
        collectionView?.register(LFAssetCell.self, forCellWithReuseIdentifier: kLFAssetCell)
        collectionView?.register(LFCameraCell.self, forCellWithReuseIdentifier: kLFCameraCell)
        view.addSubview(collectionView!)
    }
    
    fileprivate func reloadDatas() {
        
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
    
    
    /// reload 'Camera Roll Album' datas after take photo
    /// 拍照之后刷新数据
    fileprivate func reloadCameraRollAlbumDatas() {
    
        let imagePickerNAV = self.navigationController as! LFImagePickerNavgationController
        
        LFImageManager.manager.getCameraRollAlbum(allowPickingVideo: imagePickerNAV.allowPickingVideo, allowPickingImage: imagePickerNAV.allowPickingImage) { (albumModel) in
            
            self.albumModel = albumModel
            
            LFImageManager.manager.getAssetsFromFetchResult(result: albumModel.result, allowPickingVideo: imagePickerNAV.allowPickingVideo, allowPickingImage: imagePickerNAV.allowPickingImage) { (assets:Array<LFAssetModel>) in
                
                modelArray = assets
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        }
    
    }

    // call system camera
    func camera() {
        
        func cameraAction() {
            let sysCameraVC = UIImagePickerController()
            
            sysCameraVC.navigationBar.barTintColor = self.navigationController?.navigationBar.barTintColor
            sysCameraVC.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor
            sysCameraVC.sourceType = .camera
            sysCameraVC.cameraDevice = .rear
            sysCameraVC.delegate = self
            self.present(sysCameraVC, animated: true, completion: nil)
        }
        
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if authStatus == .authorized {
            cameraAction()
        } else if authStatus == .notDetermined {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { (success:Bool) in
                if success {
                    cameraAction()
                }
            }
        } else {
            let appName = Bundle.appName()
            let msg = String.init(format: "Please allow %@ to access your camera in \"Settings -> Privacy -> Camera\"", appName)
            let alert = UIAlertController(title: "Can not use camera", message: msg, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: Bundle.lf_localizedString(forKey: "Cancel"),
                                             style: .cancel,
                                             handler: nil)
            let settingAction = UIAlertAction(title: Bundle.lf_localizedString(forKey: "Setting"), style: .default) { (_) in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }
            
            alert.addAction(cancelAction)
            alert.addAction(settingAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}


extension LFPhotoPickerController:UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if (_showTakePhotoBtn) {
            let imagePickerNAV = navigationController as! LFImagePickerNavgationController
            if (imagePickerNAV.allowPickingImage && imagePickerNAV.allowTakePicture) {
                return (modelArray?.count ?? 0) + 1
            }
        }
        
        return modelArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let mCount = modelArray?.count else {
            return UICollectionViewCell()
        }
        
        // camera cell
        let imagePickerNAV = self.navigationController as! LFImagePickerNavgationController
        
        if ((imagePickerNAV.sortAscendingByModificationDate && indexPath.row >= mCount) ||
            (!imagePickerNAV.sortAscendingByModificationDate && indexPath.row == 0) && _showTakePhotoBtn) {
            return collectionView.dequeueReusableCell(withReuseIdentifier: kLFCameraCell, for: indexPath) as! LFCameraCell
        }
        
        // asset cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kLFAssetCell, for: indexPath) as! LFAssetCell
        
        cell.backgroundColor = UIColor.lightGray
        
        if (imagePickerNAV.sortAscendingByModificationDate || !_showTakePhotoBtn) {
            cell.model = modelArray?[indexPath.row]
        } else {
            cell.model = modelArray?[indexPath.row - 1]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let mCount = modelArray?.count else {
            return
        }
        
        // take a photo / 去拍照
        let imagePickerNAV = self.navigationController as! LFImagePickerNavgationController
        
        if ((imagePickerNAV.sortAscendingByModificationDate && indexPath.row >= mCount) ||
            (!imagePickerNAV.sortAscendingByModificationDate && indexPath.row == 0)  && _showTakePhotoBtn) {
            camera()
            return
        }
        
        // preview phote or video / 预览照片或视频
        var index = indexPath.row;
        if (!imagePickerNAV.sortAscendingByModificationDate && _showTakePhotoBtn) {
            index = indexPath.row - 1;
        }
        
        let photoPreviewVC = LFPhotoPreviewController()
        photoPreviewVC.currentIndex = index
        photoPreviewVC.albumModel = albumModel
        navigationController?.pushViewController(photoPreviewVC, animated: true)
    }
    
}

extension LFPhotoPickerController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let type = info[UIImagePickerControllerMediaType] as? NSString,
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        if type.isEqual(to: "public.image") {
            
            LFImageManager.manager.savePhoto(withImage: image, completeHandler: { (success, error) in
                if success {
                    self.reloadCameraRollAlbumDatas()
                } else {
                    assert(false, "cannot save images")
                }
            })
        }
    }
    
}
