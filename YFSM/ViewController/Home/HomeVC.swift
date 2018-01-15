//
//  HomeVC.swift
//  YFSMM
//
//  Created by Alvin on 2017/6/17.
//  Copyright © 2017年 Alvin. All rights reserved.
//

import UIKit
//import BabyBluetooth
import LKDBHelper
import CryptoSwift
import AVFoundation

class BlueToothEntity: NSObject {
    var peripheral: CBPeripheral?
    var RSSI: NSNumber?
    var advertisementData: Dictionary<String, Any>?
}

class PeripheralInfo: NSObject {
    var serviceUUID: CBUUID?
    var characteristics: [CBCharacteristic]?
}

let kDefaultDeviceUUid = "kDefaultDeviceUUid"

let bubble = BubbleAnimation.init();

var oil1Value = 0;
var oil2Value = 0;

var water1Value = 0;
var water2Value = 0;

class HomeVC: BaseVC,JHCustomMenuDelegate,SearchDeviceViewDelegate,AVAudioPlayerDelegate,UIAlertViewDelegate {
    @IBOutlet weak var connectView: UIView!
    
    @IBOutlet var deviceBtns: [UIButton]!
    
    @IBOutlet weak var stallsLabel: UILabel!
    @IBOutlet weak var jinghuaBGV: UIButton!
    @IBOutlet weak var daojishiLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var youfenLabel: UILabel!
    @IBOutlet weak var shuifenLabel: UILabel!
    @IBOutlet weak var youfenIMGV: UIImageView!
    @IBOutlet weak var shuifenIMGV: UIImageView!
    @IBOutlet weak var youfenBGV: UIButton!
    @IBOutlet weak var shuifenBGV: UIButton!
    @IBOutlet weak var startView: UIView!
    
    @IBOutlet weak var device_name: UILabel!
    
    
    fileprivate var angle:CGFloat = 0
    fileprivate var hasSerch:Bool = false //用户主动搜索设备
    fileprivate var hasPopView:Bool = false
    fileprivate var isConnect:Bool = false
    fileprivate var isStopAllDeviceStatusAnimation = false
    fileprivate var currentServiceCharacteristics = [CBCharacteristic]()
    fileprivate let baby = BabyBluetooth.share()!
    fileprivate let cPeripleralName = "DMK28  "

    fileprivate var peripleralArray:[CBPeripheral] = []
    fileprivate let cPQKeyNoti_charUUID = "3378"
    
    fileprivate var currPeripheral:CBPeripheral!
    fileprivate var moreMenu:JHCustomMenu?
    @IBOutlet weak var connectBtn: UIButton!
    fileprivate var isFristLaunch = true
    fileprivate let rhythm = BabyRhythm()
    fileprivate var services = [PeripheralInfo]()
    fileprivate var deviceStatus:UInt8 = 0  //设备状态
    
    fileprivate var shuifenValue:Int! = 0
    fileprivate var youfenValue:Int! = 0
    
    var audioPlayer: AVAudioPlayer?
    var musicArr:Array<String> = []
    var musicStatus:UInt8 = 0;
    var switchOn:Bool = false;
    
    @IBOutlet weak var playButton: UIButton!

    fileprivate lazy var searchView: SearchDeviceView = {
        let popView = Bundle.main.loadNibNamed("SearchDeviceView", owner: nil, options: nil)?.first as! SearchDeviceView
        popView.delegate = self
        return popView
    }()
    
    
    @IBOutlet weak var fuduSlider: UISlider!
    let channelOnPeropheralView = "channelOnPeropheralView"
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // baby.cancelAllPeripheralsConnection()
        //_ = baby.scanForPeripherals()?.begin()
        if isConnect == false {
            self.startAnimation()
        }
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // baby.cancelScan()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "智惠面膜"
        
        device_name.text = ""
        daojishiLabel.text = ""
        fuduSlider.minimumValue = 0// 设置最小值
        fuduSlider.maximumValue = 255// 设置最大值
        let stallsNum:Float = self.fuduSlider.maximumValue / Float(16)
        fuduSlider.value = 1 * stallsNum  //设置初始值
    
    
        self.stallsLabel.text = "\(Int(self.fuduSlider.value / stallsNum))"
        
