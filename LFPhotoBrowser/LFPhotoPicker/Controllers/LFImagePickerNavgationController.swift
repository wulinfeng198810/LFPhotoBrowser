//
//  LFImagePickerNavgationController.swift
//  LFPhotoBrowser
//
//  Created by Leo on 18/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

/*
 
 Architecture:
 
 ||
 || LFImagePickerNavgationController
 ||
 || ~ LFAlbumController -> rootViewController
 ||     ---------
 ||     ---------
 ||     ---------
 ||
 || ===> LFPhotoPickerController
 ||     [] [] [] ...
 ||     [] [] [] ...
 ||     [] [] [] ...
 ||     ...
 ||
 
 */

import UIKit
import Photos


protocol LFImagePickerNavgationControllerDelegate {
    func imagePickerController(didFinishPickingPhotos photos:Array<UIImage>)
}

class LFImagePickerNavgationController: UINavigationController {

    /// Default is 9 / 默认最大可选9张图片
    var maxImagesCount:Int = 9
    
    /// The minimum count photos user must pick, Default is 0
    /// 最小照片必选张数,默认是0
    var minImagesCount:Int = 0
    
    /// grid column number
    var columnNumber:Int = 4
    
    /// Always enale the done button, not require minimum 1 photo be picked
    /// 让完成按钮一直可以点击，无须最少选择一张图片
    var alwaysEnableDoneBtn:Bool = false
    
    /// Sort photos ascending by modificationDate，Default is true
    /// 对照片排序，按修改时间升序，默认是true。如果设置为false,最新的照片会显示在最前面，内部的拍照按钮会排在第一个
    var sortAscendingByModificationDate:Bool = true
    
    /// Default is 828px / 默认828像素宽
    var photoWidth:CGFloat = 828
    
    /// Default is 600px / 默认600像素宽
    var photoPreviewMaxWidth:CGFloat = 600
    
    /// Default is 15, While fetching photo, HUD will dismiss automatic if timeout
    /// 超时时间，默认为15秒，当取图片时间超过15秒还没有取成功时，会自动dismiss HUD；
    var timeout:Int = 15
    
    /// Default is true, if set false, the original photo button will hide. user can't picking original photo.
    /// 默认为true，如果设置为false,原图按钮将隐藏，用户不能选择发送原图
    var allowPickingOriginalPhoto:Bool = true
    
    /// Default is true, if set false, user can't picking video.
    /// 默认为true，如果设置为false,用户将不能选择视频
    var allowPickingVideo:Bool = false
    
    /// Default is false, if set true, user can picking gif image.
    /// 默认为false，如果设置为true,用户可以选择gif图片
    var allowPickingGIF:Bool = false
    
    /// Default is true, if set false, user can't picking image.
    /// 默认为true，如果设置为false,用户将不能选择发送图片
    var allowPickingImage:Bool = true
    
    /// Default is true, if set false, user can't take picture.
    /// 默认为true，如果设置为false,拍照按钮将隐藏,用户将不能选择照片
    var allowTakePicture:Bool = true
    
    /// Default is true, if set false, user can't preview photo.
    /// 默认为true，如果设置为false,预览按钮将隐藏,用户将不能去预览照片
    var  allowPreview:Bool = true
    
    /// Default is true, if set false, the picker don't dismiss itself.
    /// 默认为true，如果设置为false, 选择器将不会自己dismiss
    var autoDismiss:Bool = true
    
    /// The photos user have selected
    /// 用户选中过的图片数组
    var selectedAssets: Array<PHAsset>?
    var selectedModels: Array<LFAssetModel>?
    
    /// Minimum selectable photo width, Default is 0
    /// 最小可选中的图片宽度，默认是0，小于这个宽度的图片不可选中
    var minPhotoWidthSelectable:Int = 0
    var minPhotoHeightSelectable:Int = 0
    
    /// Hide the photo what can not be selected, Default is false
    /// 隐藏不可以选中的图片，默认是false，不推荐将其设置为true
    var hideWhenCannotSelect:Bool = false
    
    /// Single selection mode, valid when maxImagesCount = 1
    /// 单选模式,maxImagesCount为1时才生效
    var showSelectBtn:Bool = false  ///< 在单选模式下，照片列表页中，显示选择按钮,默认为false
    
    ///------- picker not author -----
    var timer:Timer?
    var tipLabel:UILabel?
    var settingBtn:UIButton?
    
    var takePictureImageName = "takePicture"
    var photoSelImageName = "photo_sel_photoPickerVc"
    var photoDefImageName = "photo_def_photoPickerVc"
    var photoNumberIconImageName = "photo_number_icon"
    var photoPreviewOriginDefImageName = "preview_original_def"
    var photoOriginDefImageName = "photo_original_def"
    var photoOriginSelImageName = "photo_original_sel"
    
