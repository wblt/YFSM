//
//  ChartModel.swift
//  YFSMM
//
//  Created by Alvin on 2017/7/8.
//  Copyright © 2017年 Alvin. All rights reserved.
//

import UIKit

class ChartModel: NSObject {

    
    var water1:Int = 0 //水份使用前

    var water2:Int = 0 //水份使用后

    var oil1:Int = 0//油份使用前
    
    var oil2:Int = 0//油份使用后
    
    var date = 0 //日期
    
    var step = 0 //步骤
    
    override static func getPrimaryKey() -> String {
        return "date"
    }
    override static func getTableName() -> String {
        return "LKTable"
    }
}
