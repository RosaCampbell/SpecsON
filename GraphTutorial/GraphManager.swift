//
//  GraphManager.swift
//  GraphTutorial
//
//  Created by Rosa Campbell on 21/08/20.
//  Copyright © 2020 Campbell. All rights reserved.
//

import Foundation
import MSGraphClientSDK
import MSGraphClientModels

class GraphManager {

    // Implement singleton pattern
    static let instance = GraphManager()
    private let client: MSHTTPClient?

    private init() {
        client = MSClientFactory.createHTTPClient(with: AuthenticationManager.instance)
    }


    public func getMe(completion: @escaping(MSGraphUser?, Error?) -> Void) {
        let meRequest = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me")!)
        let meDataTask = MSURLSessionDataTask(request: meRequest, client: self.client, completion: {
            (data: Data?, response: URLResponse?, graphError: Error?) in
            guard let meData = data, graphError == nil else {
                completion(nil, graphError)
                return
            }
            do {
                // Deserialize response as a user
                let user = try MSGraphUser(data: meData)
                completion(user, nil)
            } catch {
                completion(nil, error)
            }
        })
        meDataTask?.execute()
    }
    
    public func getCsvFiles(completion: @escaping([MSGraphDriveItem]?, Error?) -> Void) {
        let driveItemsRequest = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/drive/root/children")!)
        let driveItemDataTask = MSURLSessionDataTask(request: driveItemsRequest, client: self.client, completion: {
            (data: Data?, response: URLResponse?, graphError: Error?) in
            guard let driveItemsData = data, graphError == nil else {
                completion(nil, graphError)
                return
            }
            do {
                // Deserialize response as drive items collection
                let driveItemsCollection = try MSCollection(data: driveItemsData)
                var driveItemsArray: [MSGraphDriveItem] = []

                driveItemsCollection.value.forEach({
                    (rawDriveItem: Any) in
                    // Convert JSON to a dictionary
                    guard let driveItemDict = rawDriveItem as? [String: Any] else {
                        return
                    }
                    // Deserialize drive item from the dictionary
                    let driveItem = MSGraphDriveItem(dictionary: driveItemDict)!
                    
                    // Only append csv files:
                    let isCsvFile = driveItem.name?.contains(".csv")
                    if isCsvFile! {
                        driveItemsArray.append(driveItem)
                    }
                })
                completion(driveItemsArray, nil)
            } catch {
                completion(nil, error)
            }
        })
        driveItemDataTask?.execute()
    }
    
    public func getFileURL(fileId: String, completion: @escaping(Data?, String?, Error?) -> Void) {
        let fileContentsRequest = NSMutableURLRequest(url: URL(string: "\(MSGraphBaseURL)/me/drive/items/\(fileId)/content")!)
        fileContentsRequest.httpMethod = "GET"
        let fileContentsDataTask = MSURLSessionDataTask(request: fileContentsRequest, client: self.client, completion: {
            (data: Data?, response: URLResponse?, graphError: Error?) in
            guard let fileContentsData = data, let fileResponse = response, graphError == nil else {
                completion(nil, nil, graphError)
                return
            }
            if (graphError as NSError?) != nil {
                print("Error: Downloaded URL not found")
                completion(nil, nil, graphError)
            } else {
                // Return the file contents
                if let fileLocation = fileResponse.url {
                    completion(fileContentsData, fileLocation.absoluteString, nil)
                }
            }
        })
        fileContentsDataTask?.execute()
    }
}
