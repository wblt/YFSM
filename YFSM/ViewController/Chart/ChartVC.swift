//
//  ChartVC.swift
//  YFSMM
//
//  Created by Alvin on 2017/6/17.
//  Copyright © 2017年 Alvin. All rights reserved.
//

import UIKit

class ChartVC: BaseVC {
   var isYIsPercent: Bool = false
   // var lineChart:PNLineChart!
    
    var xTitles:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "水油数据表"


        let modelArry = ChartModel.search(withWhere: ["step":2], orderBy: nil, offset: 0, count: 65535) as! [ChartModel]
        

        var oil1Array:[String] = []
        var oil2Array:[String] = []
        var water1Array:[String] = []
        var water2Array:[String] = []
        
        for model in modelArry {
            var dateStr = "\(model.date)".substringFromIndex(4)!
            let stingIndex = dateStr.index(dateStr.startIndex, offsetBy: 2)
            dateStr.insert("-", at: stingIndex)
            xTitles.append(dateStr)
            
            oil1Array.append("\(model.oil1)")
            oil2Array.append("\(model.oil2)")
            water1Array.append("\(model.water1)")
            water2Array.append("\(model.water2)")
        }
        
        
        
        let chartView = ChartView()
        chartView.backgroundColor = UIColor.clear
        chartView.frame = CGRect(x: CGFloat(0), y: CGFloat(64), width: CGFloat(kScreenFrameW), height: CGFloat(kScreenFrameH / 2) - 50)
        chartView.setData(data1Array: water1Array, data2Array: water2Array, titlesArray: xTitles, title: "皮肤水份/%")
        self.view.addSubview(chartView)

        
        let chart2View = ChartView()
        chart2View.backgroundColor = UIColor.clear
        chart2View.frame = CGRect(x: CGFloat(0), y: chartView.frame.maxY + 15, width: CGFloat(kScreenFrameW), height: CGFloat(kScreenFrameH / 2) - 50)
        chart2View.setData(data1Array: oil1Array, data2Array: oil2Array, titlesArray: xTitles, title: "皮肤油份/%")
        self.view.addSubview(chart2View)
        
        
        
    }
    
  
    
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
