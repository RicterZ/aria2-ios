//
//  File.swift
//  aria2-ios
//
//  Created by Ricter Zheng on 2017/2/4.
//  Copyright © 2017年 Ricter Zheng. All rights reserved.
//

import Foundation
import RealmSwift


extension Results {
    
    func toArray() -> [T] {
        return self.map{$0}
    }
}

extension RealmSwift.List {
    
    func toArray() -> [T] {
        return self.map{$0}
    }
}

class Aria2Server: Object {
    dynamic var id: String = ""
    dynamic var url: String = ""
    dynamic var secret_key: String = ""
}


class DownloadItem: NSObject {
    var gid: String = ""
    var totalLength: Int = 0
    var title: String = ""
}

class DownloadDetail: NSObject {
    var gid: String = ""
    var totalLength: String = ""
    var completedLength: String = ""
    var downloadSpeed: String = ""
    
    var dir: String = ""
    var bitfield: String = ""
    
    var files: [String] = []
}
