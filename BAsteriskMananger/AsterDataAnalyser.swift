//
//  AsterDataAnalyser.swift
//  linphone_Fch
//
//  Created by bai on 2018/7/18.
//

import UIKit

enum AsteriskPacketType {
    case action
    case event
    case response
    case message
    case unknown
    
    func packetTypeStr() -> String {
        if self == .action {
            return "action";
        }else if self == .event {
            return "event";
        }else if self == .response {
            return "response";
        }else if self == .message {
            return "message";
        }else {
            return "unknown";
        }
    }
}

enum AsteriskEventType {
    case ConfbridgeStart //会议开始
    case ConfbridgeJoin //成员进入
    case ConfbridgeLeave //成员退出
    case ConfbridgeEnd //会议结束
    case ConfbridgeUnmute //取消静音
    case ConfbridgeMute //静音
    case unknown
}

class AsteriskResponse{
    var Response:String? // login Success or Error
}

class AsteriskMessage{
    var Message:String?
}

class AsteriskEvent {
    var Event:String?
    var Privilege:String?
    var Conference:String?
    var BridgeUniqueid:String?
    var BridgeType:String?
    var BridgeTechnology:String?
    var BridgeCreator:String?
    var BridgeName:String?
    var BridgeNumChannels:String?
    var BridgeVideoSourceMode:String?
    var Channel:String?
    var ChannelState:String?
    var ChannelStateDesc:String?
    var CallerIDNum:String?
    var CallerIDName:String?
    var ConnectedLineNum:String?
    var ConnectedLineName:String?
    var Language:String?
    var AccountCode:String?
    var Context:String?
    var Exten:String?
    var Priority:String?
    var Uniqueid:String?
    var Linkedid:String?
    var Admin:String?
    
    
    func isAdmin() -> Int {
        guard let temp = Admin else {return 0}
        if temp.hasSuffix("Yes") {
            return 1;
        }else{
            return 0;
        }
    }
    
    func eventType() -> AsteriskEventType {
       
        guard let temp = Event else {return .unknown}
        
        if temp.hasSuffix("ConfbridgeStart")  {
            return .ConfbridgeStart
        }else if temp .hasSuffix("ConfbridgeJoin"){
            return .ConfbridgeJoin;
        }else if temp .hasSuffix("ConfbridgeLeave"){
            return .ConfbridgeLeave
        }else if temp .hasSuffix("ConfbridgeEnd"){
            return .ConfbridgeEnd
        }else if temp .hasSuffix("ConfbridgeUnmute") {
            return .ConfbridgeUnmute
        }else if temp .hasSuffix("ConfbridgeMute"){
            return .ConfbridgeMute
        }else{
            return .unknown
        }
        
    }
   
}



