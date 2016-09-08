//
//  CustomStringLocalization.swift
//  ready
//
//  Created by Patrick Sheehan on 4/24/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import UIKit

class CustomStringLocalization: NSObject {

    class func textForKey(key: String) -> String {
        
        let langInt = NSUserDefaults.standardUserDefaults().integerForKey("target_language")
        var language = Language(rawValue: langInt)
        if language == nil {
            language = Language.English
        }
        
        return textForKey(key, lang: language!)

    }
    
    class func setTargetLanguage(lang: Language) {
        
        print("CustomStringLocalization setting target language to: \(lang)")
        NSUserDefaults.standardUserDefaults().setValue(lang.rawValue, forKey: "target_language")
        
    }
    
    class func textForKey(key: String, lang: Language) -> String {
        
        let language = lang.code
        if let path = NSBundle.mainBundle().pathForResource(language, ofType: "lproj") {
            let bundle = NSBundle(path: path)
            let text = bundle?.localizedStringForKey(key, value: nil, table: nil)
            
            
            print("Localized text of key '\(key)' is '\(text!)'")
        
            return text!
        }
        
        print("Failed to find localized version of \(key)")
        return key
    }

}
