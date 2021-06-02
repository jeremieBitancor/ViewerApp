//
//  BookModel.swift
//  Viewer App
//
//  Created by jeremie bitancor on 6/2/21.
//

import Foundation

class ViewerItems {
    var pdfItem = [PdfItem]()
    var imageItem = ImageItem()
}

class PdfItem {
    var fileName = ""
    var description = ""
}

class ImageItem {
    var retrieve_images = ""
    var image_count = ""
    var convertedRetrieveImages: Bool {
        if retrieve_images == "true" {
            return true
        } else {
            return false
        }
    }
    var convertedImageCount: Int {
        return Int(image_count)!
    }
}
