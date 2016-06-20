//
//  PhollowView.swift
//  Phlash
//
//  Created by serge on 17/06/2016.
//  Copyright © 2016 Phlashers. All rights reserved.
//

import UIKit

class PhollowView: UIView, UITextFieldDelegate {
    
    var usernameField = UITextField()
    var createPhollowButton = UIButton()
    var destroyPhollowButton = UIButton()
    var cancelButton = UIButton()
    var identificationLabel = UILabel()
    
    let screenBounds: CGSize = UIScreen.mainScreen().bounds.size
    let backgroundGreen: UIColor = UIColor( red: CGFloat(62/255.0), green: CGFloat(200/255.0), blue: CGFloat(172/255.0), alpha: CGFloat(0.75))
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        buildPhollowView()
        addUsernameField()
        addCreatePhollowButton()
        addDestroyPhollowButton()
        addCancelButton() //we have added this back as if you fail validations for add/unphollow someone you'll get stuck there (probably for life)!
        addIdLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func buildPhollowView() {
        backgroundColor = backgroundGreen
    }
    
    func addUsernameField() {
        usernameField.frame = CGRect(x: 0, y: screenBounds.height/8, width: screenBounds.width, height: screenBounds.height/15)
        usernameField.backgroundColor = UIColor.colorWithAlphaComponent(.whiteColor())(0.5)
        usernameField.placeholder = "Username"
        usernameField.textAlignment = .Center
        usernameField.accessibilityLabel = "phollowee"
        usernameField.delegate = self
        addSubview(usernameField)
    }
    
    func addCreatePhollowButton() {
        createPhollowButton.frame = CGRect(x: screenBounds.width/4, y: screenBounds.height*3/8, width: screenBounds.width/2, height: 30)
        createPhollowButton.setTitleColor(.whiteColor(), forState: .Normal)
        createPhollowButton.setTitle("Phollow", forState: .Normal)
        createPhollowButton.accessibilityLabel = "pholloweesubmit"
        addSubview(createPhollowButton)
    }
    
    func addDestroyPhollowButton() {
        destroyPhollowButton.frame = CGRect(x: screenBounds.width/4, y: screenBounds.height/2, width: screenBounds.width/2, height: 30)
        destroyPhollowButton.setTitleColor(.whiteColor(), forState: .Normal)
        destroyPhollowButton.setTitle("UnPhollow", forState: .Normal)
        destroyPhollowButton.accessibilityLabel = "unpholloweesubmit"
        addSubview(destroyPhollowButton)
    }
    
    func addCancelButton() {
        cancelButton.frame = CGRect(x: screenBounds.width*4/5, y: 20, width: screenBounds.width/5, height: 30)
        cancelButton.setTitleColor(.whiteColor(), forState: .Normal)
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.accessibilityLabel = "cancel"
        addSubview(cancelButton)
    }
    
    func addIdLabel() {
        identificationLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        identificationLabel.text = "PhollowView"
        identificationLabel.textColor = UIColor.clearColor()
        identificationLabel.userInteractionEnabled = false
        addSubview(identificationLabel)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.endEditing(true)
        return false
    }
}