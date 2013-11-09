//
//  VIInAppPurchaseProduct.h
//  21
//
//  Created by Nils Fischer on 06.11.13.
//
//

@import StoreKit;

enum VIInAppPurchaseProductState {
    VIInAppPurchaseProductStateUnverified,
    VIInAppPurchaseProductStateVerifying,
    VIInAppPurchaseProductStateVerified,
    VIInAppPurchaseProductStatePurchasing,
    VIInAppPurchaseProductStatePurchased
};

#define VIInAppPurchaseProductDidChangeStateNotification @"VIInAppPurchaseProductDidChangeStateNotification"

@interface VIInAppPurchaseProduct : NSObject

@property (nonatomic) uint state;
@property (strong, nonatomic) NSString *productIdentifier;

@property (strong, nonatomic) SKProduct *product;
@property (strong, nonatomic) NSError *error;

@property (weak, nonatomic) id object;
@property (nonatomic) int tag;

@property (readonly) NSString *title;
@property (readonly) NSString *description;
@property (readonly) NSString *priceAsString;

+ (VIInAppPurchaseProduct *)productWithIdentifier:(NSString *)productIdentifier;

@end
