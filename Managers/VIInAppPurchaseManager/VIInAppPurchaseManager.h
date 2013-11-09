//
//  VIInAppPurchaseManager.h
//  21
//
//  Created by Nils Fischer on 19.06.13.
//
//

@import StoreKit;
#import "VIInAppPurchaseProduct.h"

@interface VIInAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

+ (VIInAppPurchaseManager *)defaultManager;

- (VIInAppPurchaseProduct *)productForIdentifier:(NSString *)productIdentifier;
- (void)verifyProduct:(VIInAppPurchaseProduct *)product;
- (void)purchaseProduct:(VIInAppPurchaseProduct *)product;
- (void)restorePreviousPurchases;
- (BOOL)hasPurchasedProductWithIdentifier:(NSString *)productIdentifier;

@end