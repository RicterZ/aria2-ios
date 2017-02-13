//
//  Aria2SDK.swift
//  aria2-ios
//
//  Created by Ricter Zheng on 2017/2/13.
//  Copyright © 2017年 Ricter Zheng. All rights reserved.
//

import Foundation
import Alamofire




class Aria2SDK {
    static var server: Aria2Server? = nil

    static func base64(s: String) -> String {
        let utf8str = s.data(using: String.Encoding.utf8)
        return (utf8str?.base64EncodedString())!
    }
    
    static func request(param: Parameters, callback: @escaping (Any) -> Void) {

        Alamofire.request(server!.url, method: .post, parameters: param, encoding: JSONEncoding.default).responseJSON { resp in
            if resp.response != nil {
                let result = (resp.result.value as! Dictionary<String, Any>)["result"]
                callback(result!)
            }
        }
    }
    
    static func getServerOptions(callback: @escaping (Any) -> Void) {
        let parameters: Parameters = [
            "jsonrpc": "2.0",
            "method": "aria2.getGlobalOption",
            "id": 1,
            "params": []
        ]
        
        request(param: parameters, callback: callback)
    }
    
    static func tellActive(callback: @escaping (Any) -> Void) {
        let parameters: Parameters = [
            "jsonrpc": "2.0",
            "method": "aria2.tellActive",
            "id": 1
        ]
        
        request(param: parameters, callback: callback)
    }

    static func tellStopped(callback: @escaping (Any) -> Void) {
        let parameters: Parameters = [
            "jsonrpc": "2.0",
            "method": "aria2.tellStopped",
            "id": 1,
            "params": [0,1000]
        ]
        
        request(param: parameters, callback: callback)
    }

    static func tellWaiting(callback: @escaping (Any) -> Void) {
        let parameters: Parameters = [
            "jsonrpc": "2.0",
            "method": "aria2.tellWaiting",
            "id": 1,
            "params": [0,1000]
        ]
    
        request(param: parameters, callback: callback)
    }
    
    static func tellStatus(gid: String, callback: @escaping (Any) -> Void) {
        let parameters: Parameters = [
            "jsonrpc": "2.0",
            "method": "aria2.tellStatus",
            "id": 1,
            "params": [gid]
        ]
        request(param: parameters, callback: callback)
    }
}




