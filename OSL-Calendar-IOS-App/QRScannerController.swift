//
//  QRScanner.swift
//  OSL-Calendar-IOS-App
//
//  Created by Kyle Workman on 3/27/19.
//  Copyright © 2019 Kyle Workman. All rights reserved.
//
//  The QR view/scanner tab for the application
//
//  https://github.com/appcoda/QRCodeReader

import Foundation
import UIKit
import AVFoundation
import GoogleSignIn
import FirebaseAuth
import Firebase

class QRScannerController: UIViewController {
   
    var captureSession = AVCaptureSession()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.makeToastActivity(.center)
        DispatchQueue.main.async {
        // Get the back-facing camera for capturing videos
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],   mediaType: AVMediaType.video, position: .back)
        
            guard let captureDevice = deviceDiscoverySession.devices.first else {
                print("Failed to get the camera device")
                return
            }
        
            do {
                // Get an instance of the AVCaptureDeviceInput class using the previous device object.
                let input = try AVCaptureDeviceInput(device: captureDevice)
            
                // Set the input device on the capture session.
                self.captureSession.addInput(input)
            
                // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
                let captureMetadataOutput = AVCaptureMetadataOutput()
                self.captureSession.addOutput(captureMetadataOutput)
            
                // Set delegate and use the default dispatch queue to execute the call back
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = self.supportedCodeTypes
            
            } catch {
                // If any error occurs, simply print it out and don't continue any more.
                self.view.hideToastActivity()
                self.displayPopUp()
                print(error)
                return
            }
        
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.videoPreviewLayer?.frame = self.view.layer.bounds
            self.view.layer.addSublayer(self.videoPreviewLayer!)
        
            // Initialize QR Code Frame to highlight the QR code
            self.qrCodeFrameView = UIView()
        
            if let qrCodeFrameView = self.qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                self.view.addSubview(qrCodeFrameView)
                self.view.bringSubviewToFront(qrCodeFrameView)
            }
            self.view.hideToastActivity()
        }
    }
    
    // Displays a pop up telling the user the camera permissions are not enabled
    func displayPopUp() {
        let alertController = UIAlertController(title: "Camera Permission", message: "Unable to access camera, make sure permissions are allowed in Settings", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (alert) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.captureSession.startRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods
    
    func launchApp(decodedURL: String) {
        
        if presentedViewController != nil {
            return
        }
        
        let alertPrompt = UIAlertController(title: "Open URL", message: "Check into the event? You will be redirected to a URL.", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertAction.Style.default, handler: { (action) -> Void in
            if let url = URL(string: decodedURL) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        present(alertPrompt, animated: true, completion: nil)
    }
    
    func checkIn(decodedURL: String) {
        //obtain the unique firebase event ID from the decodedURL of form
        if (decodedURL.contains("?") && decodedURL.contains("osl-events-app.firebaseapp.com")) {
            var startIndex = decodedURL.index(of: "?")!
            startIndex = decodedURL.index(startIndex, offsetBy: 4)
            var endIndex = decodedURL.index(of: "&")!
            endIndex = decodedURL.index(endIndex, offsetBy: -1)
            let eventID = String(decodedURL[startIndex...endIndex])
            //obtain the user ID from the email of the current User
            let currentAccount = Auth.auth().currentUser
            let userEmail = currentAccount?.email
            let userIndex = userEmail!.index(of: "@")!
            let user = String((userEmail?.prefix(upTo: userIndex))!)
            //read the official event name from the database. If that is
            //successful, we write the user into the database and display
            //a confirmation message. If either action fails, a message
            //appears asking the user to try again.
            var eventDBref: DatabaseReference!
            eventDBref = Database.database().reference().child("current-events").child(eventID)
            let refHandle = eventDBref.child("name").observeSingleEvent(of: .value, with: { (snapshot) in
                let name = snapshot.value as? String ?? ""
                if (name != "") {
                    eventDBref.child("users").child(user).setValue(true){
                        (error:Error?, ref:DatabaseReference) in
                        if let error = error {
                            print("Data could not be saved: \(error).")
                            let message = "You were unable to check into " + name + ". Check your internet connection and try again."
                            self.showConfirmationDialog("Check In Failed", message)
                        } else {
                            let message = "You have successfully checked into " + name + " as " + user + "."
                            self.showConfirmationDialog("Checked In", message)
                        }
                    }
                } else {
                    let message = "Sorry, this event is in the past or no longer exists!"
                    self.showConfirmationDialog("Check In Failed", message)
                }
                
                
            }) { (error) in
                print(error.localizedDescription)
                let message = "We were unable to access this event. Check your internet connection and try again."
                self.showConfirmationDialog("Check In Failed", message)
            }
        } else {
            let message = "This is not a QR code for an Augustana Event."
            self.showConfirmationDialog("Invalid QR", message)
        }
        
    }
    
    func showConfirmationDialog(_ dialogTitle: String, _ dialogMessage: String) {
        if presentedViewController != nil {
            return
        }
        
        let alertPrompt = UIAlertController(title: dialogTitle, message: dialogMessage, preferredStyle: .actionSheet)
        //let confirmAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) -> Void in})
        
        //alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertPrompt, animated: true, completion: nil)
    }
    
}

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                //launchApp(decodedURL: metadataObj.stringValue!)
                checkIn(decodedURL: metadataObj.stringValue!)
            }
        }
    }
    
}

