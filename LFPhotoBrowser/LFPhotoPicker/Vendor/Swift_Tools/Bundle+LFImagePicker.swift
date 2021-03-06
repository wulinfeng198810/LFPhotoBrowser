//
//  Bundle+LFImagePicker.swift
//  LFPhotoBrowser
//
//  Created by Leo on 18/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import Foundation


/// LFImagePicker.bundle 国际化／图片等资源获取
extension Bundle {
    
    static var lf_imagePickerBundle:Bundle? {
        
        let bundlePath = Bundle.main.path(forResource: "LFImagePicker",
                                          ofType: "bundle")
        
        if bundlePath == nil {
            assert(false, "not found bundle!")
        }
        
        guard let path = bundlePath else {
            return nil
        }
        
        return Bundle(path: path)
    }
    
    class func lf_localizedString(forKey:String, value:String? = nil) -> String? {
        
        // TODO: - 需要简化
        
        let lf_imagePickerBundle:Bundle? = Bundle.lf_imagePickerBundle
        
        var language = NSLocale.preferredLanguages[0]
        
        if language.contains("zh-Hans") {
            language = "zh-Hans"
        } else {
            language = "en"
        }
        
        let localizedStrBundlePath = lf_imagePickerBundle?.path(forResource: language,
                                                    ofType: "lproj")
        
        guard let _localizedStrBundlePath = localizedStrBundlePath else {
            return nil
        }
        
        let localizedStrBundle = Bundle(path: _localizedStrBundlePath)
        
        let v = localizedStrBundle?.localizedString(forKey: forKey,
                                                    value: value,
                                                    table: nil)
        
        if v == nil {
            assert(false, "no such localizedString in LFImagePicker.bundle")
        }
        
        return v
    }
    
    
    class func lf_image(named:String) -> UIImage? {
        
        let img = UIImage(named: named, in: lf_imagePickerBundle, compatibleWith: nil)
        
        if img == nil {
            assert(false, "no such image in LFImagePicker.bundle")
        }

        return img
    }
}
