//
//  QuickBloxAPIInterface.swift
//  VideoChat
//
//  Created by Admin on 29/02/16.
//  Copyright © 2016 RonnieAlex. All rights reserved.
//

import UIKit

let TheQuickBloxAPIInterface = QuickBloxAPIInterface.sharedInstance

class QuickBloxAPIInterface: NSObject{
    static let sharedInstance = QuickBloxAPIInterface()
    
    var currentUser: QBUUser? = nil
    
    override init() {
        super.init()
    }

    func initProcess() {
        QBSettings.setApplicationID(Constants.QuickBlox.AppID)
        QBSettings.setAuthKey(Constants.QuickBlox.AuthKey)
        QBSettings.setAuthSecret(Constants.QuickBlox.AuthSecret)
        QBSettings.setAccountKey(Constants.QuickBlox.AccountKey)

        QBSettings.setLogLevel(.Info)
        QBSettings.setAutoReconnectEnabled(true)
    }
    
    func login(ID: String,
        email: String,
        password: String,
        completionBlock:((response:QBResponse, user:QBUUser?)->Void)?,
        errBlock:((response:QBResponse)->Void)? )-> Void {
            let currentUser:QBUUser = QBUUser()
            //currentUser.login = ID
            currentUser.email = email
            currentUser.password = password
            
            QBRequest.logInWithUserEmail(currentUser.email!, password: currentUser.password!, successBlock: { (response, user) -> Void in
                    self.currentUser = user
                    completionBlock!(response:response, user:user)
                },
                errorBlock: { (response) -> Void in
                    errBlock!(response:response)
                }
            )
    }

    func logout(completionBlock:((response:QBResponse)->Void)?,
        errBlock:((response:QBResponse)->Void)? )-> Void {
            QBRequest.logOutWithSuccessBlock({ (response) -> Void in
                    completionBlock!(response:response)
                },
                errorBlock: { (response) -> Void in
                    errBlock!(response:response)
                }
            )
    }

    func signup(ID: String,
        email: String,
        password: String,
        fullname: String,
        completionBlock:((response:QBResponse, user:QBUUser?)->Void)?,
        errBlock:((response:QBResponse)->Void)? )-> Void {
            let currentUser:QBUUser = QBUUser()
            currentUser.login = ID
            currentUser.email = email
            currentUser.fullName = fullname
            currentUser.password = password

            QBRequest.signUp(currentUser, successBlock: { (response, user) -> Void in
                    completionBlock!(response:response, user:user)
                },
                errorBlock: { (response) -> Void in
                    print("%@", response.error?.description)
                    
                    errBlock!(response:response)
                }
            )
    }

    func checkExsitingAccount(email : String,
                              completionBlock:((bExisting:Bool, userID: UInt?)->Void) ) -> Void {

        print("QB checking existing account with email: \(email)")
        QBRequest.userWithEmail(email,successBlock: { (response, user) -> Void in
                print("QB: Email '\(email)' already exists")
                completionBlock(bExisting: true, userID: user!.ID)
            },
            errorBlock: { (response) -> Void in
                print("QB: Email '\(email)' does not yet exist")
                completionBlock(bExisting: false, userID: nil)
            }
        )
        
    }
}
