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
   
    let operationQueue = NSOperationQueue()
    
    let cacheIdentifier: String
    
    init(URLTemplate: String, cacheIdentifier: String) {
        self.cacheIdentifier = cacheIdentifier
        super.init(URLTemplate: URLTemplate)
    }
    
    override func loadTileAtPath(path: MKTileOverlayPath, result: ((NSData!, NSError!) -> ())!) {
        if let result = result {
            let url = self.URLForTilePath(path)
            logger.log("Loading tile for path \(path) from URL \(url)...", forLevel: .Verbose)
            if let cachedData = cachedTileAtPath(path) {
                logger.log("Loaded cached tile for path \(path).", forLevel: .Debug)
                result(cachedData, nil)
            } else {
                let request = NSURLRequest(URL: url)
                NSURLConnection.sendAsynchronousRequest(request, queue: operationQueue, completionHandler: { response, data, error in
                    if data == nil || UIImage(data: data) == nil { // TODO: more efficiently check for error in response
                        self.logger.log("Could not load tile for path \(path) from URL \(url).", forLevel: .Verbose)
                    } else {
                        self.cacheTile(data, atPath: path)
                        self.logger.log("Loaded tile for path \(path).", forLevel: .Verbose)
                    }
                    result(data, error)
                })
            }
        }
    }
    
    func cachedTileAtPath(path: MKTileOverlayPath) -> NSData? {
        if let cachedFileURL = cachedFileURLForTileAtPath(path) {
            return NSData(contentsOfURL: cachedFileURL)
        } else {
            return nil
        }
    }
    
    func cacheTile(data: NSData, atPath path: MKTileOverlayPath) {
        if let cachedFileURL = cachedFileURLForTileAtPath(path) {
            if let directoryPath = cachedFileURL.URLByDeletingLastPathComponent?.path {
                var createDirectoriesError: NSError?
                if NSFileManager.defaultManager().createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil, error: &createDirectoriesError) {
                    if let cachedFilePath = cachedFileURL.path {
                        var writeError: NSError?
                        if NSFileManager.defaultManager().createFileAtPath(cachedFilePath, contents: data, attributes: nil) {
                            self.logger.log("Cached tile for path \(path) at \(cachedFilePath).", forLevel: .Verbose)
                        } else {
                            self.logger.log("Failed to cache tile at path \(path) at \(cachedFilePath) with error: \(writeError)", forLevel: .Warning)
                        }
                    } else {
                        self.logger.log("Failed to cache tile at path \(path) at \(cachedFileURL).", forLevel: .Warning)
                    }
                } else {
                    self.logger.log("Failed to create cache directory for tile at path \(path) at \(directoryPath) with error: \(createDirectoriesError)", forLevel: .Warning)
                }
            } else {
                self.logger.log("Failed to create cache directory for tile at path \(path) at \(cachedFileURL).", forLevel: .Warning)
            }
        }
    }
    
    func cachedFileURLForTileAtPath(path: MKTileOverlayPath) -> NSURL? {
        if let cachesDirectory = NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: nil) {
            return NSURL(string: "map-tiles/\(cacheIdentifier)/\(path.z)/\(path.x)/\(path.y).png", relativeToURL: cachesDirectory)
        } else {
            return nil
        }
    }

}

extension MKTileOverlayPath: Printable {
    
    public var description: String {
        return "(\(self.z),\(self.x),\(self.y))"
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
