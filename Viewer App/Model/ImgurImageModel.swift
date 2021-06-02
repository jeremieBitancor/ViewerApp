//
//  ImgurImageModel.swift
//  Viewer App
//
//  Created by jeremie bitancor on 6/2/21.
//

import Foundation

struct Images: Codable {
    let link: String
}

struct PostData: Codable {
    let id: String
    let title: String
    let link: String
    let images: [Images]?
}

struct PostDataList: Codable {
    let data: [PostData]
}