        fuduSlider.addTarget(self, action: #selector(self.sliderValueChanged), for: UIControlEvents.valueChanged)
        self.connectView.isHidden = false
        self.startView.isHidden = true
        
        self.navigationItem.leftBarButtonItem = nil
        
        self.setBabyDelegate()

        
        self.startAnimation()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)

            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)

        } catch {

        }
        
        let path1 = Bundle.main.path(forResource: "m1", ofType: "mp3")
        let path2 = Bundle.main.path(forResource: "m2", ofType: "mp3")
        let path3 = Bundle.main.path(forResource: "m3", ofType: "mp3")
        musicArr = Array<String>();
        musicArr.append(path1!);
        musicArr.append(path2!);
        musicArr.append(path3!);
        let pathURL:URL = URL(fileURLWithPath: musicArr[1])
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: pathURL)
            audioPlayer?.delegate = self
        } catch {
            audioPlayer = nil
        }

        
        
    }
    

    //MARK:结束按钮的动画
    func stopAnimation() {
        self.connectView.isHidden = true
        self.startView.isHidden = false
        self.connectView.layer.removeAllAnimations()
        self.angle = 0
        
        let endAngle = CGAffineTransform(rotationAngle: angle * CGFloat(Double.pi / 180.0))
        UIView.animate(withDuration: 0.01, delay: 0, options: .curveLinear, animations: {() -> Void in
            //self.connectBtn.isEnabled = false
            self.connectView.transform = endAngle
        }, completion: {(_ finished: Bool) -> Void in
            
        })
        
    }
    //MARK:开始按钮的动画
    @objc fileprivate dynamic func startAnimation() {
        
      
        let endAngle = CGAffineTransform(rotationAngle: angle * CGFloat(Double.pi / 180.0))
        UIView.animate(withDuration: 0.01, delay: 0, options: .curveLinear, animations: {() -> Void in
            //self.connectBtn.isEnabled = false
            self.connectView.transform = endAngle
        }, completion: {(_ finished: Bool) -> Void in
            if finished == false {
                self.angle = 0
                return
            }
            self.angle += 2
            self.startAnimation()
        })
        
        
    }
    
    
    @IBAction func startClick(_ sender: Any) {
        if  self.deviceStatus == 0 {
            var data = Data()
            var fudu = UInt8(self.fuduSlider.value)
            
            let stallsNum:Float = self.fuduSlider.maximumValue / Float(16)
            self.fuduSlider.value = Float(Int(self.fuduSlider.value / stallsNum)) * stallsNum
            
            let ssssss:String = "\(Int(self.fuduSlider.value / stallsNum))"
            print("档位值  "+ssssss)
            if (ssssss.isEqual("1")){
                fudu = 00;
            } else if (ssssss.isEqual("2")){
                fudu = 08;
            } else if (ssssss.isEqual("3")){
                fudu = 10;
            } else if (ssssss.isEqual("4")){
                fudu = 18;
            } else if (ssssss.isEqual("5")){
                fudu = 20;
            } else if (ssssss.isEqual("6")){
                fudu = 28;
            } else if (ssssss.isEqual("7")){
                fudu = 30;
            } else if (ssssss.isEqual("8")){
                fudu = 38;
            } else if (ssssss.isEqual("9")){
                fudu = 40;
            } else if (ssssss.isEqual("10")){
                fudu = 48;
            } else if (ssssss.isEqual("11")){
                fudu = 50;
            } else if (ssssss.isEqual("12")){
                fudu = 58;
            } else if (ssssss.isEqual("13")){
                fudu = 60;
            } else if (ssssss.isEqual("13")){
                fudu = 68;
            } else if (ssssss.isEqual("14")){
                fudu = 70;
            } else if (ssssss.isEqual("15")){
                fudu = 78;
            } else if (ssssss.isEqual("16")){
                fudu = 80;
            }
            print("幅度变化值  "+fudu)
            
            data = Data(bytes: [0x01,0xfe,0x00,0x00,0x23,0x33,0x10,0x00,fudu,0x00,0x00,0x00,0x00,0x00,0x00,0x00])
            let characteristics = self.services[1].characteristics![0]
            
            self.currPeripheral.writeValue(data as Data, for: characteristics, type: CBCharacteristicWriteType.withoutResponse)
        }
    }
    
    
    
    
    @IBAction func connectClick(_ sender: Any) {
        
        
        
        self.startAnimation()
        
        self.setOnDiscoverSerchDevice()
        //self.connectDevice()
        
    }
    
    
    
    
    
    @IBAction func addChartClick(_ sender: Any) {
        let model = ChartModel()
        model.date = 20170708
        model.oil1 = 40
        model.oil2 = 50
        model.water1 = 52
        model.water2 = 60
        model.step = 2
        model.saveToDB()
        
        
        
        let model2 = ChartModel()
        model2.date = 20170709
        model2.oil1 = 55
        model2.oil2 = 60
        model2.water1 = 30
        model2.water2 = 65
        model2.step = 2
        model2.saveToDB()
        
        
        let model3 = ChartModel()
        model3.date = 20170710
        model3.oil1 = 40
        model3.oil2 = 58
        model3.water1 = 52
        model3.water2 = 67
        model3.step = 2
        model3.saveToDB()
        
        
        
        
        let model4 = ChartModel()
        model4.date = 20170711
        model4.oil1 = 40
        model4.oil2 = 50
        model4.water1 = 52
        model4.water2 = 60
        model4.step = 2
        model4.saveToDB()
        
        
        
        let model5 = ChartModel()
        model5.date = 20170712
        model5.oil1 = 55
        model5.oil2 = 60
        model5.water1 = 30
        model5.water2 = 65
        model5.step = 2
        model5.saveToDB()
        
        
        let model6 = ChartModel()
        model6.date = 20170713
        model6.oil1 = 40
        model6.oil2 = 58
        model6.water1 = 52
        model6.water2 = 67
        model6.step = 2
        model6.saveToDB()
        
        
        
        
        let model7 = ChartModel()
        model7.date = 20170714
        model7.oil1 = 40
        model7.oil2 = 50
        model7.water1 = 52
        model7.water2 = 60
        model7.step = 2
        model7.saveToDB()
        
        
        
        let model8 = ChartModel()
        model8.date = 20170715
        model8.oil1 = 55
        model8.oil2 = 60
        model8.water1 = 30
        model8.water2 = 65
        model8.step = 2
        model8.saveToDB()
        
        
        let model9 = ChartModel()
        model9.date = 20170716
        model9.oil1 = 40
        model9.oil2 = 58
        model9.water1 = 52
        model9.water2 = 67
        model9.step = 2
        model9.saveToDB()
        
        
        
        
        
        
        
        
        let model10 = ChartModel()
        model10.date = 20170717
        model10.oil1 = 40
        model10.oil2 = 50
        model10.water1 = 52
        model10.water2 = 60
        model10.step = 2
        model10.saveToDB()
        
        
        
        let model11 = ChartModel()
        model11.date = 20170718
        model11.oil1 = 55
        model11.oil2 = 60
        model11.water1 = 30
        model11.water2 = 65
        model11.step = 2
        model11.saveToDB()
        
        
        let model12 = ChartModel()
        model12.date = 20170719
        model12.oil1 = 40
        model12.oil2 = 58
        model12.water1 = 52
        model12.water2 = 67
        model12.step = 2
        model12.saveToDB()
    }
    
    @IBAction func 清空统计数据(_ sender: Any) {
        let globalHelper = ChartModel.getUsingLKDBHelper()
        
        ///删除所有表   delete all table
        globalHelper.dropAllTable()
        
        //清空表数据  clear table data
        LKDBHelper.clearTableData(ChartModel.self)
        
       
    }
    
    //MARK:写入数据
    @objc func sliderValueChanged() {
//        let tempNum:Float = self.fuduSlider.maximumValue / Float(16)
//        self.fuduSlider.value = Float(Int(self.fuduSlider.value / tempNum)) * tempNum
//        var fudu = UInt8(self.fuduSlider.value)
    
        if isFristLaunch == true {
            
            let alrtView = UIAlertView(title: "提示", message: "请先点击开始按钮", delegate: nil, cancelButtonTitle: "确定")
            alrtView.show()
            return
        }
        
        // self.fuduSlider.
        // stallsLabel.center = CGPoint(x: self.fuduSlider.center.x, y: stallsLabel.center.y)
        
        let stallsNum:Float = self.fuduSlider.maximumValue / Float(16)
        self.fuduSlider.value = Float(Int(self.fuduSlider.value / stallsNum)) * stallsNum
        
        
        let trackRect = self.fuduSlider.convert(self.fuduSlider.bounds, to: nil)
        
        
        let thumbRect = self.fuduSlider.thumbRect(forBounds: self.fuduSlider.bounds, trackRect: trackRect, value: self.fuduSlider.value)
        
        self.stallsLabel.text = "\(Int(self.fuduSlider.value / stallsNum))"
        self.stallsLabel.frame = CGRect(x: thumbRect.origin.x, y: self.stallsLabel.frame.origin.y, width: self.stallsLabel.frame.width, height: self.stallsLabel.frame.height)
        
        
        
        if self.deviceStatus > 0 {
            
            
            var status:UInt8 = 0
            switch self.deviceStatus {
            case 0:
                status = 0
            case 1:
                status = 33
            case 2:
                status = 35
            case 3:
                status = 37
            default:
                status = 0
            }
            
            var data = Data()
            var fudu = UInt8(self.fuduSlider.value)
            
            let ssssss:String = "\(Int(self.fuduSlider.value / stallsNum))"
            print("档位值  "+ssssss)
            if (ssssss.isEqual("1")){
                fudu = 00;
            } else if (ssssss.isEqual("2")){
                fudu = 08;
            } else if (ssssss.isEqual("3")){
                fudu = 10;
            } else if (ssssss.isEqual("4")){
                fudu = 18;
            } else if (ssssss.isEqual("5")){
                fudu = 20;
            } else if (ssssss.isEqual("6")){
                fudu = 28;
            } else if (ssssss.isEqual("7")){
                fudu = 30;
            } else if (ssssss.isEqual("8")){
                fudu = 38;
            } else if (ssssss.isEqual("9")){
                fudu = 40;
            } else if (ssssss.isEqual("10")){
                fudu = 48;
            } else if (ssssss.isEqual("11")){
                fudu = 50;
            } else if (ssssss.isEqual("12")){
                fudu = 58;
            } else if (ssssss.isEqual("13")){
                fudu = 60;
            } else if (ssssss.isEqual("13")){
                fudu = 68;
            } else if (ssssss.isEqual("14")){
                fudu = 70;
            } else if (ssssss.isEqual("15")){
                fudu = 78;
            } else if (ssssss.isEqual("16")){
                fudu = 80;
            }
            print("幅度变化值  "+fudu)
            data = Data(bytes: [0x01,0xfe,0x00,0x00,0x23,status,0x10,0x00,fudu,0x00,0x00,0x00,0x00,0x00,0x00,0x00])
            let characteristics = self.services[1].characteristics![0]
            
            self.currPeripheral.writeValue(data as Data, for: characteristics, type: CBCharacteristicWriteType.withoutResponse)
            
        }
 
    }
    
    //MARK:减幅
    @IBAction func writeSubClick(_ sender: Any) {
        
        if isFristLaunch == true {
            
            
            let alerView  = UIAlertView(title:  "提示", message: "请先点击开始按钮", delegate: nil, cancelButtonTitle: "确定")
            alerView.show()
            return
        }
        let stallsNum:Float = self.fuduSlider.maximumValue / Float(16)
        self.fuduSlider.value = self.fuduSlider.value - stallsNum
        
        self.sliderValueChanged()
    }
    //MARK:增幅
    
    @IBAction func writeAddClick() {
        
        if isFristLaunch == true {
            let alerView  = UIAlertView(title:  "提示", message: "请先点击开始按钮", delegate: nil, cancelButtonTitle: "确定")
            alerView.show()
            return
        }
        let stallsNum:Float = self.fuduSlider.maximumValue / Float(16)
        self.fuduSlider.value += stallsNum
        
        self.sliderValueChanged()
        
    }
    
    
    
    
    //MARK:订阅一个值,用来接收设备每秒发送过来的数据
    func setNotifiy() {
        
        if currPeripheral.state != .connected {
            LogManager.shared.log("订阅失败")
            return
        }
        
        let characteristics = self.services[0].characteristics![0]
        if  characteristics.isNotifying == false {
            
            self.currPeripheral.setNotifyValue(true, for: characteristics)
            
        }
    }
    
    //MARK:解析设备每秒发送过来的数据
    func readNotifiy(data:Data) {
        isFristLaunch = false
        let status = data.bytes[13]
        let shuifen = data.bytes[10]
        let youfen = data.bytes[11]
        let fenzhong = data.bytes[8]
        let miao = data.bytes[9]
        let xiaoshi = data.bytes[7]
        self.shuifenValue = Int(shuifen)
        self.youfenValue = Int(youfen)
        
        //MARK:开始气泡动画
        bubble.view = self.view;
        bubble.bubble_x = kScreenFrameW/2;
        bubble.bubble_y = self.startView.frame.origin.y;
        
        if status != 0 && deviceStatus != status {
            self.stopAllDeviceStatusAnimation()
            let time: TimeInterval = 0.8
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
                self.isStopAllDeviceStatusAnimation = false
                self.startDeviceStatusAnimation(status: Int(status))
            }
            
        }
        self.deviceStatus = status
        
        if currPeripheral != nil {
            self.device_name.text = currPeripheral.identifier.uuidString.components(separatedBy: "-")[0]
        } else {
            self.device_name.text = ""
        }
        
        print("dddddd你好---------------------------")
        
        print("identifier"+currPeripheral.identifier.uuidString + "name:"+currPeripheral.name)
        
        
        if status != 0 && self.musicStatus != status {
            // 播放音乐
            self.playMusic(status: Int(status))
        }
        self.musicStatus = status;
        
        // 拼接数据
        var ss:String = "\(miao)"
        if ss.length == 1 {
            ss = "0"+ss;
        }
        
        let daojishi = "\(xiaoshi)\(fenzhong):"+ss;
        
        if daojishi == "00:01" {
            
            // 停止音乐
            self.musicStatus = 0
            if (self.audioPlayer?.isPlaying)! {
                self.audioPlayer?.stop();
            }
            
            //MARK:结束气泡动画
            bubble.stop_bubbleAnimation();
            
            self.deviceStatus = 0
            self.stopAllDeviceStatusAnimation()
            self.setNotifiy()
            daojishiLabel.isHidden = true
          
            
            let date = (Date.currentTime().substringToIndex(10)!.replacingOccurrences(of: "-", with: "") as NSString).integerValue
            
            let searchResultModel = ChartModel.searchSingle(withWhere: ["date":date], orderBy: nil) as! ChartModel
            self.startLabel.text = "开始"
            searchResultModel.oil2 = self.youfenValue
            searchResultModel.water2 = self.shuifenValue
            searchResultModel.date = date
            searchResultModel.step = 2
            searchResultModel.updateToDB()
            
            oil2Value = self.youfenValue;
            water2Value = self.shuifenValue;
            
            //var waterUp = String(water2Value - water1Value);
            
            let resultVC = ResultViewController();
            self.present(resultVC, animated: true, completion: nil);
            
//            waterUp = "本次美颜结束，水份提升"+waterUp+"%，水嫩嫩的。"
//            
//            let alertviw = UIAlertView(title: "提示", message:waterUp, delegate: nil, cancelButtonTitle: "确认")
//            alertviw.show();
        }
            //开始使用面膜机
        else if daojishi == "011:59"{
            
        
            bubble.start_bubbleAnimation();
            let date = (Date.currentTime().substringToIndex(10)!.replacingOccurrences(of: "-", with: "") as NSString).integerValue
            let model = ChartModel()
            model.oil1 = self.youfenValue
            model.water1 = self.shuifenValue
            model.date = date
            model.step = 1

            oil1Value = self.youfenValue;
            water1Value = self.shuifenValue;
            
            
            self.startLabel.text = "运行中"
             model.saveToDB()
        }else if daojishi != "00:00" && fenzhong < 10  {
            
        

            
            bubble.start_bubbleAnimation();

            daojishiLabel.isHidden = false
            self.startLabel.text = "运行中"
            // 拼接数据
            var bb:String = "\(miao)"
            if bb.length == 1 {
                bb = "0"+bb;
            }
//            daojishiLabel.text = "\(xiaoshi)\(fenzhong):\(miao)"
            daojishiLabel.text = "\(xiaoshi)\(fenzhong):"+bb
            
        }else if fenzhong >= 10{
            
        
            
            bubble.start_bubbleAnimation();
            self.startLabel.text = "运行中"
            daojishiLabel.isHidden = false
            var bb:String = "\(miao)"
            if bb.length == 1 {
                bb = "0"+bb;
            }
//            daojishiLabel.text = "\(fenzhong):\(miao)"
            daojishiLabel.text = "\(fenzhong):"+bb
        }
        else{
            self.startLabel.text = "开始"
            daojishiLabel.isHidden = true
        
        }
        print("分钟：-----"+"\(fenzhong)");
