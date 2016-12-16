//
//  GSON.swift
//  Web
//  Original source code found at Github Arrow
//  Created by Sumeet Kumar on 16/12/2016.
//  Copyright © 2016 Sumeet.Kumar. All rights reserved.
//
//

import Foundation

/**
 JSON Helper class that parse string response to JSON
 Simple JsonObject and JsonArray Parser
 It provives a way to access JSON values via subscripting
 */
open class GSON {
    
    /// This is the raw data of the JSON
    open var json: Any?
    
    /// This build a JSON object with raw data.
    public init?(_ json: Any?) {
        guard json != nil else {
            return nil
        }
        self.json = json
    }
    
    public static func with(_ data: Data) -> GSON {
        let jsonArray = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
        
        return GSON.init(jsonArray)!
    }
    
    public func debug() {
        print("GSON", json!)
    }
    
    /**
     Get JSON array
     */
    open func JsonArray() -> [GSON]?{
        
        guard let a = json as? [Any] else {
            return nil
        }
        return a.map { GSON($0) }.flatMap {$0}
    }
    
    
    /**
     Get JSON Object
     */
    open func JsonObject() -> GSON?{
        if let json = self[0] {
            return json
        }
        return self
    }
    
    open func getJsonObject() -> GSON? {
        return JsonObject()
    }
    
    open func get(_ key: String) -> String
    {
        if let str = self[key]?.json as? String {
            return str
        }
        return ""
    }
    
    open func getBool(_ key: String) -> Bool
    {
        if let b = self[key]?.json as? Bool {
            return b
        }
            // if the given data type is not bool try to get as string and parse it as Boolean value
        else if let i = Bool(get(key).lowercased()) {
            return i
        }
        return false
    }
    
    open func getInt(_ key: String) -> Int
    {
        if let num = self[key]?.json as? Int {
            return num
        }
            // if the given data type is not integer try to get as string and parse it as integer
        else if let i = Int(get(key)) {
            return i
        }
        return -1
    }
    
    open func isNotNull() -> Bool
    {
        if self.json != nil {
            return true
        }
        return false
    }
    
    
    public func success() -> Int {
        
        if let c = Int(get("ResponseCode")) {
            return c
        }
        return -1
        
    }
    
    open func code() -> Int{
        return success()
    }
    
    func hasKey(_ key: String) -> Bool {
        return key.characters.split {$0 == "."}.count > 1
    }
    
    func parseKey(_ keyPath: String) -> GSON? {
        if var intermediateValue = GSON(json) {
            for k in keysForKeyPath(keyPath) {
                if !tryParseJSONKey(k, intermediateValue: &intermediateValue) {
                    return nil
                }
            }
            return intermediateValue
        }
        return nil
    }
    
    func keysForKeyPath(_ keyPath: String) -> [String] {
        return keyPath.characters.split {$0 == "."}.map(String.init)
    }
    
    func tryParseJSONKey(_ key: String, intermediateValue: inout GSON) -> Bool
    {
        if let ik = Int(key), let value = intermediateValue[ik]
        {
            intermediateValue = value
        }
        else if let value = intermediateValue[key]
        {
            intermediateValue = value
        }
        else
        {
            return false
        }
        return true
    }
    
    func regularParsing(_ key: String) -> GSON? {
        guard let d = json as? [String: Any], let x = d[key], let gson = GSON(x) else {
            return nil
        }
        return gson
    }
    
    open subscript(key: String) -> GSON? {
        get { return hasKey(key) ? parseKey(key) : regularParsing(key) }
        set(obj) {
            if var d = json as? [String:Any] {
                d[key] = obj
            }
        }
    }
    
    open subscript(index: Int) -> GSON? {
        get {
            guard let array = json as? [Any], array.count > index else {
                return nil
            }
            return GSON(array[index])
        }
    }
}


/// USAGE
/*
 
 
 // array
 if let array = json.JsonArray
 {
 for jsonObject in array {
 }
 }
 
 // get object at postion
 JsonObject json = GSON.JsonObject() // from array to obj
 
 var str: String = gson[0]?["PicURl"]?.data as! String
 */



