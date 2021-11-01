//
//  stripeVC.swift
//  stripe_ios
//
//  Created by cedcoss on 01/11/21.
//

import UIKit
import Stripe
import SwiftyJSON

public class stripeVC: UIViewController, STPPaymentCardTextFieldDelegate {
    
    @IBOutlet weak var pay: UIButton!
    
    //TODO: Values required from current project
    var orderId = "1";
    var grandTotal = "100.0"            //default used for testing
    var currencySymbol = "eur"          //default used for testing
    var custID: String? = nil         // logged in user
    var cartID : String? = nil       // not logged in user
    var themeColor: UIColor = .blue;
    var baseUrl = "https://ugover.com/wp-json/"         //default used for testing
    var headerKEY = "mobiconnect123"                    //default used for testing
    var callBackURL = ""
    var publishableKey : String = "pk_test_xJWWQaGnINuH6qQdhNnovRS000nrF5yxSu"      // for testing
    
    let paymentTextField = STPPaymentCardTextField()
    
    //TODO: Comment init methods when using testing values
    init(customerID: String? = nil, cartID: String? = nil, orderID: String, currencyCode: String,amount: String, theme_color: UIColor, appURL: String, headerkey : String, callbackUrl : String, stripePublishableKEy: String ){
        super.init(nibName: nil, bundle: nil)
        self.currencySymbol = currencyCode;
        self.grandTotal = amount;
        self.orderId = orderID;
        self.baseUrl = appURL;
        self.headerKEY = headerkey;
        appSetting.appBaseURL = appURL;
        appSetting.headerKey = headerkey;
        if let customer_id = customerID {
            self.custID = customer_id;
        }
        if let cart_id = cartID {
            self.cartID = cart_id;
        }
        self.themeColor = theme_color;
        self.publishableKey = stripePublishableKEy;
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        // Do any additional setup after loading the view.
    }
    
    func initialSetup(){
        StripeAPI().setDefaultPublishableKey(publishableKey)
        self.paymentTextField.frame = CGRect(x: 15, y: 199, width: self.view.frame.width - 30, height: 44)
        self.paymentTextField.delegate = self
        self.view.addSubview(self.paymentTextField)
        self.pay.addTarget(self, action: #selector(paymentButtonClicked(_:)), for: .touchUpInside);
        self.pay.isHidden = true;
        self.pay.backgroundColor = themeColor;
    }
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        if textField.isValid {
            pay.isHidden = false;
        }
        else
        {
            pay.isHidden = false;
        }
    }
    
    @objc func paymentButtonClicked(_ sender: UIButton)
    {
        let card = paymentTextField.cardParams
        let stpCard = STPCardParams()
        stpCard.number = card.number
        stpCard.cvc = card.cvc
        if let expmonth = card.expMonth as? UInt{
            stpCard.expMonth = expmonth
        }
        if let expyear = card.expYear as? UInt{
            stpCard.expYear = expyear
        }
        STPAPIClient.shared.createToken(withCard: stpCard, completion: {(token, error) -> Void in
            if let error = error {
                print(error)
            }
            else if let token = token {
                print(token)
                self.chargeUsingToken(token: token)
            }})
    }
    
    func chargeUsingToken(token:STPToken) {
        let requestString = callBackURL     //e.g. "mobiconnect/checkout/callbackurl"
        if let amount = Double(grandTotal) {
            let amountInt = Int(amount)
            let params = ["stripeToken": token.tokenId, "amount": "\(amountInt)", "currency": self.currencySymbol, "description": "testRun","order_id":orderId]       // currency as "eur" etc
            print(params);
            
            network.sendPaymentHttpRequest(endPoint: requestString,method: "POST",params: params, controller: self, completion: {
                data,url,error in
                
                guard let data = data else{ return }
                let datastring = NSString(data: data, encoding: String.Encoding.utf8.rawValue);
                print("datastring");
                print(datastring as Any);
                let json = try! JSON(data: data);
                let title = json["status"].stringValue.capitalized
                self.showMessagePopUp(withTitle: title, message: json["message"].stringValue, controller: self)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.paymentCompleted(json: json);
                }
                
            })
            
        }
        
    }
    
    func paymentCompleted(json: JSON)
    {
        if(json["status"].stringValue.lowercased() == "success"){
            var params = Dictionary<String,String>();
            if let userId = custID as? String{
                params["customer_id"] = userId
            }
            else{
                if let cartId = cartID as? String
                {
                    params["cart_id"] = cartId
                }
            }
            
            //TODO: send request for empting cart
            // eg: end point : "mobiconnect/checkout/empty_paypal_cart"
            let endpointURL = "mobiconnect/checkout/empty_paypal_cart"
            network.sendPaymentHttpRequest(endPoint: endpointURL,method: "POST", params:params, controller: self, completion: {
                data,url,error in
                if let data = data {
                    let jsondata  = try! JSON(data:data)
                    print(jsondata)
                    if(true)    // i.e status is success
                    {
                        // TODO: naviagte to orderCompletion page, remove userdefaults object of cart_id, set CartQuantity userdefaults object  to 0
                        
                    }
                    else
                    {
                        //TODO: show toast "Some error occured"
                    }
                    
                }
            })
        }
        else{
            // TODO: naviagte to orderFailed page
        }
    }
    
    
}


extension UIViewController{
     func showMessagePopUp(withTitle title: String?, message : String?, controller: UIViewController) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(OKAction)
            controller.present(alertController, animated: true, completion: nil)
        }
    }
}
