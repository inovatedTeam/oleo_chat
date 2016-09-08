//
//  BaseManager.swift
//  Polco
//
//  Created by Marcelo Ribeiro on 7/15/15.
//  Copyright © 2015 Polco. All rights reserved.
//

import UIKit

@objc protocol BaseManagerDelegate {
    
    optional func itemsFetched(_: NSArray) -> Void
    optional func commentsFetched(_: NSArray) -> Void
    optional func discussionTopicsFetched(_: NSArray) -> Void
    optional func itemFetched(_: BaseEntity) -> Void
    optional func entityCreated(entity:BaseEntity) -> Void
    optional func entitySaved(entity:BaseEntity) -> Void
    optional func itemDeleted() -> Void
    optional func entityNotFound() -> Void
    optional func entityFound() -> Void
}

class BaseManager: NSObject {
    
    var delegate: BaseManagerDelegate?
    
    func appDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func prepareMapping(prefix:NSString) {
//        let statusCodes = RKStatusCodeIndexSetForClass(UInt(RKStatusCodeClassSuccessful))
//        let keyName = self.keyName()
//        
//        let responseMapping:RKObjectMapping = self.responseMapping()
//        self.addNestedResponseMappings(responseMapping)
//        
//        let responseDescriptor = RKResponseDescriptor(mapping: responseMapping, method: RKRequestMethod.Any, pathPattern: "\(prefix)/\(keyName).json", keyPath: keyName, statusCodes: statusCodes)
//        
//        let idResponseDescriptor = RKResponseDescriptor(mapping: responseMapping, method: RKRequestMethod.Any, pathPattern: "\(prefix)/\(pluralKeyName())/:id.json", keyPath: keyName, statusCodes: statusCodes)
//        
//        let pluralResponseDescriptor = RKResponseDescriptor(mapping: responseMapping, method: RKRequestMethod.GET, pathPattern: "\(prefix)/\(pluralKeyName()).json", keyPath: pluralKeyName(), statusCodes: statusCodes)
//        
//        let createdResponseDescriptor = RKResponseDescriptor(mapping: responseMapping, method: RKRequestMethod.POST, pathPattern: "\(prefix)/\(pluralKeyName()).json", keyPath: keyName, statusCodes: statusCodes)
//        
//        let requestMapping:RKObjectMapping = self.requestMapping()
//        self.addNestedRequestMappings(requestMapping)
//        let requestDescriptor = RKRequestDescriptor(mapping: requestMapping, objectClass: entityClass(), rootKeyPath: keyName, method: RKRequestMethod.Any)
//        
//        let manager = RKObjectManager.sharedManager()
//
//        manager.addResponseDescriptor(responseDescriptor)
//        manager.addResponseDescriptor(idResponseDescriptor)
//        manager.addResponseDescriptor(pluralResponseDescriptor)
//        manager.addResponseDescriptor(createdResponseDescriptor)
//        manager.addRequestDescriptor(requestDescriptor)
    }
//
//    func requestMapping() -> RKObjectMapping {
//        let mapping = RKObjectMapping.requestMapping();
//        mapping.addAttributeMappingsFromDictionary(self.requestMappingDictionary() as [NSObject : AnyObject])
//        return mapping
//    }
//    
//    func responseMapping() -> RKObjectMapping {
//        let mapping = RKObjectMapping(forClass: entityClass())
//        mapping.addAttributeMappingsFromDictionary(self.responseMappingDictionary() as [NSObject : AnyObject])
//        return mapping
//    }
//    
//    func setApiToken(manager:RKObjectManager) {
//        manager.HTTPClient.setAuthorizationHeaderWithToken("")
//    }
//    
//    func presentErrorMessage(error:NSError, operation:RKObjectRequestOperation) {
//        let delegate = self.appDelegate()
//        
//        if(error.domain == NSURLErrorDomain) {
//            delegate.displayError(error.localizedDescription)
//        } else if (operation.HTTPRequestOperation.response.statusCode == 400 || operation.HTTPRequestOperation.response.statusCode == 403) {
//            delegate.displayError("Something went wrong, please try again later.")
//        } else if (operation.HTTPRequestOperation.response.statusCode == 401) {
//            delegate.displayError("Authentication failed, please try again")
//        } else {
//            let data = error.userInfo as NSDictionary!
//            let errorMessage = data[RKObjectMapperErrorObjectsKey]?.firstObject as! RKErrorMessage
//            delegate.displayError(errorMessage.errorMessage)
//        }
//        
//        delegate.dismissLoading()
//    }
//    
    func apiPrefix() -> String {
        return ""
    }
    
