//
//  NotificationDetailViewController.swift
//  Audit
//
//  Created by Mac on 11/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class NotificationDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func action_back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