//        print("设备状态：\(status) 水份：\(shuifen) 油份：\(youfen) 倒计时：\(xiaoshi)\(fenzhong):\(miao)")
        print("设备状态：\(status) 水份：\(shuifen) 油份：\(youfen) 倒计时:"+daojishi)
        self.setShuiAndYouProgress()
        
        let userDefault = UserDefaults.standard
        let swithdd:Bool = userDefault.bool(forKey: "switchOn")
        let sds:String = self.startLabel.text!;
        if sds.isEqual("运行中") {
            playButton.isHidden = false;
            if swithdd == false {
                playButton.setTitle("关闭音乐", for: UIControlState.normal)
            } else {
                playButton.setTitle("打开音乐", for: UIControlState.normal)
            }
        } else {
            playButton.setTitle("关闭音乐", for: UIControlState.normal)
            playButton.isHidden = true;
        }
        
    
    }
    
    
    @IBAction func playAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected;
        if sender.isSelected {
            print("点击选择-------")
            switchOn = true;
            audioPlayer?.pause()
            playButton.setTitle("打开音乐", for: UIControlState.normal)
        } else {
            print("点击未选择-------")
            switchOn = false;
            
            audioPlayer?.play()
            playButton.setTitle("关闭音乐", for: UIControlState.normal)
        }
        let userDefault = UserDefaults.standard
        userDefault.set(switchOn, forKey: "switchOn")
        userDefault.synchronize()
    }

    // 播放音乐
    func playMusic(status:Int) {
        let userDefault = UserDefaults.standard
        let swithdd:Bool = userDefault.bool(forKey: "switchOn")
        switchOn = swithdd;
        
        switch status {
        case 1:
            print("!!!!!!!!!--1----")
            let pathURL:URL = URL(fileURLWithPath: musicArr[0])
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: pathURL)
                audioPlayer?.delegate = self
            } catch {
                audioPlayer = nil
            }
            if switchOn == false {
                audioPlayer?.play()
            }
            break
        case 2:
            print("!!!!!!!!!--2----")
            let pathURL:URL = URL(fileURLWithPath: musicArr[1])
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: pathURL)
                audioPlayer?.delegate = self
            } catch {
                audioPlayer = nil
            }
            if switchOn == false {
                audioPlayer?.play()
            }
            break
        case 3:
            print("!!!!!!!!!--3----")
            let pathURL:URL = URL(fileURLWithPath: musicArr[2])
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: pathURL)
                audioPlayer?.delegate = self
            } catch {
                audioPlayer = nil
            }
            if switchOn == false {
                audioPlayer?.play()
            }
            break
        default: break
        }
        
        
        
    }
    
    // 播放完成代理方法
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // 循环播放
        playMusic(status: Int(self.musicStatus))
    }
    
    //MARK:设置状态动画
    func stopAllDeviceStatusAnimation() {
        
        self.isStopAllDeviceStatusAnimation = true
        
        let time: TimeInterval = 0.3
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
            for btn in self.deviceBtns {
                btn.isHidden = false
            }
        }
        
    }
    
    //MARK:设置状态动画
    func startDeviceStatusAnimation(status:Int) {
        
        
        
        if self.isStopAllDeviceStatusAnimation == true {
            return
        }
        
        
        
        let time: TimeInterval = 0.2
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
            
            var statusBtn:UIButton
            switch status {
            case 1:
                statusBtn = self.deviceBtns[0]
            case 2:
                statusBtn = self.deviceBtns[1]
            case 3:
                statusBtn = self.deviceBtns[2]
            default:
                statusBtn = self.deviceBtns[0]
            }
            
            
            if statusBtn.isHidden == true {
                statusBtn.isHidden = false
            }else{
                statusBtn.isHidden = true
            }
            //statusBtn.tag = 1
            self.startDeviceStatusAnimation(status: status)
        }
        
    }
    
    //MARK:设置水和油的进度
    func setShuiAndYouProgress() {
        
        
        
        let image = UIImage(named: "progress_progress")
        
        let shuifenClipY = CGFloat(((100 - CGFloat(self.shuifenValue)) / 100) * 300)
        let shuifenClipH = CGFloat((CGFloat(self.shuifenValue) / 100) * 300)
        let newImage = Utility.clipImage(with: image!, in: CGRect(x: 0, y: shuifenClipY , width: 30, height: shuifenClipH))
        shuifenIMGV.image = newImage
        shuifenIMGV.frame = CGRect(x: self.shuifenBGV.frame.origin.x + 1, y: self.shuifenBGV.frame.maxY - (shuifenClipH / 2), width: 15, height: shuifenClipH / 2)
        
        let image2 = UIImage(named: "progress_you")
        
        let youfenClipY = CGFloat(((100 - CGFloat(self.youfenValue)) / 100) * 300)
        let youfenClipH = CGFloat((CGFloat(self.youfenValue) / 100) * 300)
        let newImage2 = Utility.clipImage(with: image2!, in: CGRect(x: 0, y: youfenClipY , width: 30, height: youfenClipH))
        youfenIMGV.image = newImage2
        youfenIMGV.frame = CGRect(x: self.youfenBGV.frame.origin.x + 1, y: self.youfenBGV.frame.maxY - (youfenClipH / 2), width: 15, height: youfenClipH / 2)
        
        
        
        shuifenLabel.text = "水:\(self.shuifenValue!)%"
        youfenLabel.text = "油:\(self.youfenValue!)%"
    }
    
    
    
    
    @IBAction func moreClick(_ sender: Any) {
        
        //NavigationManager.pushToNativeWebView(form: self, fileName: "operation", title: "更多" )
        self.moreMenu?.dismiss(completion: { (menue) in
            
        })
        //  self.moreMenu?.removeFromSuperview()
        
        self.moreMenu = JHCustomMenu(dataArr: ["搜索设备", "水油数据", "使用教程", "注销登录", "意见反馈"], origin: CGPoint(x: kScreenFrameW - 125 - 20 , y: 64), width: 125, rowHeight: 44)
        
        
        self.moreMenu?.delegate = self
        self.moreMenu?.dismiss = {() -> Void in
            self.moreMenu?.removeFromSuperview()
            self.moreMenu = nil
            
        }
        self.moreMenu?.arrImgName = ["icon-serch", "chart_icon", "icon-jiaocheng", "chart_icon", "icon-jiaocheng"]
        view.addSubview(self.moreMenu!)
        
        
    }
    
    func jhCustomMenu(_ tableView: UITableView!, didSelectRowAt indexPath: IndexPath!) {
        
        
        if indexPath.row == 0 {
            self.hasPopView = false
            self.hasSerch = true
            self.peripleralArray.removeAll()
            self.currPeripheral = nil
            self.baby.cancelAllPeripheralsConnection()
            self.baby.cancelScan()
            _ = baby.scanForPeripherals().begin()
            self.connectView.isHidden = false
            self.startView.isHidden = true
            self.setBabyDelegate()
            self.setOnDiscoverSerchDevice()
        }
        
        if indexPath.row == 1 {
            self.performSegue(withIdentifier: "GoChartSegueIdentifier", sender: nil)
        }
        if indexPath.row == 2 {
            NavigationManager.pushToNativeWebView(form: self, fileName: "h5/operation", title: "更多" )
        }
        if indexPath.row == 3 {
            
            let alrtView = UIAlertView(title: "温馨提示", message: "是否确定退出？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定")
            alrtView.show()
        }
        if indexPath.row == 4 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let suggestionsVC = storyboard.instantiateViewController(withIdentifier: "SuggestionsVC") as! SuggestionsVC
            self.navigationController?.pushViewController(suggestionsVC, animated: true)
        }
    }
    
    public func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int)
    {
        if buttonIndex == 1 {
            UDManager.shared.removeUserToken()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
            appDelegate.window?.rootViewController = BaseNavC(rootViewController: loginVC)
        }
    }
    
    @IBAction func xx(_ sender: Any) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "GoChartSegueIdentifier") {
            //let chartVC: ChartVC? = (segue.destination as? ChartVC)
            //   oneVC?.activityDataModel = sender
        }
        
        
    }
    
    
}

