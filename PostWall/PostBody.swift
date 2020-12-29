//
//  PostBody.swift
//  PostWall
//
//  Created by 翁淑惠 on 2020/12/22.
//

import Foundation

//for output
struct PostBody: Codable {
    let records: [Record]

    struct Record: Codable {
        let fields: Fields
    }

    struct Fields: Codable {
        var name: String
        var postDate: String
        var image: [imageData]
        var article: String
    }

    struct imageData: Codable {
        var url: String
    }
}

//for input
struct UploadImgurResult: Decodable {
    let data: Data
    
    struct Data: Decodable {
        let link: String
    }
}

func dateFormatter(formatType: String) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_TW")
    formatter.dateFormat = formatType
    return formatter
}
