//
//  SLNetworkManager.swift
//  NetworkKit
//
//  Created by Madhusudhan, Srikanth on 10/7/15.
//  Copyright © 2015 Madhusudhan, Srikanth. All rights reserved.
//

import Foundation

class RESTClient {
    
    func GET(url:String, parameters:[String:AnyObject]?, completionHandler:((response:AnyObject?, error:NSError?)  -> Void)) {
        let completeURL = URL(string: "\(url)?\(parameters?.stringFromHttpParameters() ?? "")")!
        let session = URLSession(configuration: URLSessionConfiguration.default())
        session.dataTask(with: completeURL) { (data, urlResponse, error) in
            if let d = data where error == nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.mutableContainers)
                    completionHandler(response: json, error: nil)
                } catch {}
            } else {
                completionHandler(response: nil, error: error)
            }
        }.resume()
    }
    
    func DOWNLOAD(url:String, parameters:[String:AnyObject]?, completionHandler:((response:Data?, error:NSError?)  -> Void)) {
        let completeURL = URL(string: "\(url)?\(parameters?.stringFromHttpParameters() ?? "")")!
        let session = URLSession(configuration: URLSessionConfiguration.default())
        session.dataTask(with: completeURL) { (data, response, error) in
            if let d = data where error == nil {
                completionHandler(response: d, error: nil)
            } else {
                completionHandler(response: nil, error: error)
            }
        }.resume()
    }
}

extension String {
    
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return  self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
}

extension Dictionary {
    
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).stringByAddingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
    
}
