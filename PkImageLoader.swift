//
//  PkImageLoader.swift
//  ImageLoader
//
//  Created by Pawan Kumar on 04/07/19.
//  Copyright © 2019 com.pawanLine.hari. All rights reserved.
//

import Foundation
import UIKit

class PKImageLoader {
    let imageCache = NSCache<NSString, UIImage>()

    class var sharedLoader: PKImageLoader {
        struct Static {
            static let instance: PKImageLoader = PKImageLoader()
        }
        return Static.instance
    }

    func imageForUrl(urlPath: String, completionHandler: @escaping (_ image: UIImage?, _ url: String) -> ()) {
        guard let url = urlPath.toUrl else {
            return
        }
        if let image = imageCache.object(forKey: urlPath as NSString) {
            completionHandler(image, urlPath)
        }
        else {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let finalData = data else { return }

                DispatchQueue.main.async {
                    if let img = UIImage(data: finalData) {
                        self.imageCache.setObject(img, forKey: urlPath as NSString)
                         completionHandler(img, urlPath)
                    }
                }
            }.resume()
        }
    }
}

extension UIImageView {
    func setImage(from urlPath: String, placeHolder: UIImage? = nil) {
        self.image = placeHolder
        PKImageLoader.sharedLoader.imageForUrl(urlPath: urlPath) { image, _ in
            self.image = image
        }
    }
}

/// EZSE: Converts String to URL

extension String {
    var toUrl: URL? {
        if self.hasPrefix("https://") || self.hasPrefix("http://") {
            return URL(string: self)
        }
        else {
            return URL(fileURLWithPath: self)
        }
    }
}
