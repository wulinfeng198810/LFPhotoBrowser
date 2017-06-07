//
//  LFPhotoPreviewController.swift
//  LFPhotoBrowser
//
//  Created by Leo on 19/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit

private let kLFPhotoPreviewCell = "LFPhotoPreviewCell"


/// preview
/// 预览,采用 collectionView
class LFPhotoPreviewController: UIViewController {

    var currentIndex:Int = 0
    var albumModel:LFAlbumModel?
    
    var collectionView:UICollectionView?
    
    var _naviBar:UIView?
    var _backButton:UIButton?
    var _selectButton:UIButton?
    
    var _toolBar:UIView?
    var _editButton:UIButton?
    var _originalPhotoButton:UIButton?
    var _originalPhotoLabel:UILabel?
    var _doneButton:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        
        configCollectionView()
        configCustomNaviBar()
        configBottomToolBar()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
//        collectionView?.setContentOffset(CGPoint(x:view.lf_width() * CGFloat(currentIndex),y:0), animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func configCollectionView() {
        
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        
        flow.itemSize = view.bounds.size
        flow.minimumLineSpacing = 0.1
        flow.minimumInteritemSpacing = 0.1
        flow.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        collectionView = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: flow)
        collectionView?.backgroundColor = UIColor.black
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.register(LFPhotoPreviewCell.self, forCellWithReuseIdentifier: kLFPhotoPreviewCell)
        view.addSubview(collectionView!)
    }
    
    private func configCustomNaviBar() {
        _naviBar = UIView(frame: CGRect(x: 0, y: 0, width: view.lf_width(), height: 64))
        _naviBar?.backgroundColor = UIColor(colorLiteralRed: 34/255.0,
                                            green: 34/255.0,
                                            blue: 34/255.0,
                                            alpha: 0.7)
    
        _backButton = UIButton(frame: CGRect(x: 10, y: 10, width: 44, height: 44))
        _backButton?.setImage(Bundle.lf_image(named: "navi_back"), for: .normal)
        _backButton?.setTitleColor(UIColor.white, for: .normal)
        _backButton?.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        
        _naviBar?.addSubview(_backButton!)
        view.addSubview(_naviBar!)
    }
    
    private func configBottomToolBar() {
        _toolBar = UIView(frame: CGRect(x: 0, y: view.lf_height() - 44, width: view.lf_width(), height: 44))
        _toolBar?.backgroundColor = UIColor(colorLiteralRed: 34/255.0,
                                            green: 34/255.0,
                                            blue: 34/255.0,
                                            alpha: 0.7)
        
        let nav = self.navigationController as! LFImagePickerNavgationController
        
        _editButton = UIButton(type: .system)
        _editButton?.frame = CGRect(x: 12, y: 0, width: 44, height: 44)
        _editButton?.setTitle(Bundle.lf_localizedString(forKey: "Edit"), for: .normal)
        _editButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        _editButton?.setTitleColor(UIColor.white, for: .normal)
        _editButton?.addTarget(self, action: #selector(editPhotoButtonClick), for: .touchUpInside)
        
        
        _originalPhotoButton = UIButton(type: .custom)
        _originalPhotoButton?.frame = CGRect(x: (_editButton?.lf_left())! + (_editButton?.lf_width())! + 12, y: 0, width: 80, height: 44)
        _originalPhotoButton?.setTitle(" " + (Bundle.lf_localizedString(forKey: "Full image") ?? ""), for: .normal)
        _originalPhotoButton?.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        _originalPhotoButton?.setTitleColor(UIColor.lightGray, for: .normal)
        _originalPhotoButton?.setTitleColor(UIColor.white, for: .selected)
        _originalPhotoButton?.setImage(Bundle.lf_image(named: "photo_original_def"), for: .normal)
        _originalPhotoButton?.setImage(Bundle.lf_image(named: "photo_original_sel"), for: .selected)
        _originalPhotoButton?.addTarget(self, action: #selector(originalPhotoButtonClick), for: .touchUpInside)
        
        _doneButton = UIButton(type: .system)
        _doneButton?.frame = CGRect(x: view.lf_width() - 12 - 44, y: 0, width: 44, height: 44)
        _doneButton?.setTitle(Bundle.lf_localizedString(forKey: "Done"), for: .normal)
        _doneButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        _doneButton?.setTitleColor(nav.oKButtonTitleColorNormal, for: .normal)
        _doneButton?.addTarget(self, action: #selector(doneButtonClick), for: .touchUpInside)
        
        _toolBar?.addSubview(_editButton!)
        _toolBar?.addSubview(_originalPhotoButton!)
        _toolBar?.addSubview(_doneButton!)
        view.addSubview(_toolBar!)
    }
    
    func backButtonClick() {
        navigationController?.popViewController(animated: true)
    }
    
    func editPhotoButtonClick() {
        
        let asset = albumModel?.models?[currentIndex].asset
        LFImageManager.manager.getOriginalPhoto(withAsset: asset!, isCompress:!_originalPhotoButton!.isSelected) { (photo, info) in
            if photo != nil {
                let editor = CLImageEditor(image: photo!)
                self.navigationController?.pushViewController(editor!, animated: true)
                
//                let nav = self.navigationController as! LFImagePickerNavgationController
//                nav.pickerDelegate?.imagePickerController(nav, didFinishPickingPhoto: photo!)
            }
        }
    }
    
    func originalPhotoButtonClick() {
        _originalPhotoButton?.isSelected = !_originalPhotoButton!.isSelected
    }
    
    func doneButtonClick() {
        
        let asset = albumModel?.models?[currentIndex].asset
        LFImageManager.manager.getOriginalPhoto(withAsset: asset!, isCompress:!_originalPhotoButton!.isSelected) { (photo, info) in
            if photo != nil {
                let nav = self.navigationController as! LFImagePickerNavgationController
                nav.pickerDelegate?.imagePickerController(nav, didFinishPickingPhoto: photo!)
                
                nav.imagePickerDismiss()
            }
        }
    }
    
    private func reloadDatas() {
    }
}


// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension LFPhotoPreviewController:UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return albumModel?.count ?? 0
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kLFPhotoPreviewCell, for: indexPath) as? LFPhotoPreviewCell else {
                return UICollectionViewCell()
        }
        
        cell.assetModel = albumModel?.models?[currentIndex]
        
        return cell
    }
}
