//
//  PdfPostModel.swift
//  Viewer App
//
//  Created by jeremie bitancor on 6/2/21.
//

import Foundation

struct PdfPost {
    let title: String
    let description: String
    let detail: String
}

struct PdfPostList {
    let list: [PdfPost]
}
