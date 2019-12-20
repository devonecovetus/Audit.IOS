

//
//  Prirority_VC.swift
//  Audit
//
//  Created by Mac on 12/19/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class Prirority_VC: UIViewController {
    
    @IBOutlet weak var titleLabel: UINavigationItem!
    @IBOutlet weak var pkrView: UIPickerView!
    
    var callbackpriorityset:((_ name:String, _ value:Int, _ selectedcolor:UIColor)->())?

    var arrPriority = MF.setUpQuestionPriority()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpLanguageSetting()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpLanguageSetting() {
        titleLabel.title = NSLocalizedString("Priority", comment: "")
        
    }
    
    @IBAction func action_cancel(_ sender: Any) {
        let tmpController :UIViewController! = self.presentingViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
    
    @IBAction func action_done(_ sender: Any) {
        let tmpController :UIViewController! = self.presentingViewController;
        self.dismiss(animated: false, completion: {()->Void in
            let dict = self.arrPriority[self.pkrView.selectedRow(inComponent: 0)] as! NSDictionary
            self.callbackpriorityset?((dict["Name"] as? String)!,(dict["Value"] as? Int)!, (dict["Color"] as? UIColor)!)
            tmpController.dismiss(animated: false, completion: nil);
        });
    }
    
}

extension Prirority_VC: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrPriority.count
    }
    
    // MARK: UIPickerViewDelegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (arrPriority[row] as! NSDictionary)["Name"] as? String
    }
    
}
