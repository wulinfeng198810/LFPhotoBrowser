//
//  LFPhotoPreviewController.swift
//  LFPhotoBrowser
//
//  Created by Leo on 19/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit

private let kLFPhotoPreviewCell = "LFPhotoPreviewCell"

class LFPhotoPreviewController: UIViewController {

    var currentIndex:Int = 0
    var albumModel:LFAlbumModel?
    
    var collectionView:UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        
        configCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        collectionView?.setContentOffset(CGPoint(x:view.lf_width() * CGFloat(currentIndex),y:0), animated: false)
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
        collectionView?.backgroundColor = UIColor.white
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.register(LFPhotoPreviewCell.self, forCellWithReuseIdentifier: kLFPhotoPreviewCell)
        view.addSubview(collectionView!)
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
        return albumModel?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kLFPhotoPreviewCell, for: indexPath) as? LFPhotoPreviewCell else {
                return UICollectionViewCell()
        }
        
        cell.assetModel = albumModel?.models?[indexPath.row]
        
        return cell
    }
}
