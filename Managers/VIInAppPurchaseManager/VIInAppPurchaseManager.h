//
//  VIInAppPurchaseManager.h
//  21
//
//  Created by Nils Fischer on 19.06.13.
//
//

@import Foundation;
@import StoreKit;
#import "VIManager.h"
#import "VIInAppPurchaseProduct.h"

@interface VIInAppPurchaseManager : VIManager <SKProductsRequestDelegate, SKPaymentTransactionObserver>

- (VIInAppPurchaseProduct *)productForIdentifier:(NSString *)productIdentifier;
- (void)verifyProduct:(VIInAppPurchaseProduct *)product;
- (void)purchaseProduct:(VIInAppPurchaseProduct *)product;
- (void)restorePreviousPurchases;
- (BOOL)hasPurchasedProductWithIdentifier:(NSString *)productIdentifier;

@end