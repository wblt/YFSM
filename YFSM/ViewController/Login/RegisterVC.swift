//
//  RegisterVC.swift
//  YFSM
//
//  Created by 冷婷 on 2018/1/14.
//  Copyright © 2018年 wb. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
class RegisterVC: BaseVC {

    @IBOutlet weak var _numberTextField: UITextField!
    @IBOutlet weak var _passwordTextField: UITextField!
    @IBOutlet weak var _codeTextField: UITextField!
    @IBOutlet weak var _codeButton: UIButton!
    @IBOutlet weak var _registerBtn: UIButton!
    var code = ""
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "注册";
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func registerAction(_ sender: UIButton) {
        if _numberTextField.text?.length != 11 {
            SVProgressHUD.showError(withStatus: "请输入手机号")
            return
        }
        if (_passwordTextField.text?.length)! < 6 {
            SVProgressHUD.showError(withStatus: "请设置密码(6-10位数字与字母的组合)")
            return
        }
        if _codeTextField.text != self.code {
            SVProgressHUD.showError(withStatus: "验证码错误")
            return
        }
        let urlString = api_service+"/register"
        
        var parameters = [String: Any]()
        parameters["username"] = _numberTextField.text
        parameters["password"] = _passwordTextField.text?.mattress_MD5();
        BFunction.shared.showLoading()
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            BFunction.shared.hideLoadingMessage()
            if response.error != nil  {
                
                SVProgressHUD.showError(withStatus: "注册失败")
                return
            }
            if let jsonResult = response.value as? Dictionary<String, Any> {
                if jsonResult["result"] as! Int == 0 {
                    let userDefaults = UserDefaults.standard
                    userDefaults.setValue(self._numberTextField.text, forKey: "UserPhone")
                    userDefaults.setValue(self._passwordTextField.text, forKey: "UserPassword")
                    userDefaults.setValue(jsonResult["userid"], forKey: "userid")
                    userDefaults.synchronize()
                    AccountManager.shared.login(response.value as! [String : Any], firstLogin: false)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
                    appDelegate.window?.rootViewController = BaseNavC(rootViewController: homeVC)
                }else if jsonResult["result"] as! Int == -2 {
                    SVProgressHUD.showError(withStatus: "已经注册 ，去登录")
                }else {
                    
                    SVProgressHUD.showError(withStatus: "注册失败")
                }
            }
            
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func codeAction(_ sender: UIButton) {
        let urlString = api_service+"/vercode"
        var parameters = [String: Any]()
        parameters["username"] = _numberTextField.text
        BFunction.shared.showLoading()
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            BFunction.shared.hideLoadingMessage()
            if response.error != nil  {
             
                SVProgressHUD.showError(withStatus: "获取验证码失败")
                return
            }
            if let jsonResult = response.value as? Dictionary<String, Any> {
                if jsonResult["result"] as! Int == 0 {
                    self.code = (jsonResult["vercode"] as! NSNumber).stringValue
                    SVProgressHUD.showSuccess(withStatus: "已发送验证码")
                    self.remainingSeconds = 59
                    self.isCounting = !self.isCounting
                }else {
                    
                    SVProgressHUD.showError(withStatus: "获取验证码失败")
                }
            }
            
        }
    }
    
    private var isCounting: Bool = false {//是否开始计时
        willSet(newValue) {
            if newValue {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
            } else {
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    
    @objc func updateTimer(timer: Timer) {// 更新时间
        if remainingSeconds > 0 {
            remainingSeconds -= 1
        }
        
        if remainingSeconds == 0 {
            _codeButton.setTitle("获取验证码", for: .normal)
            _codeButton.isEnabled = true
            isCounting = !isCounting
            timer.invalidate()
        }
    }
    
    private var remainingSeconds: Int = 0 {//remainingSeconds数值改变时 江将会调用willSet方法
        willSet(newSeconds) {
            let seconds = newSeconds%60
            _codeButton.setTitle(NSString(format: "%02ds", seconds) as String, for: .normal)
        }
    }//当前倒计时剩余的秒数
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
