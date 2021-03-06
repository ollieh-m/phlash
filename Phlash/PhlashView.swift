//
//  PhlashView.swift
//  Phlash
//
//  Created by Admin on 18/06/2016.
//  Copyright © 2016 Phlashers. All rights reserved.
//

import UIKit

class PhlashView: UIImageView {
    
    private let screenBounds:CGSize = UIScreen.mainScreen().bounds.size
    private let whiteColor = UIColor.whiteColor()
    private let blackColor = UIColor.blackColor()
    private let backgroundGreen: UIColor = UIColor( red: CGFloat(48/255.0), green: CGFloat(227/255.0), blue: CGFloat(202/255.0), alpha: CGFloat(0.75))
    var identificationLabel = UILabel()
    let usernameLabel = UILabel()
    let captionLabel = UILabel()
    let FONT_SIZE = UIScreen.mainScreen().bounds.size.height/35
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        backgroundColor = UIColor.clearColor()
        addIdLabel()
        addUsernameLabel()
        addCaptionLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addIdLabel() {
        identificationLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        identificationLabel.text = "PhlashView"
        identificationLabel.textColor = UIColor.clearColor()
        identificationLabel.userInteractionEnabled = false
        addSubview(identificationLabel)
    }
    
    func addUsernameLabel() {
        usernameLabel.frame = CGRect(x: 0, y: screenBounds.height*16/17, width: self.frame.width, height: screenBounds.height/17)
        usernameLabel.font = UIFont.systemFontOfSize(FONT_SIZE)
        usernameLabel.backgroundColor = backgroundGreen
        usernameLabel.textColor = whiteColor
        usernameLabel.textAlignment = .Center
        usernameLabel.userInteractionEnabled = false
        addSubview(usernameLabel)
    }
    
    func addCaptionLabel() {
        captionLabel.frame = CGRect(x: 0, y: screenBounds.height/5, width: self.frame.width, height: screenBounds.height/15)
        captionLabel.backgroundColor = UIColor.colorWithAlphaComponent(whiteColor)(0.5)
        captionLabel.textColor = blackColor
        captionLabel.textAlignment = .Center
        captionLabel.userInteractionEnabled = false
        
        captionLabel.font = UIFont.systemFontOfSize(FONT_SIZE)
        captionLabel.minimumScaleFactor = 0.5
        captionLabel.adjustsFontSizeToFitWidth = true
        captionLabel.numberOfLines = 1
        
        addSubview(captionLabel)
    }
}