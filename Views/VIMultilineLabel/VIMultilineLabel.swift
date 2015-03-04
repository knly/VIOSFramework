//
//  VIMultilineLabel.swift
//  uni-hd
//
//  Created by Nils Fischer on 07.12.14.
//  Copyright (c) 2014 Universität Heidelberg. All rights reserved.
//

import UIKit

class VIMultilineLabel: UILabel {

    override var bounds: CGRect {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    override func updateConstraints() {
        if self.preferredMaxLayoutWidth != bounds.width {
            self.preferredMaxLayoutWidth = bounds.width
        }
        super.updateConstraints()
    }
    
}
