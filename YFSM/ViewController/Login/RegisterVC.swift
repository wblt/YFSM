//
//  RegisterVC.swift
//  YFSM
//
//  Created by 冷婷 on 2018/1/14.
//  Copyright © 2018年 wb. All rights reserved.
//

import UIKit

class RegisterVC: BaseVC {

    @IBOutlet weak var _numberTextField: UITextField!
    @IBOutlet weak var _passwordTextField: UITextField!
    @IBOutlet weak var _codeTextField: UITextField!
    @IBOutlet weak var _codeButton: UIButton!
    @IBOutlet weak var _registerBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func registerAction(_ sender: UIButton) {
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
