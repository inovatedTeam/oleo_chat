//
//  GlobalPool.swift
//  READY
//
//  Created by Admin on 22/03/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit
import SwiftyJSON

let TheGlobalPoolManager = GlobalPool.sharedInstance

class GlobalPool: NSObject {
    static let sharedInstance = GlobalPool()

    var currentUser: User? = nil
    var accessToken: String = ""
    var deviceToken: String = Constants.DeviceInfo.DefaultDeviceToken
    
    var curMessageViewCon: MessagingViewController? = nil
    
    var arrayMissingMessagesFromStudents: Array<AnyObject> = []
    var arrayMissingMessagesFromTeachers: Array<AnyObject> = []
    
    var opponentUser: User? = nil
    
    var bCallerUser: Bool = false

    
    var student1: User? = nil
    var student2: User? = nil
    
    
    override init() {
        super.init()
    }
    
    func getLastMessage(userName : String, bStudent: Bool) -> String {
        var strReturn: String = ""
        
        let arrayValueForChecking = bStudent ? self.arrayMissingMessagesFromStudents : self.arrayMissingMessagesFromTeachers
        
        for i in  0..<arrayValueForChecking.count {
            let senderInfo = arrayValueForChecking[i] as! NSDictionary
            if senderInfo["receiver_info"]!["userName"] as! String == userName {
                let media_type = senderInfo["message_info"]!["media_type"] as! String
                if media_type == Constants.MessageType.Text {
                    strReturn = senderInfo["message_info"]!["message"] as! String
                } else {
                    strReturn = media_type
                }
                break
            }
        }
        
        return strReturn
    }
    
    func getEachMissingMessagesCnt(userName: String, bStudent: Bool) -> Int {
        var nMessageCnt: Int = 0
        
        let arrayValueForChecking = bStudent ? self.arrayMissingMessagesFromStudents : self.arrayMissingMessagesFromTeachers
        
        for i in  0..<arrayValueForChecking.count {
            let senderInfo = arrayValueForChecking[i] as! NSDictionary
            if senderInfo["receiver_info"]!["userName"] as! String == userName {
                nMessageCnt = Int(senderInfo["missing_count"] as! String)!
                break
            }
        }
        
        return nMessageCnt
    }
    
    func getMissingMessages(bHasLoadingAnimation: Bool) {
        if bHasLoadingAnimation {
            LoadingOverlay.shared.showOverlay(TheAppDelegate.window?.rootViewController!.view)
        }
        
        WebServiceAPI.postDataWithURL(Constants.APINames.GetMissingMessages, withoutHeader: false, params: nil, completionBlock: {(request:NSURLRequest?, response:NSHTTPURLResponse?, json:AnyObject)->Void in
            if bHasLoadingAnimation {
                LoadingOverlay.shared.hideOverlayView()
            }
            
            var nTotalMissingMessagesFromStudents = 0
            var nTotalMissingMessagesFromTeachers = 0
            
            let responseFromServer = JSON(json).dictionaryObject
            if let arrayMessagesOfStudents = responseFromServer!["student"] as? Array<AnyObject> {
                self.arrayMissingMessagesFromStudents = arrayMessagesOfStudents
                
                for i in  0..<self.arrayMissingMessagesFromStudents.count {
                    let senderInfo = self.arrayMissingMessagesFromStudents[i] as! NSDictionary
                    
                    nTotalMissingMessagesFromStudents += Int(senderInfo["missing_count"] as! String)!
                }
                
                NSLog("\(arrayMessagesOfStudents)")
            }

            if let arrayMessagesOfTeachers = responseFromServer!["teacher"] as? Array<AnyObject> {
                self.arrayMissingMessagesFromTeachers = arrayMessagesOfTeachers
                
                for i in 0..<self.arrayMissingMessagesFromTeachers.count {
                    let senderInfo = self.arrayMissingMessagesFromTeachers[i] as! NSDictionary
                    
                    nTotalMissingMessagesFromTeachers += Int(senderInfo["missing_count"] as! String)!
                }

                NSLog("\(arrayMessagesOfTeachers)")
            }
            
            /*
            let curTabBarViewCon = TheAppDelegate.window?.rootViewController as! UITabBarController
            let studentTabBarItem = curTabBarViewCon.tabBar.items![1]
            let teacherTabBarItem = curTabBarViewCon.tabBar.items![3]
            studentTabBarItem.badgeValue = nTotalMissingMessagesFromStudents > 0 ? "\(nTotalMissingMessagesFromStudents)" : nil
            teacherTabBarItem.badgeValue = nTotalMissingMessagesFromTeachers > 0 ? "\(nTotalMissingMessagesFromTeachers)": nil
            */
            
            }, errBlock: {(errorString) -> Void in
                if bHasLoadingAnimation {
                    LoadingOverlay.shared.hideOverlayView()
                }
        })
    }
}
