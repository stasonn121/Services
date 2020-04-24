//
//  AutificationUIView.swift
//  Social App
//
//  Created by user on 16.03.2020.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit

class AutificationUIView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.layer.cornerRadius = self.frame.height / 2
             
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 10
             
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    

    }
    
}
