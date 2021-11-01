//
//  network.swift
//  stripe_ios
//
//  Created by cedcoss on 01/11/21.
//

import Foundation
import UIKit
import SwiftyJSON

public class network{
    public static func sendPaymentHttpRequest(endPoint : String, method: String, params: [String:String], controller: UIViewController, completion: @escaping (Data?, String, Error) -> () ){
        let baseRequestUrl = appSetting.appBaseURL + endPoint;
        var makeRequest = URLRequest(url: URL(string: baseRequestUrl)!)
        makeRequest.httpMethod = method
        var postData = ""
        if(params.count>0){
            for (key,value) in params
            {
                postData+="&"+key+"="+value
            }
            postData+="&ced_mage_api=mobiconnect"
            makeRequest.httpBody = postData.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        }
        makeRequest.setValue(appSetting.headerKey, forHTTPHeaderField: "uid")
        let storeid = appSetting.storeID as String
        makeRequest.setValue(storeid, forHTTPHeaderField: "langid");
        print(baseRequestUrl)
        print(postData)
        
        let task = URLSession.shared.dataTask(with: makeRequest, completionHandler: {data,response,error in
            // check for http errors
            
            if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200
            {
                
                DispatchQueue.main.async{
                    showErrorPopUp(withTitle: "Error \(httpStatus.statusCode)", message: "", controller: controller)
                }
                return;
            }
            guard error == nil && data != nil else
            {
                DispatchQueue.main.async
                {
                    
                    let AlertBckView = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    let OkAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: nil)
                    AlertBckView.addAction(OkAction)
                    
                    controller.present(AlertBckView, animated: true, completion: nil)
                }
                return ;
            }
            
            DispatchQueue.main.async
            {
                _ =  completion(data, endPoint, error!)
            }
            
        })
        task.resume()
    }
    
    public static func showErrorPopUp(withTitle title: String?, message : String?, controller: UIViewController) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(OKAction)
            controller.present(alertController, animated: true, completion: nil)
        }
    }
}

public struct appSetting{
    public static var appBaseURL = "https://ugover.com/wp-json/"
    public static var headerKey = "mobiconnect123"
    public static var storeID = ""
}
