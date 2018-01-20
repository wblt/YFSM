//
//  ChartVC.swift
//  YFSMM
//
//  Created by Alvin on 2017/6/17.
//  Copyright © 2017年 Alvin. All rights reserved.
//

import UIKit
import MJExtension
import Alamofire
import SVProgressHUD

class ChartVC: BaseVC {
   var isYIsPercent: Bool = false
   // var lineChart:PNLineChart!
    var xTitles:[String] = []
    var beanArrassy:[FaceDataModel] = [FaceDataModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "水油数据表"
        self.automaticallyAdjustsScrollViewInsets = false;
        getdata();
    }

    func initEView(flag:String) {
        var oil1Array:[String] = []
        var oil2Array:[String] = []
        var water1Array:[String] = []
        var water2Array:[String] = []
        var tan1Array:[String] = []
        var tan2Array:[String] = []
        var jin1Array:[String] = []
        var jin2Array:[String] = []
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x:0, y:0, width:kScreenFrameW, height:kScreenFrameH)
        scrollView.contentSize = CGSize(width: kScreenFrameW, height: kScreenFrameH*2 - 150);
        self.view.addSubview(scrollView)
        if flag == "1" {
//            let modelArry = ChartModel.search(withWhere: ["step":2], orderBy: nil, offset: 0, count: 65535) as! [ChartModel]
//            for model in modelArry {
//                var dateStr = "\(model.date)".substringFromIndex(4)!
//                let stingIndex = dateStr.index(dateStr.startIndex, offsetBy: 2)
//                dateStr.insert("-", at: stingIndex)
//                xTitles.append(dateStr)
//                oil1Array.append("\(model.oil1)")
//                oil2Array.append("\(model.oil2)")
//                water1Array.append("\(model.water1)")
//                water2Array.append("\(model.water2)")
//            }
        } else {
            for model in beanArrassy {
                let dateStr = "\(model.time!)".substringToIndex(10)!
                //let stingIndex = dateStr.index(dateStr.startIndex, offsetBy: 2)
                //dateStr.insert("-", at: stingIndex)
                xTitles.append(dateStr)
                oil1Array.append("\(model.beforeuseoil!)")
                oil2Array.append("\(model.oil!)")
                water1Array.append("\(model.beforeusewater!)")
                water2Array.append("\(model.water!)")
                tan1Array.append("\(model.beforeuseelastic!)")
                tan2Array.append("\(model.elastic!)")
                jin1Array.append("\(model.beforeusecompactness!)")
                jin2Array.append("\(model.compactness!)")
            }
        }
        let chartView = ChartView()
        chartView.backgroundColor = UIColor.clear
        chartView.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(kScreenFrameW), height: CGFloat(kScreenFrameH / 2) - 50)
        chartView.setData(data1Array: water1Array, data2Array: water2Array, titlesArray: xTitles, title: "皮肤水份/%")
        scrollView.addSubview(chartView)
        
        let chart2View = ChartView()
        chart2View.backgroundColor = UIColor.clear
        chart2View.frame = CGRect(x: CGFloat(0), y: chartView.frame.maxY + 15, width: CGFloat(kScreenFrameW), height: CGFloat(kScreenFrameH / 2) - 50)
        chart2View.setData(data1Array: oil1Array, data2Array: oil2Array, titlesArray: xTitles, title: "皮肤油份/%")
        scrollView.addSubview(chart2View)
        
        // 紧致度
        let chart3View = ChartView()
        chart3View.backgroundColor = UIColor.clear
        chart3View.frame = CGRect(x: CGFloat(0), y: chart2View.frame.maxY + 15, width: CGFloat(kScreenFrameW), height: CGFloat(kScreenFrameH / 2) - 50)
        chart3View.setData(data1Array: jin1Array, data2Array: jin2Array, titlesArray: xTitles, title: "皮肤紧致度/%")
        scrollView.addSubview(chart3View)
        
        // 弹性
        let chart4View = ChartView()
        chart4View.backgroundColor = UIColor.clear
        chart4View.frame = CGRect(x: CGFloat(0), y: chart3View.frame.maxY + 15, width: CGFloat(kScreenFrameW), height: CGFloat(kScreenFrameH / 2) - 50)
        chart4View.setData(data1Array: tan1Array, data2Array: tan2Array, titlesArray: xTitles, title: "皮肤弹性值/%")
        scrollView.addSubview(chart4View)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 从服务器获取
    func getdata(){
        var parameters = [String: Any]()
        BFunction.shared.showLoading()
        let urlString = api_service + "/getmask"
        let userDefaults = UserDefaults.standard
        parameters["userid"] = userDefaults.value(forKey: "userid")
        parameters["page"] = "0";
        parameters["pagesize"] = "10";
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            BFunction.shared.hideLoadingMessage()
            if response.error != nil  {
                SVProgressHUD.showError(withStatus: "获取面膜数据失败")
                return
            }
            if let jsonResult = response.value as? Dictionary<String, Any> {
                if jsonResult.count == 0 {
                    self.initEView(flag: "1");
                } else {
                    if jsonResult["result"] as! Int == 0 {
                        SVProgressHUD.showInfo(withStatus: "获取面膜数据成功")
                        let data:Array<Dictionary> = jsonResult["data"] as! Array<Dictionary<String,Any>>;
                        var beanArray:[FaceDataModel] = [FaceDataModel]()
                        for item in data {
                            print(item)
                            if item.count == 9 {
                                let model:FaceDataModel = FaceDataModel.mj_object(withKeyValues: item);
                                print(model.beforeusecompactness)
                                beanArray.append(model);
                            }
                            
                        }
                        print(beanArray);
                        self.beanArrassy = beanArray;
                        self.initEView(flag: "2");
                    }else {
                        SVProgressHUD.showError(withStatus: "获取面膜数据失败")
                    }
                }
                
            }
            
        }
        
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
