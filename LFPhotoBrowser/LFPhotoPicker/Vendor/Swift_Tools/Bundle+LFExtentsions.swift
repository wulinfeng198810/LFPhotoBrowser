//
//  Bundle+LFExtentsion.swift
//  LFPhotoBrowser
//
//  Created by Leo on 18/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import Foundation

extension Bundle {
    
    class func appName() -> String {
        
        if let appBundleDisplayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            return appBundleDisplayName
        } else if let appBundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            return appBundleName
        }
        
        return "APP NAME ?"
    }
}
