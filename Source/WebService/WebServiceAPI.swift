//
//  FeedbackViewController.swift
//  READY
//
//  Created by Admin on 18/03/16.
//  Copyright © 2016 Andrei. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WebServiceAPI: NSObject {
    static func postDataWithURL(url:String,
                                withoutHeader: Bool,
                                params:Dictionary<String, AnyObject>?,
                                completionBlock:((request:NSURLRequest?, response:NSHTTPURLResponse?, json:AnyObject)->Void)?,
                                errBlock:((errorString:String)->Void)? )-> Void {
        
        
        var headers:[String:String]? = nil
        if withoutHeader {
            headers = nil
        } else {
            headers = ["Access-Token":TheGlobalPoolManager.accessToken, "Device-Id":TheGlobalPoolManager.deviceToken]
        }
        
        let urlString = "\(Constants.WebServiceApi.ApiBaseUrl)\(url)"
        print("WebServiceAPI postDataWithURL: \(urlString)")
        Alamofire.request(.POST, urlString, parameters: params, encoding: ParameterEncoding.URL, headers: headers)
            .responseJSON { response in
                let json = response.result
                if json.isSuccess {
                    if let data = json.value {
                        let jsonObj = JSON(data)
                        
                        if jsonObj.error == nil {
                            if let dictionaryObject = jsonObj.dictionaryObject {
                                if dictionaryObject["success"] as! String == "0" || dictionaryObject["success"] as! String == "false" {
                                    TheInterfaceManager.showLocalValidationError("error-1", errorMessage: dictionaryObject["message"] as! String)
                                    errBlock!(errorString: "")
                                } else {
                                    completionBlock!(request: nil, response: nil, json: data)
                                }
                            }
                        } else {
                            errBlock!(errorString: jsonObj.error!.localizedDescription)
                        }

                    } else {
                        errBlock!(errorString: "Could not get json.value")
                    }
                } else {
                    errBlock!(errorString: "We're sorry, a network error occurred")
                }
        }
    }

    static func postDataWithURLWithResource(url:String,
                                withoutHeader: Bool,
                                resourceData:NSData?,
                                fileName:String,
                                mimeType:String,
                                attachParamName:String,
                                params:Dictionary<String, AnyObject>?,
                                completionBlock:((request:NSURLRequest?, response:NSHTTPURLResponse?, json:AnyObject)->Void)?,
                                errBlock:((errorString:String)->Void)? )-> Void {
        var headers:[String:String]? = nil
        if withoutHeader {
            headers = nil
        } else {
            headers = ["Access-Token":TheGlobalPoolManager.accessToken, "Device-Id":TheGlobalPoolManager.deviceToken]
        }
        
        Alamofire.upload(.POST, "\(Constants.WebServiceApi.ApiBaseUrl)\(url)", headers: headers, multipartFormData: { multipartFormData in
            
            if resourceData != nil {
                multipartFormData.appendBodyPart(data: resourceData!, name: attachParamName, fileName: fileName, mimeType: mimeType)
            }
            
            if let params = params {
                for (key, value) in params {
                    multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                }
            }
            print(multipartFormData)
            }, encodingMemoryThreshold: Manager.MultipartFormDataEncodingMemoryThreshold,
               encodingCompletion: { encodingResult in
                
                print("HEADERS: \(headers)")
                print("PARAMS: \(params)")
                
                switch encodingResult {
                case .Success(let upload, _, _):
                    
                    upload.responseJSON(completionHandler: { response in
                        
                        debugPrint(response)
                        
                        let json = response.result
                        if let data = json.value {
                            let jsonObj = JSON(data)
                            
                            if jsonObj.error == nil {
                                if let dictionaryObject = jsonObj.dictionaryObject {
                                    if dictionaryObject["success"] as! String == "0" || dictionaryObject["success"] as! String == "false" {
                                        TheInterfaceManager.showLocalValidationError("error-1", errorMessage: dictionaryObject["message"] as! String)
                                        errBlock!(errorString: "")
                                    } else {
                                        completionBlock!(request: nil, response: nil, json: data)
                                    }
                                }
                            } else {
                                errBlock!(errorString: "")
                            }
                            
                        } else {
                            errBlock!(errorString: "")
                        }
                    })
                    upload.responseString(completionHandler: { (response) in
                        debugPrint(response)
                    })
                case .Failure(let encodingError):
                    print("Encoding Result was FAILURE")
                    print(encodingError)
                    //                        if Reachability.isConnectedToNetwork() {
                    //                            TheInterfaceManager.showLocalValidationError("error-1", errorMessage: NSLocalizedString("Please check your internet connection or try again", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""))
                    //                        } else {
                    //                            TheInterfaceManager.showNoInternetConnectionView()
                    //                        }
                    //                        errBlock!(errorString: "Encoding Result was FAILURE")
                }
        })
    }

    static func getDataWithURL(url:String,
        params:Dictionary<String, AnyObject>?,
        withoutHeader: Bool,
        cacheKey:String?,
        completionBlock:((request:NSURLRequest?, response:NSHTTPURLResponse?, json:SwiftyJSON.JSON, isFromCache:Bool)->Void)?,
        errBlock:((errorString:String)->Void)? )-> Void {
            
            var headers:[String:String]? = nil
            if withoutHeader {
                headers = nil
            } else {
                headers = ["Acces-Token":TheGlobalPoolManager.accessToken, "Device-Id":TheGlobalPoolManager.deviceToken]
            }

            Alamofire.request(.GET, "\(Constants.WebServiceApi.ApiBaseUrl)\(url)", parameters: params, encoding: ParameterEncoding.JSON, headers: headers)
                .responseJSON { response in
                    let json = response.result
                    if json.isSuccess {
                        if let data = json.value {
                            
                            let jsonObj = JSON(data)
                            
                            if jsonObj["error"] != nil {
                                let error = jsonObj["error"]
                                if let message = error.rawString() {
                                    if message == "invalid_grant" {
                                    } else {
                                        TheInterfaceManager.showLocalValidationError("error-1", errorMessage: NSLocalizedString("Please check your internet connection or try again", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""))
                                    }
                                    
                                    errBlock!(errorString: message)
                                }
                            } else {
                                completionBlock!(request: nil, response: nil, json: jsonObj, isFromCache:false)
                            }
                        } else {
                            errBlock!(errorString: "")
                        }
                    } else {
                        if Reachability.isConnectedToNetwork() {
                            TheInterfaceManager.showLocalValidationError("error-1", errorMessage: NSLocalizedString("Please check your internet connection or try again", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""))
                        } else {
                            TheInterfaceManager.showNoInternetConnectionView()
                        }
                    }
            }
    }

    static func sendMessageWithMedia(resourceData:NSData?,
        fileName:String,
        mimeType:String,
        attachParamName:String,
        url:String,
        params:Dictionary<String, AnyObject>?,
        completionBlock:((media_link: String?, media_type: String?)->Void)?,
        errBlock:((errorString:String)->Void)? )-> Void {
        
        
            let headers:[String:String] = ["Access-Token":TheGlobalPoolManager.accessToken, "Device-Id":TheGlobalPoolManager.deviceToken]
            
            Alamofire.upload(.POST, "\(Constants.WebServiceApi.ApiBaseUrl)\(url)", headers: headers, multipartFormData: { multipartFormData in
                
                if resourceData != nil {
                    multipartFormData.appendBodyPart(data: resourceData!, name: attachParamName, fileName: fileName, mimeType: mimeType)
                }
                
                if let params = params {
                    for (key, value) in params {
                        multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                    }
                }
                print(multipartFormData)
                }, encodingMemoryThreshold: Manager.MultipartFormDataEncodingMemoryThreshold,
                   encodingCompletion: { encodingResult in
                    
                    print("HEADERS: \(headers)")
                    print("PARAMS: \(params)")
                    
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        
                        upload.responseJSON(completionHandler: { response in
                    
                            debugPrint(response)
                            
                            let json = response.result
                            if let data = json.value {
                                let jsonObj = JSON(data)
                                
                                if jsonObj.error == nil {
                                    if let dictionaryObject = jsonObj.dictionaryObject {
                                        if dictionaryObject["success"] as! String == "0" || dictionaryObject["success"] as! String == "false" {
                                            TheInterfaceManager.showLocalValidationError("error-1", errorMessage: dictionaryObject["message"] as! String)
                                            errBlock!(errorString: "")
                                        } else {
                                            completionBlock!(media_link: dictionaryObject["media_link"] as? String, media_type: dictionaryObject["media_type"] as? String)
                                        }
                                    }
                                } else {
                                    errBlock!(errorString: "")
                                }
                                
                            } else {
                                errBlock!(errorString: "")
                            }
                        })
                        upload.responseString(completionHandler: { (response) in
                            debugPrint(response)
                        })
                    case .Failure(let encodingError):
                        print("Encoding Result was FAILURE")
                        print(encodingError)
//                        if Reachability.isConnectedToNetwork() {
//                            TheInterfaceManager.showLocalValidationError("error-1", errorMessage: NSLocalizedString("Please check your internet connection or try again", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""))
//                        } else {
//                            TheInterfaceManager.showNoInternetConnectionView()
//                        }
//                        errBlock!(errorString: "Encoding Result was FAILURE")
                    }
            })
    }
    
    //MARK: converter
    static func dateFromString(dateString:String?, dateFormat:String) -> NSDate? {
        if let dateString = dateString {
            let formatter = NSDateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "US_en")
            formatter.dateFormat = dateFormat
            return formatter.dateFromString(dateString)
        }
        
        return nil
    }

}
