//
//  DragViewController.swift
//  Audit
//
//  Created by Rupesh Chhabra on 26/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class DragViewController: UIViewController {

    @IBOutlet weak var colView1: DragNDropCollectionView!
    @IBOutlet weak var colView2: DragNDropCollectionView!
    
    @IBAction func btn_EnableDelete(_ sender: Any) {
        
        if !colView2.isEnableDelete! {
            colView2.isEnableDelete = true
        } else {
            colView2.isEnableDelete = false
        }
        colView2.reloadData()
    }
    var arrItems = ["Car", "Bike", "Moped", "Bicycle", "Truck", "Bus", "Two Wheeler", "Four Wheeler"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colView1.initSettings(isDelegaeDataSource: true, isDrag: true, isDrop: true)
        colView1.rowNumber = 1
        colView2.initSettings(isDelegaeDataSource: true, isDrag: false, isDrop: true)
        colView2.rowNumber = 2
        colView1.strTitle = "Main List"
        colView1.stickers = arrItems
        colView2.isEnabled = true

        colView2.strTitle = "Drag N Drop Objects"
        colView2.stickers = []
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
