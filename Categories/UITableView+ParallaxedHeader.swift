//
//  UITableView+ParallaxedHeader.swift
//  uni-hd
//
//  Created by Nils Fischer on 16.12.14.
//  Copyright (c) 2014 Universität Heidelberg. All rights reserved.
//

import UIKit

extension UITableView {
    
    public func adjustFrameForParallaxedHeaderView(parallaxedView: UIView) {
        if let tableHeaderView = self.tableHeaderView {
            let offset = self.contentOffset.y + self.contentInset.top
            var parallaxedFrame = tableHeaderView.bounds
            parallaxedFrame.origin.y = offset
            parallaxedFrame.size.height = max(0, -offset + tableHeaderView.frame.size.height);
            parallaxedView.frame = parallaxedFrame
        }
    }
    
}
