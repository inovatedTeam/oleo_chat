//
//  OutComingCallViewController.swift
//  VideoChat
//
//  Created by Admin on 01/03/16.
//  Copyright © 2016 RonnieAlex. All rights reserved.
//

import UIKit

protocol OutComingCallViewControllerDelegate {
    func removeOutComingViewCon(viewCon: OutComingCallViewController)
}

class OutComingCallViewController: UIViewController, VideoCallManagerDelegate, UIAlertViewDelegate{

    var delegate: OutComingCallViewControllerDelegate? = nil
    
    @IBOutlet weak var m_imageViewOpponentUser: UIImageView!
    @IBOutlet weak var m_lblOpponentUserName: UILabel!
    @IBOutlet weak var m_btnEndCall: UIButton!

    var strOpponentUserName: String = ""
    var strOpponentUserProfileUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        TheVideoCallManager.delegate = self

        self.makeUserInterface()
    }
    
    override func viewWillDisappear(animated: Bool) {
        TheVideoCallManager.delegate = nil
    }
    
    func makeUserInterface() {
        self.m_lblOpponentUserName.text = "Calling to \(self.strOpponentUserName)..."
        
        m_imageViewOpponentUser.setNeedsLayout()
        m_imageViewOpponentUser.layoutIfNeeded()
        self.m_imageViewOpponentUser.downloadedFrom(link: self.strOpponentUserProfileUrl, contentMode:.ScaleAspectFit)
    }
    
    override func viewDidLayoutSubviews() {
        InterfaceManager.makeRadiusControl(self.m_imageViewOpponentUser, cornerRadius: CGRectGetWidth(self.m_imageViewOpponentUser.bounds) * 0.5, withColor: TheInterfaceManager.naviTintColor, borderSize: 2.0)
        InterfaceManager.makeRadiusControl(self.m_btnEndCall, cornerRadius: CGRectGetWidth(self.m_btnEndCall.bounds) * 0.5, withColor: UIColor.whiteColor(), borderSize: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func actionEndCall(sender: AnyObject) {
        self.endCallProcess()
    }

    func endCallProcess () {
        TheVideoCallManager.rejectCall(TheVideoCallManager.currentSession)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func goVideoCallView() {
        self.delegate?.removeOutComingViewCon(self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func callErrors(description: String) {
        let alertView: UIAlertView = UIAlertView(title: "Ready", message: description, delegate: self, cancelButtonTitle: "OK")
        alertView.tag = 100
        alertView.show()
    }

    func acceptedByUser() {
        self.goVideoCallView()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == 100 {
            self.endCallProcess()
        }
    }
}
