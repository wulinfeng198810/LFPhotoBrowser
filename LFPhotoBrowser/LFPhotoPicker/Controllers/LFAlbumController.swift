//
//  LFAlbumController.swift
//  LFPhotoBrowser
//
//  Created by Leo on 19/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit

private let kLFAlbumCell = "LFAlbumCell"

/// album list
/// 相册列表
class LFAlbumController:UIViewController {
    
    var albumArr:Array<LFAlbumModel>?
    
    lazy var tableView:UITableView = {
        
        let frame = CGRect(x: 0, y: 0, width: self.view.lf_width(), height: self.view.lf_height())
        
        let tabView = UITableView(frame: frame, style: .plain)
        tabView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        tabView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0)
        tabView.rowHeight = 70
        tabView.delegate = self
        tabView.dataSource = self
        tabView.register(LFAlbumCell.self, forCellReuseIdentifier: kLFAlbumCell)
        tabView.tableFooterView = UIView()
        
        return tabView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        let imagePickerNAV = navigationController as! LFImagePickerNavgationController
        
        view.backgroundColor = UIColor.white
        navigationItem.title = imagePickerNAV.allowPickingImage ?
            Bundle.lf_localizedString(forKey: "Photos") :
            Bundle.lf_localizedString(forKey: "Video")
        
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: imagePickerNAV.cancelBtnTitleStr,
                            style: .plain,
                            target: imagePickerNAV,
                            action: #selector(imagePickerNAV.cancelButtonClick))
        
        navigationItem.backBarButtonItem =
            UIBarButtonItem(title: Bundle.lf_localizedString(forKey: "Back"),
                            style: .plain,
                            target: nil,
                            action: nil)
        
        view.addSubview(tableView)
        
        reloadDatas()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadDatas()
    }
    
    
    /// reload album list datas
    func reloadDatas() {
        let imagePickerNAV = navigationController as! LFImagePickerNavgationController
        LFImageManager.manager.getAllAlbums(allowPickingVideo: imagePickerNAV.allowPickingVideo, allowPickingImage: imagePickerNAV.allowPickingImage) { (albums:Array<LFAlbumModel>) in
            
            albumArr = albums
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension LFAlbumController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumArr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kLFAlbumCell) as! LFAlbumCell
        cell.albumModel = albumArr?[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let imagePickerNAV = navigationController as! LFImagePickerNavgationController
        let photoPickerVC = LFPhotoPickerController()
        photoPickerVC.isFirstAppear = true
        photoPickerVC.columnNumber = imagePickerNAV.columnNumber
        
        guard let album = albumArr?[indexPath.row]  else {
            return
        }
        
        photoPickerVC.albumModel = album
        navigationController?.pushViewController(photoPickerVC, animated: true)
    }
    
}
