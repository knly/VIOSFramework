//
//  VICaptureSessionManager.m
//  cardvision
//
//  Created by Nils Fischer on 16.12.13.
//  Copyright (c) 2013 Nils Fischer. All rights reserved.
//

#import "VICaptureSessionManager.h"

@implementation VICaptureSessionManager

- (AVCaptureSession *)captureSession
{
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}

- (void)setInputMediaType:(NSString *)mediaType
{
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:mediaType];
    if (!videoDevice) {
        [self.logger log:@"Couldn't create video capture device" error:nil];
        return;
    }
    
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (error) {
        [self.logger log:@"Couldn't create video input" error:error];
        return;
    }
    
    if (![self.captureSession canAddInput:deviceInput]) {
        [self.logger log:@"Couldn't add video input" error:nil];
        return;
    }
    [self.captureSession addInput:deviceInput];
}

- (void)setOutput:(AVCaptureOutput *)output
{
    if (![self.captureSession canAddOutput:output]) {
        [self.logger log:@"Couldn't add output" error:nil];
    }
    [self.captureSession addOutput:output];
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

@end
