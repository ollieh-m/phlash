//
//  CameraController.swift
//  Phlash
//
//  Created by Ollie Haydon-Mulligan on 17/06/2016.
//  Copyright © 2016 Phlashers. All rights reserved.
//

import UIKit
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let screenBounds:CGSize = UIScreen.mainScreen().bounds.size
    private let cameraView = CameraView()
    private let phollowView = PhollowView()
    private let helpView = HelpView()
    private var settingsView = UIView()
    var statusLabel = UILabel()
    var pendingPhlashesButton = UIButton()
    var phlashesArray = [PFObject]()
    
    
    private var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.frame = view.frame
        cameraView.settingsButton.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)
        cameraView.phollowButton.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)
        cameraView.helpButton.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)
        cameraView.logoutButton.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)
        cameraView.flipCamera.addTarget(self, action: #selector(buttonAction),forControlEvents: .TouchUpInside)
         cameraView.pendingPhlashesButton.addTarget(self, action: #selector(buttonAction),forControlEvents: .TouchUpInside)
        cameraView.swipeRight.addTarget(self, action: #selector(respondToSwipeGesture))
        cameraView.swipeLeft.addTarget(self, action: #selector(respondToSwipeGesture))
        cameraView.panGesture.addTarget(self, action: #selector(handlePanGesture))
        
        
        cameraView.tap.addTarget(self, action: #selector(dismissKeyboard))
        phollowView.frame = CGRect(x: 0, y: screenBounds.height, width: screenBounds.width, height: screenBounds.height)
        phollowView.createPhollowButton.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)
        phollowView.destroyPhollowButton.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)
        phollowView.cancelButton.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)
        
        helpView.frame = CGRect(x: 0, y: screenBounds.height, width: screenBounds.width, height: screenBounds.height)
        helpView.cancelButton.addTarget(self, action: #selector(buttonAction), forControlEvents: .TouchUpInside)

        pendingPhlashesButton = cameraView.pendingPhlashesButton
        statusLabel = cameraView.statusLabel
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(receivePush), name: "receivePush", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(checkBadge), name: UIApplicationDidBecomeActiveNotification, object: nil)
        loadImagePicker()
        checkDatabase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func checkBadge() {
        if UIApplication.sharedApplication().applicationIconBadgeNumber > 0 {
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            checkDatabase()
        }
    }
    
    func receivePush(notification: NSNotification) {
        checkDatabase()
        if let aps = notification.userInfo!["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                if let message = alert["message"] as? NSString {
                   AlertMessage().show(cameraView.statusLabel, message: message as String)
                }
            } else if let alert = aps["alert"] as? NSString {
                AlertMessage().show(cameraView.statusLabel, message: alert as String)
            }
        }
    }
    
    func checkDatabase() {
        let phlashCount = phlashesArray.count
        AlertMessage().show(statusLabel, message: "Checking...")
        RetrievePhoto().queryDatabaseForPhotos({ (phlashesFromDatabase, error) -> Void in
            self.phlashesArray = phlashesFromDatabase!
            if self.phlashesArray.count > phlashCount {
                AlertMessage().show(self.statusLabel, message: "New phlashes in! Swipe left to flick through them.")
                self.togglePhlashesLabel()
            } else {
                AlertMessage().show(self.statusLabel, message: "No new phlashes.")
                self.togglePhlashesLabel()
            }
        })
    }
    
    func dismissKeyboard() {
        cameraView.endEditing(true)
    }
    
    func loadImagePicker() {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            PickerSetup().makePickerFullScreen(picker)
            picker.delegate = self
            
            presentViewController(picker, animated: false, completion: {
                self.picker.cameraOverlayView = self.cameraView
            })
        }
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                picker.takePicture()
            case UISwipeGestureRecognizerDirection.Left:
                showPhlash()
            default:
                break
            }
        }
    }
    
   
    func togglePhlashesLabel() {
        if phlashesArray.count < 1 {
            pendingPhlashesButton.setImage(UIImage(named: "emptybolt.png"), forState: .Normal)
        } else {
            pendingPhlashesButton.setImage(UIImage(named: "bolt.png"), forState: .Normal)
        }
    }
    
    func showPhlash() {
        if phlashesArray.count > 0 {
            cameraView.swipeLeft.enabled = false
            cameraView.swipeRight.enabled = false
            let firstPhlash = phlashesArray.first!
            RetrievePhoto().showFirstPhlashImage(cameraView, firstPhlash: firstPhlash, swipeLeft: cameraView.swipeLeft, swipeRight: cameraView.swipeRight)
            phlashesArray.removeAtIndex(0)
           togglePhlashesLabel()
        } else {
            AlertMessage().show(statusLabel, message: "No phlashes! Try again later.")
        }
    }
    
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        cameraView.swipeRight.enabled = false
        cameraView.swipeLeft.enabled = false
        
        var image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        if picker.cameraDevice == UIImagePickerControllerCameraDevice.Front {
            image =  UIImage(CGImage: image.CGImage!, scale: image.scale, orientation:.LeftMirrored)
        } else {
            image = UIImage(CGImage:image.CGImage!, scale: 1.0, orientation: .Right)
        }
        
      
        let captionField = cameraView.captionField
        
        guard captionField.text?.characters.count < 100 else {
            AlertMessage().show(statusLabel, message: "Oops, caption cannot be more than 100 characters")
            return
        }
        
        let resizedImage = ResizeImage().resizeImage(image, newWidth: ImageViewFrame().getNewWidth(image))
        DisplayImage().setup(image, cameraView: cameraView, animate: false, username: "", caption: "", yValue: "", swipeLeft: cameraView.swipeLeft, swipeRight: cameraView.swipeRight)
        SendPhoto().sendPhoto(resizedImage, statusLabel: statusLabel, captionField: captionField)
    }
    
    func buttonAction(sender: UIButton!) {
        switch sender {
        case cameraView.logoutButton:
            logout()
        case cameraView.helpButton:
            help()
        case helpView.cancelButton:
            hideHelpView()
        case cameraView.phollowButton:
            showPhollowPage()
        case phollowView.createPhollowButton:
            phollow()
        case phollowView.destroyPhollowButton:
            unphollow()
        case phollowView.cancelButton:
            cancelPhollowPage()
        case cameraView.flipCamera:
            flipFrontBackCamera()
        case cameraView.pendingPhlashesButton:
            checkDatabase()
        case cameraView.settingsButton:
            if cameraView.logoutButton.frame.origin.y < 0 {
                showSettings()
            } else {
                hideSettings()
            }
        default:
            break
        }
    }
    
    func showSettings() {
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
            self.cameraView.logoutButton.frame.origin.y = self.screenBounds.width*2/5
            self.cameraView.helpButton.frame.origin.y = self.screenBounds.width*3/10
            self.cameraView.phollowButton.frame.origin.y = self.screenBounds.width/5
            }, completion: nil)
    }
    
    func hideSettings() {
        self.cameraView.logoutButton.frame.origin.y = -self.screenBounds.width*2/5
        self.cameraView.helpButton.frame.origin.y = -self.screenBounds.width*3/10
        self.cameraView.phollowButton.frame.origin.y = -self.screenBounds.width/5
    }
    
    func flipFrontBackCamera(){
        picker.cameraDevice = picker.cameraDevice == UIImagePickerControllerCameraDevice.Front ? UIImagePickerControllerCameraDevice.Rear : UIImagePickerControllerCameraDevice.Front
    }
    
    func logout() {
        PFUser.logOut()
       
        picker.dismissViewControllerAnimated(false, completion: {
            self.performSegueWithIdentifier("toAuth", sender: nil)
        })
    }
    
    func help() {
        hideSettings()
        cameraView.swipeLeft.enabled = false
         cameraView.swipeRight.enabled = false
        cameraView.addSubview(helpView)
        cameraView.containerView.hidden = true
        HelpViewSetup().animate(helpView, yValue: 0, appear: true)
    }
    
    func hideHelpView() {
        cameraView.swipeLeft.enabled = true
        cameraView.swipeRight.enabled = true
        cameraView.containerView.hidden = false
        HelpViewSetup().animate(helpView, yValue: screenBounds.height, appear: false)
    }
    
    func showPhollowPage() {
        hideSettings()
        cameraView.swipeLeft.enabled = false
        cameraView.swipeRight.enabled = false
        cameraView.addSubview(phollowView)
        cameraView.identificationLabel.text = ""
        cameraView.containerView.hidden = true
        PhollowViewSetup().animate(phollowView, yValue: 0, appear: true, cameraViewId: cameraView.identificationLabel)
    }
    
    func phollow() {
        if isInvalidInput(phollowView.usernameField.text!) {
            AlertMessage().show(phollowView.statusLabel, message: "Error: please review your input")
            return
        }

        PhollowSomeone().phollow(phollowView.usernameField, statusLabel: phollowView.statusLabel, phollowButton: phollowView.createPhollowButton, type: "phollow")
    }
    
    func unphollow() {
        if isInvalidInput(phollowView.usernameField.text!) {
            AlertMessage().show(phollowView.statusLabel, message: "Error: please review your input")
            return
        }
        PhollowSomeone().phollow(phollowView.usernameField, statusLabel: phollowView.statusLabel, phollowButton: phollowView.destroyPhollowButton, type: "unphollow")
    }
    
    func cancelPhollowPage() {
        cameraView.swipeLeft.enabled = true
        cameraView.swipeRight.enabled = true
        cameraView.containerView.hidden = false
        PhollowViewSetup().animate(phollowView, yValue: screenBounds.height, appear: false, cameraViewId: cameraView.identificationLabel)
    }
    
    
    func isInvalidInput(username: String) -> Bool {
        let MAX_LENGTH_USERNAME = 15
        var isInvalid = false
        if username.characters.count > MAX_LENGTH_USERNAME ||
            username.containsUpperCaseLetter() || !username.isAlphanumeric {
            isInvalid = true
        }
        return isInvalid
    }
    
    func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        
        let translation = panGesture.translationInView(cameraView)
        let newCenter = CGPoint(x: screenBounds.width/2, y: panGesture.view!.center.y + translation.y)
        
        if newCenter.y <= (screenBounds.height*16/17 - screenBounds.height/30) && newCenter.y >= screenBounds.height/30 {
            panGesture.view!.center = newCenter
            panGesture.setTranslation(CGPointZero, inView: cameraView)
        }
        
    }
}
