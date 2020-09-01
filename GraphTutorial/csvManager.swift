//
//  MyCSVManager.swift
//  GraphTutorial
//
//  Created by Rosa Campbell on 25/08/20.
//  Copyright © 2020 Campbell. All rights reserved.
//

import UIKit
import MSGraphClientModels

class csvManager: NSObject {

    var data:[[String:String]] = []
    var hourlyData:[[[String:String]]] = []
    var dailyData:[[[String:String]]] = []
    
    var columnTitles:[String] = []
    //var columnType:[String] = ["Float","Float"]
    var fileName: String = ""
    
    func readStringFromURL(stringURL:String)-> String!{
        
        if let url = NSURL(string: stringURL) {
            do {
                return try String(contentsOf: url as URL)
            } catch {
                print("Cannot load contents from: \(url)")
                return nil
            }
        } else {
            print("String was not a URL")
            return nil
        }
    }
    
    func cleanRows(stringData:String)->[String]{
        var cleanFile = stringData
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of:"\n\n", with: "\n")
        return cleanFile.components(separatedBy: "\n")
    }
    
    func cleanFields(oldString:String) -> [String]{
        let delimiter = "\t"
        let newString = oldString.replacingOccurrences(of: ",", with: delimiter)
        return newString.components(separatedBy: delimiter)
    }
    
    func convertCSV(stringData:String, stringFileName: String) -> [[String:String]] {
        fileName = stringFileName
        let rows = cleanRows(stringData: stringData)
        if rows.count > 0 {
            data = []
            columnTitles = cleanFields(oldString: rows.first!)
            for row in rows{
                let fields = cleanFields(oldString: row)
                if fields.count != columnTitles.count { continue }
                var newRow = [String:String]()
                for index in 0..<fields.count{
                    newRow[columnTitles[index]] = fields[index]
                    
                }
                data.append(newRow)
            }
        } else {
            print("No data in file")
        }
        getStatusFromTemperature()
        return data
    }
    
    func getStatusFromTemperature()-> Void {
        columnTitles.append("Diff")
        columnTitles.append("State")
        for row in 1..<data.count {
            if let strObjTemp = data[row]["Obj"] {
                if let strAmbTemp = data[row]["Amb"] {
                    let flObjTemp = Float(strObjTemp)
                    let flAmbTemp = Float(strAmbTemp)
                    let flTempDiff = flObjTemp! - flAmbTemp!
                    var state: String = "0"
                    if (flObjTemp!>23 && flAmbTemp!>3) || (flObjTemp!>30 && flAmbTemp!>30) {
                        state = "1"
                    } else {
                        state = "0"
                    }
                    data[row]["Diff"] = String(flTempDiff)
                    data[row]["State"] = state
                }
            }
        }
    }
}
