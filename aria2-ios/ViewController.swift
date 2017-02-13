//
//  ViewController.swift
//  aria2-ios
//
//  Created by Ricter Zheng on 2017/2/4.
//  Copyright © 2017年 Ricter Zheng. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class AddAria2ServerViewController: UITableViewController {

    
    @IBOutlet weak var serverAddressText: UITextField!
    @IBOutlet weak var secretText: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func addServer(_ sender: Any) {
        let realm = try! Realm()
        let s = Aria2Server()
        s.id = UUID.init().uuidString
        s.url = serverAddressText.text!
        s.secret_key = secretText.text!
        
        try! realm.write {
            realm.add(s)
        }
        
        self.navigationController!.popViewController(animated: true)
    }

}



class EditServerInfoViewController: UITableViewController {
    
    var server: Aria2Server? = nil
    var serverInfo: [String: String]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Aria2SDK.server = server
        Aria2SDK.getServerOptions {result in
            self.serverInfo = (result as! [String: String])
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let k = Array(serverInfo!.keys)[indexPath.section]
        let v = serverInfo![k]

        let cell = tableView.dequeueReusableCell(withIdentifier: "serverInfoCell", for: indexPath)
        cell.textLabel?.text = v
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(serverInfo!.keys)[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return serverInfo?.count ?? 0
    }
}


class ListDownloadItemViewController: UITableViewController {

    @IBOutlet weak var edit: UIBarButtonItem!
    @IBOutlet var editserver: UITableView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    var server: Aria2Server? = nil
    var downloading: [DownloadItem] = []
    var waitting: [DownloadItem] = []
    var downloaded: [DownloadItem] = []
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let c = segue.destination as! EditServerInfoViewController
        c.server = server
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loading.hidesWhenStopped = true
        loading.startAnimating()
    
        Aria2SDK.server = server