    var oKButtonTitleColorNormal = UIColor.init(colorLiteralRed: 83/255.0,
        green: 179/255.0,
        blue: 17/255.0,
        alpha: 1)
    var oKButtonTitleColorDisabled =  UIColor.init(colorLiteralRed: 83/255.0,
        green: 83/255.0,
        blue: 83/255.0,
        alpha: 0.5)
    
    var doneBtnTitleStr = Bundle.lf_localizedString(forKey: "Done")
    var cancelBtnTitleStr = Bundle.lf_localizedString(forKey: "Cancel")
    var previewBtnTitleStr = Bundle.lf_localizedString(forKey: "Preview")
    var fullImageBtnTitleStr = Bundle.lf_localizedString(forKey: "Full image")
    var settingBtnTitleStr = Bundle.lf_localizedString(forKey: "Setting")
    var processHintStr = Bundle.lf_localizedString(forKey: "Processing...")
    
    var pickerDelegate:LFImagePickerNavgationControllerDelegate?
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        view.backgroundColor = UIColor.white
        
        navigationBar.barStyle = .black
        navigationBar.isTranslucent = true
        navigationBar.barTintColor = UIColor.init(colorLiteralRed: 34/255.0,
                                                  green: 34/255.0,
                                                  blue: 34/255.0,
                                                  alpha: 1.0)
        navigationBar.tintColor = UIColor.white
        
        LFImageManager.manager.shouldFixOrientation = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(maxImagesCount:Int = 1, columnNumber:Int = 4, delegate:LFImagePickerNavgationControllerDelegate?, pushPhotoPickerVC:Bool = false) {
        
        self.columnNumber = columnNumber
        
        let albumVC = LFAlbumController()
        
        super.init(rootViewController: albumVC)
        
        self.pickerDelegate = delegate
        self.sortAscendingByModificationDate = false
        
        LFImageManager.manager.sortAscendingByModificationDate = sortAscendingByModificationDate
        LFImageManager.manager.columnNumber = columnNumber
        
        if LFImageManager.manager.authorizationStatusAuthorized() == false {
            addAuthorView()
        } else {
            self.pushPhotoPickerVC()
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    private func addAuthorView() {
        tipLabel = UILabel()
        
        tipLabel?.frame = CGRect(x: 8,
                                 y: 120,
                                 width: self.view.lf_width() - 16,
                                 height: 60)

        tipLabel?.textAlignment = .center
        tipLabel?.numberOfLines = 0
        tipLabel?.font = UIFont.systemFont(ofSize: 10)
        tipLabel?.textColor = UIColor.black
        let appName = Bundle.appName()
        tipLabel?.text = String(format: "Allow %@ to access your album in \"Settings -> Privacy -> Photos\"", appName)
        view.addSubview(tipLabel!)
        
        
        settingBtn = UIButton(type: .system)
        settingBtn?.setTitle(self.settingBtnTitleStr!, for: .normal)
        settingBtn?.frame = CGRect(x: 0,
                                  y: 180,
                                  width: self.view.lf_width(),
                                  height: 44)
        settingBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        settingBtn?.addTarget(self,
                              action: #selector(settingBtnClick),
                              for: .touchUpInside)
        view.addSubview(settingBtn!)
        
        timer = Timer.scheduledTimer(timeInterval: 0.2,
                                     target: self,
                                     selector: #selector(observeAuthrizationStatusChange),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc private func settingBtnClick() {
        UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
    }
    
    @objc private func observeAuthrizationStatusChange() {
        if LFImageManager.manager.authorizationStatusAuthorized() {
            tipLabel?.removeFromSuperview()
            settingBtn?.removeFromSuperview()
            
            timer?.invalidate()
            timer = nil
            pushPhotoPickerVC()
            
//            if self.viewControllers.count > 0 {
//                if let albumVC = self.viewControllers[0] as? LFAlbumController {
//                    albumVC.reloadDatas()
//                }
//            }
        }
    }
    
    private func pushPhotoPickerVC() {
        let photoPickerVC = LFPhotoPickerController()
        photoPickerVC.isFirstAppear = true
        photoPickerVC.columnNumber = columnNumber
        
        LFImageManager.manager.getCameraRollAlbum(allowPickingVideo: self.allowPickingVideo, allowPickingImage: self.allowPickingImage) { (albumModel) in
            photoPickerVC.albumModel = albumModel
            pushViewController(photoPickerVC, animated: true)
        }
    }
    
    public func cancelButtonClick() {
        if autoDismiss {
            dismiss(animated: true) {
                
            }
        }
    }
}

