//
//  IncomingCallViewController.swift
//  VideoChat
//
//  Created by Admin on 01/03/16.
//  Copyright © 2016 RonnieAlex. All rights reserved.
//

import UIKit

class IncomingCallViewController: UIViewController, VideoCallManagerDelegate {
    
    @IBOutlet weak var m_imageViewOpponentUser: UIImageView!
    @IBOutlet weak var m_lblOpponentUserName: UILabel!
    @IBOutlet weak var m_btnEndCall: UIButton!
    @IBOutlet weak var m_btnAcceptCall: UIButton!

    var strOpponentUserName: String = ""
    var strOpponentUserProfileUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        TheVideoCallManager.delegate = self

        self.makeUserInterface()
        
        TheVideoCallManager.incomingCall()
    }
    
    override func viewWillDisappear(animated: Bool) {
        TheVideoCallManager.delegate = nil
    }
    
    func makeUserInterface() {
        self.m_lblOpponentUserName.text = self.strOpponentUserName
        
        m_imageViewOpponentUser.setNeedsLayout()
        m_imageViewOpponentUser.layoutIfNeeded()
        self.m_imageViewOpponentUser.downloadedFrom(link: self.strOpponentUserProfileUrl, contentMode:.ScaleAspectFit)
    }
    
    override func viewDidLayoutSubviews() {
        InterfaceManager.makeRadiusControl(self.m_imageViewOpponentUser, cornerRadius: CGRectGetWidth(self.m_imageViewOpponentUser.bounds) * 0.5, withColor: TheInterfaceManager.naviTintColor, borderSize: 2.0)

        InterfaceManager.makeRadiusControl(self.m_btnEndCall, cornerRadius: self.m_btnEndCall.bounds.size.width * 0.5, withColor: UIColor.whiteColor(), borderSize: 1.0)
        InterfaceManager.makeRadiusControl(self.m_btnAcceptCall, cornerRadius: self.m_btnAcceptCall.bounds.size.width * 0.5, withColor: UIColor.whiteColor(), borderSize: 1.0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionEndCall(sender: AnyObject) {
        TheVideoCallManager.rejectCall(TheVideoCallManager.currentSession)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func actionAcceptCall(sender: AnyObject) {
        self.goVideoCallView()
    }

    func goVideoCallView() {
        let viewCon: VideoCallViewController = self.storyboard?.instantiateViewControllerWithIdentifier("videocallview") as! VideoCallViewController
        viewCon.bOutComingCall = false
        
        self.addChildViewController(viewCon)
        self.view.addSubview(viewCon.view)
        viewCon.didMoveToParentViewController(self)
    }

    func callErrors(description: String) {
        self.endCallProcess()
    }
    
    func acceptedByUser() {
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == 100 {
            self.endCallProcess()
        }
    }

    func endCallProcess () {
        TheVideoCallManager.bIncomingCall = false

        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
