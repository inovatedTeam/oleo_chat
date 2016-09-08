//
//  TranslationInteractor.swift
//  READY
//
//  Created by Patrick Sheehan on 11/19/15.
//  Copyright © 2015 Siochain. All rights reserved.
//

import UIKit
import SwiftyJSON

class TranslationInteractor: NSObject {
    
    
    class func translate(text: String, sourceLanguage: Language, targetLanguage: Language, completion: (error: NSError?, translatedText: String) -> Void) {
        
        // Build URL
        let sourceText = text.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let urlComponents = NSURLComponents(string: Constants.GoogleApi.Translate.BaseUrl)!
        urlComponents.queryItems = [
            NSURLQueryItem(name: "q", value: sourceText),
            NSURLQueryItem(name: "target", value: targetLanguage.code),
            NSURLQueryItem(name: "format", value: "text"),
            NSURLQueryItem(name: "source", value: sourceLanguage.code),
            NSURLQueryItem(name: "key", value: Constants.GoogleApi.Translate.APIKey)
        ]
        let url: NSURL = urlComponents.URL!
        print("URL: \(url)")
        
        // Execute API call
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) -> Void in

            if let e = error {
                print("An internal error occurred while sending a NSURLSession data task: \(e.localizedDescription)")
                completion(error: e, translatedText: "(Failed to translate)")
            }
            
            // Check HTTP Response code
            if let httpResponse = response as? NSHTTPURLResponse {
                print("Status code: (\(httpResponse.statusCode))")
                print("HTTP response:\(httpResponse)")
                
                
                // Decode the JSON data
                let json = JSON(data: data!)
                print("JSON: \(json)")
                
                if let translatedText = json["data"]["translations"][0]["translatedText"].string {
                    print("SUCCESS: Translated response Data into JSON with translated text: \(translatedText)")
                    completion(error: nil, translatedText: translatedText)
                }
                else {
                    print("FAILURE: Could not encode response into necessary JSON")
                    completion(error: NSError(domain: "Failed to encode response into the JSON needed", code: 0, userInfo: nil), translatedText: "(Failed to translate)")
                }
   
            }
        }
        task.resume()
        
    }
}
