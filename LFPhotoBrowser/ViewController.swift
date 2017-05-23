//
//  ViewController.swift
//  LFPhotoBrowser
//
//  Created by Leo on 15/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, LFImagePickerNavgationControllerDelegate {

    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func camera(_ sender: Any) {
    
        let imagePickerNav = LFImagePickerNavgationController(maxImagesCount: 1, columnNumber: 3, delegate: self, pushPhotoPickerVC: true)
        self.present(imagePickerNav, animated: true, completion: nil)
    }
    
    @IBAction func album(_ sender: Any) {
       
        // album
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: LFImagePickerNavgationController, didFinishPickingPhoto photo: UIImage) {
        imgView.image = photo
        picker.dismiss(animated: true, completion: nil)
        
        print(photo)
    }
    
    func imagePickerControllerCancel(_ picker: LFImagePickerNavgationController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

