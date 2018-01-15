//
//  LoginVC.swift
//  DigitalCampus
//
//  Created by luo on 16/4/23.
//  Copyright © 2016年 luo. All rights reserved.
//

import UIKit

class LoginVC: BaseVC {
    
    @IBOutlet weak var _numberTextField: UITextField!
    @IBOutlet weak var _passwordTextField: UITextField!
    @IBOutlet weak var _loginButton: UIButton!
    @IBOutlet weak var _registerBtn: UIButton!
    
    
    // MARK: - life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _registerBtn.layer.borderColor = UIColor.cyan.cgColor
        _registerBtn.layer.borderWidth = 1.0

        _registerBtn.layer.masksToBounds = true;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func toRegister(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
      self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
    }
    
}

