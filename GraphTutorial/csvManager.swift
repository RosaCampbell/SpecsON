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
    var columnTitles:[String] = []
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
    
    func removeUnwantedHeaderInfo(totalString: String)->String{
        let stringParts = totalString.components(separatedBy: "Date Time")
        var tableString = stringParts[1]
        tableString.insert(contentsOf: "Date Time", at: tableString.startIndex)
        return tableString
    }
    
    func cleanFields(oldString:String) -> [String]{
        let delimiter = "\t"
        let newString = oldString.replacingOccurrences(of: ",", with: delimiter)
        return newString.components(separatedBy: delimiter)
    }
    
    
    func convertCSV(stringData:String, stringFileName: String) -> [[String:String]] {
        fileName = stringFileName
        let tableData = removeUnwantedHeaderInfo(totalString: stringData)
        let rows = cleanRows(stringData: tableData)
        if rows.count > 0 {
            data = []
            columnTitles = cleanFields(oldString: rows.first!)
            for row in 1..<rows.count {
                let fields = cleanFields(oldString: rows[row])
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
        formatDateTimeColumn()
        return data
    }
    
    func getStatusFromTemperature()-> Void {
        columnTitles.append("Difference")
        columnTitles.append("State")
        for row in 0..<data.count {
            if let strObjTemp = data[row]["Object"] {
                if let strAmbTemp = data[row]["Ambient"] {
                    let flObjTemp = Float(strObjTemp)
                    let flAmbTemp = Float(strAmbTemp)
                    if (flObjTemp != nil) && (flAmbTemp != nil) {
                        let flTempDiff = flObjTemp! - flAmbTemp!
                        var state: String = "0"
                        if (flTempDiff > (-0.21*flAmbTemp!) + 7) {
                            state = "1"
                        } else {
                            state = "0"
                        }
                        data[row]["Difference"] = String(flTempDiff)
                        data[row]["State"] = state
                    }
                }
            }
        }
    }
    
    func formatDateTimeColumn()-> Void {
        data[0]["Date Time"] = formatStartDateFromFileName(strFileName: fileName)
        for row in 1..<(data.count-1) {
            let prevDate = data[row - 1]["Date Time"] ?? ""
            data[row]["Date Time"] = addIntervalTo(strDate: prevDate)
        }
    }
    
    func addIntervalTo(strDate: String)-> String {

        // set the recieved and required date format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm"

        // convert string to date
        let prevDate = dateFormatter.date(from: strDate)

        // Add 5 minutes to current date
        if let newDate = prevDate?.addingTimeInterval(5.0*60.0) {
            // convert date back into string in correct format
            return dateFormatter.string(from: newDate)
        }
        return "Error uwrapping optional 'prevDate'"
    }
    
    func formatStartDateFromFileName(strFileName: String?) -> String {
        guard let fileName = strFileName else {
            return ""
        }

        // Get only date/time part of file name
        let strFileNameParts = fileName.components(separatedBy: ["_", "."])
        let strStartDate = strFileNameParts[1]

        // Create a formatter to parse files date format
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyyMMddHHmm"

        let dateFormatterDisplay = DateFormatter()
        dateFormatterDisplay.dateFormat = "MMM dd, yyyy HH:mm"

        let date = dateFormatterGet.date(from: strStartDate)
        if let newDate = date {
            return dateFormatterDisplay.string(from: newDate)
        }
        return "Date not in format yyyMMddHHmm"
    }
}
