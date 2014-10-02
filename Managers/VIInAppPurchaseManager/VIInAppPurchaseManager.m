//
//  VIInAppPurchaseManager.m
//  21
//
//  Created by Nils Fischer on 19.06.13.
//
//

#import "VIInAppPurchaseManager.h"

#import <objc/runtime.h>

@interface SKRequest (VICategory)

@property (copy, nonatomic) NSSet *productIdentifiers;

@end

NSString * const kSKRequestProductIdentifiersProperty = @"kSKRequestProductIdentifiersProperty";

@implementation SKRequest (VICategory)

- (void)setProductIdentifiers:(NSSet *)productIdentifiers {
	objc_setAssociatedObject(self, &kSKRequestProductIdentifiersProperty, productIdentifiers, OBJC_ASSOCIATION_COPY);
}

- (NSSet *)productIdentifiers
{
	return objc_getAssociatedObject(self, &kSKRequestProductIdentifiersProperty);
}

@end

@interface VIInAppPurchaseManager ()

@property (strong, nonatomic) NSMutableDictionary *products;

- (void)processSuccessfulPurchaseForProduct:(VIInAppPurchaseProduct *)product;

@end

@implementation VIInAppPurchaseManager

- (id)init {
    if (self = [super init]) {
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:[NSUserDefaults standardUserDefaults]];

    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark - Requesting Products

- (VIInAppPurchaseProduct *)productForIdentifier:(NSString *)productIdentifier {
    if (!productIdentifier) return nil;
    if (![self.products objectForKey:productIdentifier]) {
        VIInAppPurchaseProduct *product = [VIInAppPurchaseProduct productWithIdentifier:productIdentifier];
        if (!self.products) self.products = [[NSMutableDictionary alloc] init];
        [self.products setObject:product forKey:productIdentifier];
        product.state = ([self hasPurchasedProductWithIdentifier:product.productIdentifier]) ? VIInAppPurchaseProductStatePurchased : VIInAppPurchaseProductStateUnverified;

    }
    return [self.products objectForKey:productIdentifier];
}

- (void)verifyProduct:(VIInAppPurchaseProduct *)product {
    if (!product) return;

    [self.logger log:@"Verifying product..." object:product.productIdentifier forLevel:VILogLevelDebug];

    if (product.state!=VIInAppPurchaseProductStateUnverified) {
        [self.logger log:@"Product already verified." object:product.productIdentifier forLevel:VILogLevelDebug];
        return;
    }

	product.state = VIInAppPurchaseProductStateVerifying;

	SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:product.productIdentifier]];
    productRequest.productIdentifiers = [NSSet setWithObject:product.productIdentifier];
	productRequest.delegate = self;
	[productRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

    // verified products
	for (SKProduct *skproduct in response.products) {
        VIInAppPurchaseProduct *product = [self productForIdentifier:skproduct.productIdentifier];

        product.product = skproduct;
        product.state = VIInAppPurchaseProductStateVerified;

        [self.logger log:@"Product verification successful." object:product.productIdentifier forLevel:VILogLevelDebug];

	}

    // invalid products
	for (NSString *productIdentifier in response.invalidProductIdentifiers) {
        VIInAppPurchaseProduct *product = [self productForIdentifier:productIdentifier];
        product.state = VIInAppPurchaseProductStateUnverified;
        [self.logger log:@"Product verification failed." object:product.productIdentifier forLevel:VILogLevelWarning];
	}
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [self.logger log:@"Product request failed." object:error forLevel:VILogLevelDebug];

	for (NSString *productIdentifier in request.productIdentifiers) {
        VIInAppPurchaseProduct *product = [self productForIdentifier:productIdentifier];
        product.error = error;
        product.state = VIInAppPurchaseProductStateUnverified;
        [self.logger log:@"Product verification failed." object:product.productIdentifier forLevel:VILogLevelWarning];
	}
}

#pragma mark - Purchasing Products

- (void)purchaseProduct:(VIInAppPurchaseProduct *)product {
    if (!product) return;
    
    [self.logger log:@"Initiating product purchase..." object:product.productIdentifier forLevel:VILogLevelDebug];
    
    if (![SKPaymentQueue canMakePayments]) {
        
        [self.logger log:@"Purchases disabled, aborting product purchase." object:product.productIdentifier forLevel:VILogLevelWarning];
        
        UIAlertView *newAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"purchases_disabled_alert_title", @"") message:NSLocalizedString(@"purchases_disabled_alert_msg", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_button_title", @"") otherButtonTitles:nil];
        [newAlertView show];
        return;
    }
    SKPayment *payment = [SKPayment paymentWithProduct:product.product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


#pragma mark - Restoring previous purchases

- (void)restorePreviousPurchases {
    [self.logger log:@"Initiating restore previous purchases..." forLevel:VILogLevelDebug];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


#pragma mark - Transaction Observer

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {

        VIInAppPurchaseProduct *product = [self productForIdentifier:(transaction.transactionState==SKPaymentTransactionStateRestored)?transaction.originalTransaction.payment.productIdentifier:transaction.payment.productIdentifier];

        switch (transaction.transactionState) {
                
            case SKPaymentTransactionStatePurchasing:
                [self.logger log:@"Updated transaction state: purchasing" object:product.productIdentifier forLevel:VILogLevelDebug];
                product.state = VIInAppPurchaseProductStatePurchasing;
                break;
                
            case SKPaymentTransactionStatePurchased:
                [self.logger log:@"Updated transaction state: purchased" object:product.productIdentifier forLevel:VILogLevelDebug];
                [self processSuccessfulPurchaseForProduct:product];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                [self.logger log:@"Updated transaction state: failed" object:product.productIdentifier forLevel:VILogLevelDebug];
                product.state = VIInAppPurchaseProductStateVerified;
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateRestored:
                [self.logger log:@"Updated transaction state: restored" object:product.productIdentifier forLevel:VILogLevelDebug];
                [self processSuccessfulPurchaseForProduct:product];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
}
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    [self.logger log:@"Restore previous purchases failed." object:error forLevel:VILogLevelWarning];
}
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    [self.logger log:@"Restore previous purchases finished." forLevel:VILogLevelDebug];
}

#pragma mark - Content Delivery
		  
- (void)processSuccessfulPurchaseForProduct:(VIInAppPurchaseProduct *)product {
    if (!product) return;
    [self.logger log:@"Product purchased successfully." object:product.productIdentifier forLevel:VILogLevelInfo];
	[[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:product.productIdentifier];
    product.state = VIInAppPurchaseProductStatePurchased;
}

- (BOOL)hasPurchasedProductWithIdentifier:(NSString *)productIdentifier {
    if (!productIdentifier) return NO;
	return [[[NSUserDefaults standardUserDefaults] objectForKey:productIdentifier] boolValue];
}

#pragma mark - Update Product State from User Defaults Change

- (void)userDefaultsDidChange:(NSNotification *)notification {
    NSDictionary *userDefaults = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    [userDefaults enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        VIInAppPurchaseProduct *product = [self.products objectForKey:key];
        if (product) {
            product.state = ([self hasPurchasedProductWithIdentifier:product.productIdentifier]) ? VIInAppPurchaseProductStatePurchased : VIInAppPurchaseProductStateUnverified;
        }
    }];
}

@end
