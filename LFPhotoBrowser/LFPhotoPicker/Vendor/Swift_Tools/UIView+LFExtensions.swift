//
//  UIView+LFExtensions.swift
//  LFPhotoBrowser
//
//  Created by Leo on 18/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit

extension UIView {
    
    func lf_left() -> CGFloat {
        return self.frame.origin.x
    }
    
    func setLf_left(_ x:CGFloat) {
        self.frame.origin.x = x
    }
    
    func lf_right() -> CGFloat {
        return self.frame.origin.x + self.frame.width
    }
    
    func lf_top() -> CGFloat {
        return self.frame.origin.y
    }
    
    func setLf_top(_ y:CGFloat) {
        self.frame.origin.y = y
    }
    
    func lf_bottom() -> CGFloat {
        return self.frame.origin.y + self.frame.height
    }
    
    func lf_width() -> CGFloat {
        return self.frame.width
    }
    
    func setLf_width(_ width:CGFloat) {
        self.frame.size.width = width
    }
    
    func lf_height() -> CGFloat {
        return self.frame.height
    }
    
    func setLf_height(_ height:CGFloat) {
        self.frame.size.height = height
    }
    
    func lf_centerX() -> CGFloat {
        return self.center.x
    }
    
    func setLf_centerX(_ centerX:CGFloat) {
        self.center.x = centerX
    }
    
    func lf_centerY() -> CGFloat {
        return self.center.y
    }
    
    func setLf_centerY(_ centerY:CGFloat) {
        self.center.y = centerY
    }
    
    func lf_origin() -> CGPoint {
        return self.frame.origin
    }
    
    func setLf_origin(_ origin:CGPoint) {
        self.frame.origin = origin
    }
    
    func lf_size() -> CGSize {
        return self.frame.size
    }
    
    func setLf_size(_ size:CGSize) {
        self.frame.size = size
    }
    
}
