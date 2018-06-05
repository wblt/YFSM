//
//  ForgotPwdVC.swift
//  YFSM
//
//  Created by wb on 2018/6/5.
//  Copyright © 2018年 wb. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
class ForgotPwdVC: BaseVC {
    
    @IBOutlet weak var _numberTextField: UITextField!
    @IBOutlet weak var _codeTextField: UITextField!
    @IBOutlet weak var _passwordTextField: UITextField!
    @IBOutlet weak var _codeButton: UIButton!
    @IBOutlet weak var _commitButton: UIButton!
    
    var code = ""
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "找回密码";
        // Do any additional setup after loading the view.
    }
    
    @IBAction func codeAction(_ sender: Any) {
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
                if jsonResult["result"] as! String == "0" {
                    self.code = jsonResult["vercode"] as! String;
                    SVProgressHUD.showSuccess(withStatus: "已发送验证码")
                    self.remainingSeconds = 59
                    self.isCounting = !self.isCounting
                }else {
                    SVProgressHUD.showError(withStatus: "获取验证码失败")
                }
            }
            
        }
    }
    

    @IBAction func commitAction(_ sender: Any) {
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
        let urlString = api_service+"/restpwd"
        var parameters = [String: Any]()
        parameters["username"] = _numberTextField.text
        parameters["password"] = _passwordTextField.text?.mattress_MD5();
        BFunction.shared.showLoading()
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            BFunction.shared.hideLoadingMessage()
            if response.error != nil  {
                SVProgressHUD.showError(withStatus: "提交失败")
                return
            }
            if let jsonResult = response.value as? Dictionary<String, Any> {
                if jsonResult["result"] as! Int == 0 {
                    SVProgressHUD.showError(withStatus: "重置密码成功")
                    self.navigationController?.popViewController(animated: true)
                }else if jsonResult["result"] as! Int == -2 {
                    SVProgressHUD.showError(withStatus: "提交失败")
                }else {
                    SVProgressHUD.showError(withStatus: "注册失败")
                }
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
