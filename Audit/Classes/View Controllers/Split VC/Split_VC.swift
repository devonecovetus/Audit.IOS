//
//  Split_VC.swift
//  Audit
//
//  Created by Mac on 10/15/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class Split_VC: UIViewController {
    
    @IBOutlet var tblMenuOptions : UITableView!
    
    var img_arr = ["menu_account", "menu_history", "menu_reports", "menu_language", "menu_setting", "menu_help", "menu_logout"]
    var title_arr = ["Account", "History", "Reports", "Language", "Setting", "Help", "Logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension Split_VC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return title_arr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "menu_cell", for: indexPath) as! menu_cell
        cell.img_icons.image = UIImage(named: img_arr[indexPath.row])
        cell.lbl_title.text = title_arr[indexPath.row]
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if title_arr[indexPath.row] == "Account" {
            let vc = MainStoryBoard.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController
          //  self.navigationController?.pushViewController(vc!, animated: true)
            let navigationcontroller = UINavigationController(rootViewController: vc!)
            navigationController?.hidesBarsOnTap = true
            self.splitViewController?.showDetailViewController(navigationcontroller, sender: self)
            //self.splitViewController?.show(vc!, sender: self)
            
        } else if title_arr[indexPath.row] == "Logout" {
            logout()
        }
       
//        let btn = UIButton(type: UIButtonType.custom)
//        btn.tag = indexPath.row
//
//        UserDefaults.standard.set(title_arr[indexPath.row], forKey: "title") //setObject
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cellMenu", for: indexPath) as! cellMenu
//        cell.lbl_title.textColor = UIColor(hexString: "FF4908")
//        cell.lbl_title.backgroundColor = UIColor.white
//        self.onCloseMenuClick(btn)
    }
    
    func logout() {
        let alert = UIAlertController(title: "", message: ValidationMessages.strLogout, preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title:"Yes", style: UIAlertActionStyle.default) { (UIAlertAction) in
            
            UIView.animate(withDuration: 0.2) { () -> Void in
              self.splitViewController?.preferredDisplayMode = .primaryHidden
                MF.logoutAndClearAllSessionData()
                SHOWALERT.showAlertViewWithDuration(ValidationMessages.logoutSuccessfully)
            }
            
        }
        let cancelButton = UIAlertAction(title:"No", style: UIAlertActionStyle.default) { (UIAlertAction) in
        }
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
}
