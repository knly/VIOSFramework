//
//  VICaptureSessionManager.h
//  cardvision
//
//  Created by Nils Fischer on 16.12.13.
//  Copyright (c) 2013 Nils Fischer. All rights reserved.
//

@import AVFoundation;

#import "VIManager.h"

@interface VICaptureSessionManager : VIManager

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

- (void)setInputMediaType:(NSString *)mediaType;
- (void)setOutput:(AVCaptureOutput *)output;

@end
