//
//  WebController.swift
//  Omlet
//
//  Created by Sergey Libin on 27.07.17.
//  Copyright © 2017 Sergey Libin. All rights reserved.
//

import UIKit

class WebController: UIViewController  {

    @IBOutlet weak var WebView: UIWebView!
    
    var url = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loadUrl = NSURL (string: url)
        let requestObj = NSURLRequest(url: loadUrl! as URL)
        WebView.loadRequest(requestObj as URLRequest)
        
    }

}