    func apiKey() -> String {
        return ""
    }
    
//    func fetch(id:String) {
//        let manager = RKObjectManager.sharedManager()
//        manager.HTTPClient.setAuthorizationHeaderWithToken(self.appDelegate().getAccessToken())
//        manager.getObjectsAtPath("\(self.apiPrefix())\(self.pluralKeyName())/\(id).json", parameters: ["api_key": self.apiKey()], success: {(operation: RKObjectRequestOperation!, result:RKMappingResult!) -> Void in
//            if(self.delegate != nil) {
//                self.delegate?.itemFetched!(result.firstObject() as! BaseEntity)
//            }
//            }, failure: {(operation: RKObjectRequestOperation!, error:NSError!) -> Void in
//                self.presentErrorMessage(error, operation: operation)
//        })
//    }
//    
//    func fetchAll() {
//        let manager = RKObjectManager.sharedManager()
//        manager.HTTPClient.setAuthorizationHeaderWithToken(self.appDelegate().getAccessToken())
//        manager.getObjectsAtPath("\(self.apiPrefix())\(self.pluralKeyName()).json", parameters: ["api_key": self.apiKey()], success: {(operation: RKObjectRequestOperation!, result:RKMappingResult!) -> Void in
//            let items = result.array()
//            self.delegate?.itemsFetched!(items!)
//            }, failure: {(operation: RKObjectRequestOperation!, error:NSError!) -> Void in
//                self.presentErrorMessage(error, operation: operation)
//        })
//    }
//    
//    func deleteEntity(entity:BaseEntity) {
//        let manager = RKObjectManager.sharedManager()
//        
//        manager.deleteObject(entity, path: "\(self.apiPrefix())\(self.pluralKeyName())/\(entity.remoteId).json", parameters: ["api_key": self.apiKey()], success: {(operation: RKObjectRequestOperation!, result:RKMappingResult!) -> Void in
//            if(self.delegate != nil) {
//                self.delegate?.itemDeleted!()
//            }
//            }, failure: {(operation: RKObjectRequestOperation!, error:NSError!) -> Void in
//                self.presentErrorMessage(error, operation: operation)
//        })
//    }
//    
//    func addNestedRequestMappings(mapping:RKObjectMapping) {
//        // Optional
//    }
//    
//    func addNestedResponseMappings(mapping:RKObjectMapping) {
//        // Optional
//    }
    
    func entityClass() -> AnyClass {
        fatalError("This method must be overriden")
    }
    
    func keyName() -> String {
        fatalError("This method must be overriden")
    }
    
    func pluralKeyName() -> String {
        fatalError("This method must be overriden")
    }
    
    func requestMappingDictionary() -> NSDictionary {
        fatalError("This method must be overriden")
    }
    
    func responseMappingDictionary() -> NSDictionary {
        fatalError("This method must be overriden")
    }
    
    func attributesLabels() -> NSDictionary {
        fatalError("This method must be overriden")
    }
    
    func showObjectErrors(error: NSError) {
        let data = error.localizedRecoverySuggestion?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        var jsonResponse = NSDictionary()

        do {
            try jsonResponse = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        } catch {
        
        }
        print(jsonResponse)
//        self.appDelegate().displayError(jsonResponse["message"] as! String)
    }
}