//MARK:蓝牙的拓展
fileprivate extension HomeVC {
    
    func setOnDiscoverSerchDevice() {
        //已经选择设备的情况下就不需要处理了
     /*   if self.currPeripheral != nil {
            return
        }*/
        
        if self.currPeripheral == nil {
            Utility.delay(3, closure: {
                self.setOnDiscoverSerchDevice()
            })
        }
        
        //用户主动搜索让列表框弹出来
        if self.hasSerch == true {
            if hasPopView == false {
                self.searchView.show()
                self.hasPopView = true
            }
            self.searchView.setData(dataArray: self.peripleralArray)
            return
        }
        
        if self.peripleralArray.count == 0 {
            return
        }


        
        //缓存里面没有设备就弹窗让用户选择
        if self.peripleralArray.count > 1 && (UserDefaults.standard.object(forKey: kDefaultDeviceUUid) == nil) {


            self.searchView.setData(dataArray: self.peripleralArray)
            
        }else if self.peripleralArray.count == 1 && (UserDefaults.standard.object(forKey: kDefaultDeviceUUid) == nil) {
            let peripheral = self.peripleralArray[0]
            self.currPeripheral = peripheral
            self.connectDevice()
            self.hasPopView = false
            UserDefaults.standard.set(currPeripheral.identifier.uuidString, forKey: kDefaultDeviceUUid)
            return
        }

        
        //查找默认链接的设备
        for peripheral in self.peripleralArray {
            if let uuidString = UserDefaults.standard.object(forKey: kDefaultDeviceUUid) as? String  {
                
                if uuidString == peripheral.identifier.uuidString  {
                    self.currPeripheral = peripheral
                    //self.startAnimation()
                    self.connectDevice()
                    return
                }
            }
        }
        
        //没找到默认连接的设备就弹窗
        
        if hasPopView == false {
            self.searchView.show()
        }
        
        self.searchView.setData(dataArray: self.peripleralArray)
        
        

        
    }
    
    func connectDevice() {
        if self.currPeripheral == nil {
            let time: TimeInterval = 1.0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
                self.connectDevice()
            }
        }else{
            baby.cancelAllPeripheralsConnection()
            baby.having(self.currPeripheral).and().channel(channelOnPeropheralView).then().connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
            self.baby.cancelScan()
        }
    }
    
    
    
    //蓝牙网关初始化和委托方法设置
    /**
     进行第一步: 搜索到周围所有的蓝牙设备
     */
    func setBabyDelegate() {
        
        //获取设备状态
        baby.setBlockOnCentralManagerDidUpdateState { (central:CBCentralManager?) in
            
            if central?.state == .poweredOn  {
                
                LogManager.shared.log("设备打开成功，开始扫描设备")
                self.setOnDiscoverSerchDevice()
            }else{
                
           
                
  
            }
            
            
        }
        
        //过滤器
        //设置查找设备的过滤器
        baby.setFilterOnDiscoverPeripherals { (name, adv, RSSi) -> Bool in
            if let name = adv?["kCBAdvDataLocalName"] as? String {
                if name == self.cPeripleralName {
                    return true
                }
            }
            return false
        }
        
        
        
        //设置发现设service的Characteristics的委托
        baby.setBlockOnDiscoverCharacteristics { (p, s, err) in
            
            
            if let uuid = s?.uuid {
                LogManager.shared.log("发现service的Characteristics uuid是: \(uuid)")
            }else{
                LogManager.shared.log("发现service的Characteristics 但无法读取uuid")
            }
            
            
            if let characteristics = s?.characteristics {
                
                
                
                for c in characteristics {
                    LogManager.shared.log("charateristic name is : \(c.uuid)")
                }
            }else{
                LogManager.shared.log("发现Characteristics 但无法读取")
            }
            
        }
        
        
        
        //设置连接Peripherals的规则
        /* baby.setFilterOnConnectToPeripherals { (name, adv, RSSI) -> Bool in
         if let name = adv?["kCBAdvDataLocalName"] as? String {
         if name == self.cPeripleralName {
         return true;
         }
         }
         return false;
         }*/
        
        
        //搜索到一个新的设备
        baby.setBlockOnDiscoverToPeripherals { (centralManager, peripheral, adv, RSSI) in
            //  NSLog("%@", centralManager!);
            
            if adv?["kCBAdvDataLocalName"] as? String == self.cPeripleralName {
                
                if !self.peripleralArray.contains(peripheral!) {
                    self.peripleralArray.append(peripheral!)
                    
                }
            }
            
            
        };
        
        
        //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
        baby.setBlockOnConnectedAtChannel(channelOnPeropheralView) { (central:CBCentralManager?, peripheral:CBPeripheral?) in
            
            if peripheral != nil {
                
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                    self.stopAnimation()
                })
                self.isConnect = true
                LogManager.shared.log("设备连接成功 :\(peripheral!.name!)")
            }
        }
        
        //设置设备连接失败的委托
        baby.setBlockOnFailToConnectAtChannel(channelOnPeropheralView) { (central:CBCentralManager?, peripheral:CBPeripheral?, error:Error?) in
            if peripheral != nil {
                self.isConnect = false
                LogManager.shared.log("设备连接失败 :\(peripheral!.name!)")
            }
        }
        
        baby.setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel(channelOnPeropheralView) { (characteristic:CBCharacteristic?, error:Error?) in
            LogManager.shared.log("\(characteristic!.isNotifying)")
        }
        //设置设备断开连接的委托
        baby.setBlockOnDisconnectAtChannel(channelOnPeropheralView) { (central:CBCentralManager?, peripheral:CBPeripheral?, error:Error?) in
            if peripheral != nil {
                self.isConnect = false
                LogManager.shared.log("设备连接断开 :\(peripheral!.name!)")
            }
        }
        
        //设置发现设备的Services的委托
        baby.setBlockOnDiscoverServicesAtChannel(channelOnPeropheralView) { (peripheral:CBPeripheral?, error:Error?) in
            if let service_ = peripheral?.services {
                if self.services.count == 0 &&  self.services.count < 2 {
                    for mService in service_ {
                        
                        print("搜索到服务: \(mService.uuid.uuidString)")
                        let info = PeripheralInfo()
                        info.serviceUUID = mService.uuid
                        self.services.append(info)
                        
                        
                        //  self.setData2(service: mService)
                    }
                }
                
            }
            // 开启计时
            self.rhythm.beats()
        }
        
        //设置发现设service的Characteristics的委托
        baby.setBlockOnDiscoverCharacteristicsAtChannel(channelOnPeropheralView) { (peripheral:CBPeripheral?, service:CBService?, error:Error?) in
            
            if let service_ = service {
                
                var index = 0
                for m_sevice in self.services {
                    if service_.uuid.uuidString == m_sevice.serviceUUID?.uuidString {
                        m_sevice.characteristics = service!.characteristics
                        self.services[index] = m_sevice
                    }
                    
                    index = index + 1
                }
                
            }
            
            
        }
        
        
        //找到Peripherals的bloc
        baby.setBlockOnDiscoverDescriptorsForCharacteristicAtChannel(channelOnPeropheralView) { (peripheral:CBPeripheral?, characteristic:CBCharacteristic?, error:Error?) in
            
            // LogManager.shared.log(characteristic!.uuid.uuidString)
            
            if characteristic!.uuid.uuidString == self.cPQKeyNoti_charUUID {
                self.setNotifiy()
            }
            
            
        }
        
        
        
        // 读取数据
        baby.setBlockOnReadValueForCharacteristicAtChannel(channelOnPeropheralView) { (peripheral:CBPeripheral?, characteristic:CBCharacteristic?, error:Error?) in
            NSLog("discover characteristics:\(String(describing: characteristic))");
            
            
            if characteristic?.value?.count == 20 {
                
                if self.services.count == 2 {
                    self.readNotifiy(data: characteristic!.value!)
                }
            }
            
            
        }
        
        
        let scanForPeripheralsWithOptions = [CBCentralManagerScanOptionAllowDuplicatesKey:true]
        // 连接设备 9
        baby.setBabyOptionsWithScanForPeripheralsWithOptions(scanForPeripheralsWithOptions, connectPeripheralWithOptions: nil, scanForPeripheralsWithServices: nil, discoverWithServices: nil, discoverWithCharacteristics: nil)
        
       // baby.cancelAllPeripheralsConnection()
        _ = baby.scanForPeripherals().begin()
    }
}

extension HomeVC {
    
    func searchDeviceView(_ searchDeviceView: SearchDeviceView, didSelectRowAt index: Int) {
        self.currPeripheral = self.peripleralArray[index]
        self.connectDevice()
        //self.startAnimation()
        
        UserDefaults.standard.set(currPeripheral.identifier.uuidString, forKey: kDefaultDeviceUUid)
    }
    func dissmissOfView(_ searchDeviceView: SearchDeviceView) {
        self.hasPopView = false
        self.hasSerch = false
    }
    
    
}
