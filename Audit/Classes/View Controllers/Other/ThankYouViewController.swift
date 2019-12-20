//
//  ThankYouViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 29/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class ThankYouViewController: UIViewController {

    //MARK: Outlets & Variables:
    @IBOutlet weak var btn_Home: UIButton!
    @IBOutlet weak var lbl_Messsage: UILabel!
    @IBOutlet weak var lbl_ThankYou: UILabel!
    @IBOutlet weak var imgView_Star: UIImageView!
    @IBOutlet weak var imgView_Thank: UIImageView!
    
    //MARK: View Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        kAppDelegate.currentViewController = self
    }
    
    @IBAction func btn_Home(_ sender: Any) {
        let navigationController = kAppDelegate.window?.rootViewController as! UINavigationController
        navigationController.viewControllers = [MF.setUpTabBarView()]
        MF.animateViewNavigation(navigationController: navigationController)
        kAppDelegate.window?.rootViewController = navigationController
    }
    
    //MARK: Supporting Functions:
    func setUpLanguageSetting() {
        self.view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Messsage.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_ThankYou.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        imgView_Thank.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
}