class AsterDataAnalyser: NSObject {

    
    func asteriskPacketType(data:Data) -> AsteriskPacketType {
      
        let tempStr = String(data: data, encoding: .utf8);
        guard let temp = tempStr else {return .unknown}
        if temp.hasPrefix("Action") {
            return .action
        }else if temp.hasPrefix("Event"){
            return .event;
        }else if temp.hasPrefix("Response"){
            return .response
        }else if temp.hasPrefix("Message"){
            return .message
        }else{
            return .unknown
        }
    }
    

    
    func asteriskEvent(data:Data) -> AsteriskEvent?{
        if self.asteriskPacketType(data: data) != .event {
            return nil;
        }
        let tempStr = String(data: data, encoding: .utf8);
        guard let temp = tempStr else {return nil}
        
        let event = AsteriskEvent()
        let str =  temp.replacingOccurrences(of: "\r", with: "");
        let keyVauleArray = str.components(separatedBy: "\n");
        
        
        for item in keyVauleArray {
            guard let idx = item.index(of: ":")else{ continue };
            let key = item.prefix(upTo: idx)
            let idx2 = item.index(idx, offsetBy: 1);
            let value = item.suffix(from: idx2)
            let itemArray = [String(key),String(value)];
            
//            let itemArray = item.components(separatedBy: ":");
            
            if itemArray.count != 2{
                continue;
            }else{
                if itemArray[0] == "Event" {
                    event.Event = itemArray[1].trimmed();
                }else if itemArray[0] == "Privilege" {
                    event.Privilege = itemArray[1].trimmed();
                }else if itemArray[0] == "Conference" {
                    event.Conference = itemArray[1].trimmed();
                }else if itemArray[0] == "BridgeUniqueid" {
                    event.BridgeUniqueid = itemArray[1].trimmed();
                }else if itemArray[0] == "BridgeType" {
                    event.BridgeType = itemArray[1].trimmed();
                }else if itemArray[0] == "BridgeTechnology" {
                    event.BridgeTechnology = itemArray[1].trimmed();
                }else if itemArray[0] == "BridgeCreator" {
                    event.BridgeCreator = itemArray[1].trimmed();
                }else if itemArray[0] == "BridgeName" {
                    event.BridgeName = itemArray[1].trimmed();
                }else if itemArray[0] == "BridgeNumChannels" {
                    event.BridgeNumChannels = itemArray[1].trimmed();
                }else if itemArray[0] == "BridgeVideoSourceMode" {
                    event.BridgeVideoSourceMode = itemArray[1].trimmed();
                }else if itemArray[0] == "Channel" {
                    event.Channel = itemArray[1].trimmed();
                }else if itemArray[0] == "ChannelState" {
                    event.ChannelState = itemArray[1].trimmed();
                }else if itemArray[0] == "ChannelStateDesc" {
                    event.ChannelStateDesc = itemArray[1].trimmed();
                }else if itemArray[0] == "CallerIDNum" {
                    event.CallerIDNum = itemArray[1].trimmed();
                }else if itemArray[0] == "CallerIDName" {
                    event.CallerIDName = itemArray[1].trimmed();
                }else if itemArray[0] == "ConnectedLineNum" {
                    event.ConnectedLineNum = itemArray[1].trimmed();
                }else if itemArray[0] == "ConnectedLineName" {
                    event.ConnectedLineName = itemArray[1].trimmed();
                }else if itemArray[0] == "Language" {
                    event.Language = itemArray[1].trimmed();
                }else if itemArray[0] == "AccountCode" {
                    event.AccountCode = itemArray[1].trimmed();
                }else if itemArray[0] == "Context" {
                    event.Context = itemArray[1].trimmed();
                }else if itemArray[0] == "Exten" {
                    event.Exten = itemArray[1].trimmed();
                }else if itemArray[0] == "Priority" {
                    event.Priority = itemArray[1].trimmed();
                }else if itemArray[0] == "Uniqueid" {
                    event.Uniqueid = itemArray[1].trimmed();
                }else if itemArray[0] == "Linkedid" {
                    event.Linkedid = itemArray[1].trimmed();
                }else if itemArray[0] == "Admin" {
                    event.Admin = itemArray[1].trimmed();
                }else{
                    
                }
            }
        }
        return event;
        
    }
    
    func asteriskMessage(data:Data) -> AsteriskMessage?{
        if self.asteriskPacketType(data: data) != .message {
            return nil;
        }
        let tempStr = String(data: data, encoding: .utf8);
        guard let temp = tempStr else {return nil}
        
        let message = AsteriskMessage()
        let str =  temp.replacingOccurrences(of: "\r", with: "");
        let keyVauleArray = str.components(separatedBy: "\n");
        
        for item in keyVauleArray {
            let itemArray = item.components(separatedBy: ":");
            if itemArray.count != 2{
                continue;
            }else{
                if itemArray[0] == "Message" {
                    message.Message = itemArray[1].trimmed();
                }else{
                    
                }
            }
        }
        return message;
        
    }
    
    
    func asteriskResponse(data:Data) -> AsteriskResponse?{
        if self.asteriskPacketType(data: data) != .response {
            return nil;
        }
        let tempStr = String(data: data, encoding: .utf8);
        guard let temp = tempStr else {return nil}
        
        let response = AsteriskResponse()
        let str =  temp.replacingOccurrences(of: "\r", with: "");
        let keyVauleArray = str.components(separatedBy: "\n");
        
        for item in keyVauleArray {
            let itemArray = item.components(separatedBy: ":");
            if itemArray.count != 2{
                continue;
            }else{
                if itemArray[0] == "Response" {
                    response.Response = itemArray[1].trimmed();
                }else{
                    
                }
            }
        }
        return response;
        
    }
    
    
   
    
}