        Aria2SDK.tellActive {result in
            for row in result as! Array<Any> {
                let tmp = row as! Dictionary<String, Any>
                let d = DownloadItem()
                d.gid = tmp["gid"] as! String
                d.totalLength = (tmp["totalLength"] as! NSString).integerValue

                let path = (((tmp["files"] as! NSArray).firstObject) as! Dictionary<String, Any>)["path"] as! String
                let title = NSURL.fileURL(withPath: path).lastPathComponent
                d.title = title
                self.downloading.append(d)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        Aria2SDK.tellWaiting { result in
            for row in result as! Array<Any> {
                let tmp = row as! Dictionary<String, Any>
                let d = DownloadItem()
                d.gid = tmp["gid"] as! String
                d.totalLength = (tmp["totalLength"] as! NSString).integerValue
                
                let path = (((tmp["files"] as! NSArray).firstObject) as! Dictionary<String, Any>)["path"] as! String
                let title = NSURL.fileURL(withPath: path).lastPathComponent
                d.title = title
                self.waitting.append(d)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        Aria2SDK.tellStopped { result in
            for row in result as! Array<Any> {
                let tmp = row as! Dictionary<String, Any>
                let d = DownloadItem()
                d.gid = tmp["gid"] as! String
                d.totalLength = (tmp["totalLength"] as! NSString).integerValue
                
                let path = (((tmp["files"] as! NSArray).firstObject) as! Dictionary<String, Any>)["path"] as! String
                let title = NSURL.fileURL(withPath: path).lastPathComponent
                d.title = title
                self.downloaded.append(d)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            self.loading.stopAnimating()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Downloading Item"
        } else if section == 1 {
            return "Wait For Download item"
        } else {
            return "Downloaded Item"
        }
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return downloading.count != 0 ? downloading.count : 1
        } else if section == 1 {
            return waitting.count != 0 ? waitting.count : 1
        } else {
            return downloaded.count != 0 ? downloaded.count : 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadCell", for: indexPath)
        let s: String
        if indexPath.section == 0 {
            if downloading.count == 0 {
                s = "NO DATA"
            } else {
                s = downloading[indexPath.row].title
            }
        } else if indexPath.section == 1 {
            if waitting.count == 0 {
                s = "NO DATA"
            } else {
                s = waitting[indexPath.row].title
            }
        } else {
            if downloaded.count == 0 {
                s = "NO DATA"
            } else {
                s = downloaded[indexPath.row].title
            }
        }
        cell.textLabel?.text = s

        return cell
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "downloadDetail") as! DownloadDetailViewController
        controller.server = server
        
        let gid: String
        if indexPath.section == 0 {
            gid = downloading[indexPath.row].gid
        } else if indexPath.section == 1 {
            gid = waitting[indexPath.row].gid
        } else {
            gid = downloaded[indexPath.row].gid
        }
        
        controller.gid = gid
        navigationController?.pushViewController(controller, animated: true)
    }
    
}



class ListServerViewController: UITableViewController {
    
    var servers: [Aria2Server] = []
    @IBOutlet weak var serverTable: UITableView!
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        let s = servers[indexPath.row]
        
        cell.textLabel?.text = s.url
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        let realm = try! Realm()
        let s = realm.objects(Aria2Server.self).filter("id = '\(servers[indexPath.row].id)'").first!

        servers.remove(at: indexPath.row)
        
        try! realm.write {
            realm.delete(s)
        }
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView,titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "download") as! ListDownloadItemViewController
        controller.server = self.servers[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let realm = try! Realm()
        servers = realm.objects(Aria2Server.self).toArray()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        autoreleasepool {
            // all Realm usage here
        }
        let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
        let realmURLs = [
            realmURL,
            realmURL.appendingPathExtension("lock"),
            realmURL.appendingPathExtension("note"),
            realmURL.appendingPathExtension("management")
        ]
        for URL in realmURLs {
            do {
                try FileManager.default.removeItem(at: URL)
            } catch {
                // handle error
            }
        }
        */
    }
}

class DownloadDetailViewController: UITableViewController {

    var server: Aria2Server? = nil
    var gid: String? = nil
    var downloadInfo: DownloadDetail? = nil
    
    func getLength(number: Double) -> String {
        var tmp: Double = number
        var unit: String = "Byte"

        if number > 1024 {
            tmp = tmp / 1024.0
            unit = "KB"
        }
        if tmp > 1024 {
            tmp = tmp / 1024.0
            unit = "MB"
        }
        if tmp > 1024 {
            tmp = tmp / 1024.0
            unit = "GB"
        }
        
        let s = NSString(format: "%.2f", tmp) as String
        return "\(s) \(unit)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadInfo = DownloadDetail()
        
        Aria2SDK.server = server
        Aria2SDK.tellStatus(gid: gid!) {result in

            let data = result as! Dictionary<String, Any>
            self.downloadInfo!.gid = data["gid"] as! String
            self.downloadInfo!.bitfield = data["bitfield"] as! String
            self.downloadInfo!.dir = data["dir"] as! String

            self.downloadInfo!.completedLength = self.getLength(number: Double((data["completedLength"] as! NSString).intValue))
            self.downloadInfo!.totalLength = self.getLength(number: Double((data["totalLength"] as! NSString).intValue))
            self.downloadInfo!.downloadSpeed = self.getLength(number: Double((data["downloadSpeed"] as! NSString).intValue))
            
            for file in data["files"] as! [Dictionary<String, Any>] {
                let filename = NSURL.fileURL(withPath: (file["path"] as! String)).lastPathComponent
                self.downloadInfo!.files.append(filename)
            }
            
            print(result)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section < 4 ? 1 : downloadInfo!.files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let order = [
            downloadInfo!.gid,
            downloadInfo!.dir,
            "\(downloadInfo!.completedLength) / \(downloadInfo!.totalLength)",
            "\(downloadInfo!.downloadSpeed) / s",
            downloadInfo!.files
        ] as [Any]
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadDetailCell", for: indexPath)
        
        print(downloadInfo!.completedLength)
        
        if indexPath.section != 4 {
            cell.textLabel?.text = (order[indexPath.section] as! String)
        } else {
            cell.textLabel?.text = downloadInfo!.files[indexPath.row] 
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["GID", "Save Path", "Complete / Total", "Speed", "Files list"][section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    

}
