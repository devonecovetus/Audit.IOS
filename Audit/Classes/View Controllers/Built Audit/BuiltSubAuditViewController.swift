//
//  BuiltSubAuditViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 30/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class BuiltSubAuditViewController: UIViewController {

    @IBOutlet weak var tv_Description: UITextView!
    @IBOutlet weak var lbl_Info: UILabel!
    @IBOutlet weak var btn_Content: UIButton!
    @IBOutlet weak var imgView_Photo: UIImageView!
    @IBOutlet weak var lbl_FolderTitle: UILabel!
    @IBOutlet weak var btn_EditPhoto: UIButton!
    @IBOutlet weak var btn_AddPhoto: UIButton!
    @IBOutlet weak var btn_Delete: DesignableButton!
    @IBOutlet weak var btn_Next: DesignableButton!
    @IBOutlet weak var colView_SubLocation: UICollectionView!
    @IBOutlet weak var colView_SelectedSubLocation: UICollectionView!
    
    var intAuditId = Int()
    var intLocationId = Int()
    var intFolderId = Int()
    var intSubFolderId = Int()
    var arrSubLocationList = [SubLocationModel]()
    var arrSelectedSubLocationList = [BuiltAuditSubLocationModel]()
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLanguageSetting()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //MARK: Supporting Functions:
    
    func getSubLocationList() {
        self.arrSubLocationList = obSqlite.getDefaultSubLocationList(auditId: intAuditId)
        self.colView_SubLocation.reloadData()
    }
    
    func getSelectedSubLocationList() {
     //   self.arrSelectedSubLocationList = obSqlite.getBui
    }
    
    
    func setUpLanguageSetting() {
        
    }
    
    //MARK: Button Actions:
    @IBAction func btn_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_EditPhoto(_ sender: Any) {
    }
    @IBAction func btn_AddPhoto(_ sender: Any) {
    }
    @IBAction func btn_NavigateToBuiltAudit(_ sender: Any) {
        MF.navigateToBuiltAudit(vc: self)
    }
    @IBAction func btn_Next(_ sender: Any) {
    }
    
    @IBAction func btn_Delete(_ sender: Any) {
    }
    
}
