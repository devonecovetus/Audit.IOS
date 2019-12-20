//
//  NotificationListViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 31/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class NotificationListViewController: UIViewController {
    //MARK: Variable & Outlets
    var pageno = 1
    var lodingApi: Bool!
    var delegate: NotificationListDelegate?
    var notificationList:[NotificationModel]? = [NotificationModel]()
    @IBOutlet weak var tblView: UITableView?
    @IBOutlet weak var lbl_Title: UILabel?
    
    //MARK: View Life Cycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        // Do any additional setup after loading the view.
        setUpLanguageSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        kAppDelegate.currentViewController = self
        notificationList?.removeAll()
        tblView?.reloadData()
        delegate?.getNotificationList()
    }

    //MARK: Button Actions:
    @IBAction func btn_Back(_ sender: Any) {
        notificationList?.removeAll()
        notificationList = [NotificationModel]()
        tblView?.delegate = nil
        tblView?.dataSource = nil
        delegate = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_DeleteAll(_ sender: Any) {
        MF.ShowPopUpViewOn(viewController: self, popUpType: PopUpType.Action, title: "Delete All!" , message: NSLocalizedString("ClearAllNotification", comment: ""))
    }
    
    @IBOutlet weak var btn_DeleteAll: UIButton!
    
    // MARK: - Supporting Methods
    func setUpLanguageSetting() {
        view.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
        lbl_Title?.transform = CGAffineTransform(scaleX: kAppDelegate.intViewFlipStatus, y: 1)
    }
}

extension NotificationListViewController: PopUpDelegate {
    func actionOnYes() {
        deleteAllNotification()
    }
    
    func actionOnNo() { }
}

