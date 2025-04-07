//
//  UserPreference.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct UserMuthu<T> {
    
    let defaultsKey: String
    let defaultValue: T
    
    // TODO: Add a description field that can be used as a label tooltip in the Preferences UI ???
    
    var value: T {
        
        get {
            userDefaults.object(forKey: defaultsKey) as? T ?? defaultValue
        }
        
        set {
            userDefaults.setValue(newValue, forKey: defaultsKey)
        }
    }
}

extension UserMuthu where T: RawRepresentable {
    
    var value: T {
        
        get {
            
            if let rawValue = userDefaults.object(forKey: defaultsKey) as? T.RawValue {
                return T(rawValue: rawValue) ?? defaultValue
            }
            
            return defaultValue
        }
        
        set {
            userDefaults.setValue(newValue.rawValue, forKey: defaultsKey)
        }
    }
}

struct OptionalMuthu<T> {
    
    let defaultsKey: String
    
    var value: T? {
        
        get {
            userDefaults.object(forKey: defaultsKey) as? T
        }
        
        set {
            userDefaults.setValue(newValue, forKey: defaultsKey)
        }
    }
}

extension OptionalMuthu where T == URL {
    
    var value: T? {
        
        get {
            
            if let path = userDefaults.string(forKey: defaultsKey) {
                return URL(fileURLWithPath: path)
            }
            
            return nil
        }
        
        set {
            userDefaults.setValue(newValue?.path, forKey: defaultsKey)
        }
    }
}
