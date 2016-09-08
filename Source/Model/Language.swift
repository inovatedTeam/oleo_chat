//
//  Language.swift
//  ready
//
//  Created by Patrick Sheehan on 1/16/16.
//  Copyright © 2016 Siochain. All rights reserved.
//

import Foundation


/*
 
 English
 en
 United-States-of-America.png
 
 */

let dictLanguages: [Language: [String]] = [
    .English : ["English", "en"],
    .Spanish : ["Español", "es"],
    .Catalan : ["Català", "ca"],
    .Persian : ["فارسی", "fa"],
    .Hindi : ["हिंदी", "hi"],
    .Panjabi : ["ਪੰਜਾਬੀ", "pa"],
    .Irish : ["Gaeilge", "ga"],
    .Dutch : ["Nederlands", "nl"],
    .Arabic : ["العربية", "ar"],
    .French : ["Français", "fr"],
    .Danish : ["Dansk", "da"],
    .Korean : ["한국어", "ko"],
    .Turkish : ["Türkçe", "tr"],
    .Albanian : ["Shqip", "sq"],
    .Chinese : ["中国语言", "zh"],
    .Japanese : ["日本語", "ja"],
    .Polish : ["Polski", "pl"]
]

enum Language: Int, CustomStringConvertible {
    
    case English
    case Spanish
    case Catalan
    case Persian
    case Hindi
    case Panjabi
    case Irish
    case Dutch
    case Arabic
    case French
    case Danish
    case Korean
    case Turkish
    case Albanian
    case Chinese
    case Japanese
    case Polish
    
    init(code: String) {
        
        switch (code) {
            
            case "en": self = .English
            case "es": self = .Spanish
            case "ca": self = .Catalan
            case "fa": self = .Persian
            case "hi": self = .Hindi
            case "pa": self = .Panjabi
            case "ga": self = .Irish
            case "nl": self = .Dutch
            case "ar": self = .Arabic
            case "fr": self = .French
            case "da": self = .Danish
            case "ko": self = .Korean
            case "tr": self = .Turkish
            case "sq": self = .Albanian
            case "zh": self = .Chinese
            case "ja": self = .Japanese
            case "pl": self = .Polish
            default: self = .English
        }
        
        
        
    }
    var description: String {
        if let d = dictLanguages[self]?[0] {
            return d
        }
        
        print("ERROR: Attempted to translate name of invalid language: \(self)")
        return "ERROR"
    
    }
    
    var code: String {
        
        if let c = dictLanguages[self]?[1] {
            return c
        }
        
        print("ERROR: Attempted to translate name of invalid language: \(self)")
        return "ERROR"
    }

    static func getLanguageFlag(s: String) -> String {
        
        switch s {
        case "en":
            return "United-States-of-America.png"
            
        case "es":
            return "Spain.png"

        case "ca":
            return "Andorra.png"

        case "fa":
            return "Iran.png"

        case "hi":
            return "India.png"

        case "pa":
            return "Pakistan.png"

        case "ga":
            return "Ireland.png"

        case "ar":
            return "Saudi-Arabia.png"

        case "fr":
            return "France.png"

        case "da":
            return "Denmark.png"

        case "ko":
            return "Korea,-South.png"

        case "tr":
            return "Turkey.png"

        case "sq":
            return "Albania.png"

        case "zh":
            return "China.png"
            
        case "ja":
            return "Japan.png"

        case "nl":
            return "Germany.png"

        default:
            return "United-States-of-America.png"
        }

    }
    static func allValues() -> [Language] {
        
        return [
            .English,
            .Spanish,
            .Catalan,
            .Persian,
            .Hindi,
            .Panjabi,
            .Irish,
            .Dutch,
            .Arabic,
            .French,
            .Danish,
            .Korean,
            .Turkish,
            .Albanian,
            .Chinese,
            .Japanese,
            .Polish
        ]
    }
    
    static func allLanguages() -> [String] {
        
        
        let langs = Language.allValues()
        var strings = [String]()
        for l in langs {
            strings.append(l.description)
        }
        
        return strings
    }
    
}