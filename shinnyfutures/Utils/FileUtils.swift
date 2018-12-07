//
//  FileUtils.swift
//  shinnyfutures
//
//  Created by chenli on 2018/4/20.
//  Copyright © 2018年 xinyi. All rights reserved.
//

import Foundation

class FileUtils {

    //读取latest文件
//    class func readLatestFile() -> String? {
//        let manager = FileManager.default
//        let urlsForDocDirectory = manager.urls(for: .documentDirectory, in: .userDomainMask)
//        let docPath = urlsForDocDirectory[0]
//        let file = docPath.appendingPathComponent("latest.json")
//        let readHandler = try! FileHandle(forReadingFrom: file)
//        let data = readHandler.readDataToEndOfFile()
//        return String(data: data, encoding: .utf8)
//    }

    //保存自选合约
    class func saveOptional(ins: [String]) {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirectory.appendingPathComponent("optional")
            (ins as NSArray).write(to: fileURL, atomically: true)
        } catch {
            print(error)
        }
    }

    //读取自选合约
    class func getOptional() -> [String] {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirectory.appendingPathComponent("optional")
            if let data = NSArray(contentsOf: fileURL) as? [String] {
                return data
            } else {
                return [String]()
            }

        } catch {
            print(error)
        }
        return [String]()
    }
}
