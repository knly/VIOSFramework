//
//  CachedTileOverlay.swift
//  uni-hd
//
//  Created by Nils Fischer on 25.11.14.
//  Copyright (c) 2014 Universität Heidelberg. All rights reserved.
//

import Foundation
import MapKit
import VILogKit

class CachedTileOverlay: MKTileOverlay {
   
    let cache = NSCache()
    let operationQueue = NSOperationQueue()
    
    override func loadTileAtPath(path: MKTileOverlayPath, result: ((NSData!, NSError!) -> ())!) {
        // FIXME: caching does not work
        if let result = result {
            if let cachedData = self.cache.objectForKey(self.URLForTilePath(path).absoluteString!) as? NSData {
                logger.log("Loaded cached tile for path (\(path.z),\(path.x),\(path.y))", forLevel: .Verbose)
                result(cachedData, nil)
            } else {
                let url = self.URLForTilePath(path)
                let request = NSURLRequest(URL: url)
                logger.log("Requesting tile for path (\(path.z),\(path.x),\(path.y)) from URL \(url)...", forLevel: .Verbose)
                NSURLConnection.sendAsynchronousRequest(request, queue: operationQueue, completionHandler: { response, data, error in
                    var imageData: NSData! = nil
                    if UIImage(data: data) == nil { // TODO: more efficiently check for error in response
                        self.logger.log("Could not load tile for path (\(path.z),\(path.x),\(path.y)) from URL \(url).", forLevel: .Verbose)
                    } else {
                        imageData = data
                        self.cache.setObject(imageData, forKey: url.absoluteString!)
                        self.logger.log("Loaded and cached tile for path (\(path.z),\(path.x),\(path.y)).", forLevel: .Debug)
                    }
                    result(imageData, error)
                })
            }
        }
    }

}


// MARK: Logging

extension CachedTileOverlay {
    var logger: Logger {
        // TOOD: dont do this
        let logger = Logger.loggerForKeyPath("VIOSFramework.CachedTileOverlay")
        logger.logLevel = .Debug
        return logger
    }
}
