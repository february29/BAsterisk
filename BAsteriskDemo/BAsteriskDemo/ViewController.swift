//
//  ViewController.swift
//  BAsteriskDemo
//
//  Created by bai on 2019/7/1.
//  Copyright © 2019 北京仙指信息技术有限公司. All rights reserved.
//

import UIKit

let MeetingLoginPar = ["C001":"fchmanager001",
                       "C002":"fchmanager002",
                       "C003":"fchmanager003",
                       "C004":"fchmanager004"]

let MeetingHost = "your host";
let MeetingPort = 6038
let MeetingPassword = "password"

class ViewController: UIViewController {
    
    
    public var meettingNo:String?
    //TCP 长链接管理
    var asteriskManager:AsteriskManager = AsteriskManager();

    override func viewDidLoad() {
        super.viewDidLoad()
        
        meettingNo = "C002"
        
        asteriskManager.delegate = self;
        self.asteriskManager.socketConnect(toHost: MeetingHost, onPort: MeetingPort);
        
    }


}

extension ViewController:AsteriskManagerDelegate{
    
    // MARK: AsteriskManagerDelegate
    
    func asteriskSocketDidConnect(_ asterisk: AsteriskManager, toHost host: String, port: UInt16) {
        self.asteriskManager.login(userName: MeetingLoginPar[self.meettingNo!]!, password: MeetingPassword);
    }
    
    func asteriskSocketDidDisconnect(_ asterisk: AsteriskManager, withError err: Error?) {
        
    }
    
    func asterisk(_ asterisk: AsteriskManager, didRecivedEvent event: AsteriskEvent?) {
        print("didRecivedEvent:\(event?.Event ?? "")\n\(String(describing: event))")
        
        let eventType = event?.eventType()
        
        if eventType == .ConfbridgeJoin  {
           
            
            
        }else if eventType == .ConfbridgeLeave{
           
            
        }else if eventType == .ConfbridgeUnmute{
           
            
            
        }else if eventType == .ConfbridgeMute{
           
            
        }
        
    }
    
    func asterisk(_ asterisk: AsteriskManager, didRecivedResponse response: AsteriskResponse?) {
        print("didRecivedResponse")
       
        
    }
    
    func asterisk(_ asterisk: AsteriskManager, didRecivedMessage message: AsteriskMessage?) {
        print("didRecivedMessage")
    }
    
    func asterisk(_ asterisk: AsteriskManager, didRecivedUnknown data: Data) {
        print("didRecivedUnknown")
    }
    
    
}

