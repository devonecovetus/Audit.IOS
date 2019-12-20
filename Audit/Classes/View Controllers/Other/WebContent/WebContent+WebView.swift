//
//  WebContent+WebView.swift
//  Audit
//
//  Created by Rupesh Chhabra on 29/03/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

extension WebContentViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView){
        SVProgressHUD.show(withStatus: NSLocalizedString("loading...", comment: ""))
        //print("webViewDidStartLoad")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
        //print("webViewDidFinishLoad")
    }
    
    func webView(_webView: UIWebView, didFailLoadWithError error: NSError) {
        SVProgressHUD.dismiss()
        //print("webview did fail load with error: \(error)")
    }
}
