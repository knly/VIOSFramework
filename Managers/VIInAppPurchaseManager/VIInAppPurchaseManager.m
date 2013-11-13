//
//  VIInAppPurchaseManager.m
//  21
//
//  Created by Nils Fischer on 19.06.13.
//
//

#import "VIInAppPurchaseManager.h"
#import "VILogger.h"

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

@property (strong, nonatomic) VILogger *logger;

- (void)processSuccessfulPurchaseForProduct:(VIInAppPurchaseProduct *)product;

@end

@implementation VIInAppPurchaseManager

+ (VIInAppPurchaseManager *)defaultManager {

    static VIInAppPurchaseManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
    });
    return defaultManager;

}

- (id)init {
    if (self = [super init]) {
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
    }
    return self;
}

#pragma mark - Requesting Products

- (VIInAppPurchaseProduct *)productForIdentifier:(NSString *)productIdentifier {
    if (!productIdentifier) return nil;
    if (![self.products objectForKey:productIdentifier]) {
        VIInAppPurchaseProduct *product = [VIInAppPurchaseProduct productWithIdentifier:productIdentifier];
        if (!self.products) self.products = [[NSMutableDictionary alloc] init];
        [self.products setObject:product forKey:productIdentifier];
        if ([self hasPurchasedProductWithIdentifier:product.productIdentifier]) product.state = VIInAppPurchaseProductStatePurchased;
        else product.state = VIInAppPurchaseProductStateUnverified;

    }
    return [self.products objectForKey:productIdentifier];
}

- (void)verifyProduct:(VIInAppPurchaseProduct *)product {
    if (!product) return;

    [self.logger log:@"verify product" object:product.productIdentifier forLevel:VILogLevelInfo];

    if (product.state!=VIInAppPurchaseProductStateUnverified) {
        [self.logger log:@"product not unverified" object:product.productIdentifier forLevel:VILogLevelInfo];
        return;
    }

    [self.logger log:@"start product request" object:product.productIdentifier forLevel:VILogLevelInfo];

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

        [self.logger log:@"verification successful" object:product.productIdentifier forLevel:VILogLevelInfo];

	}

    // invalid products
	for (NSString *productIdentifier in response.invalidProductIdentifiers) {
        VIInAppPurchaseProduct *product = [self productForIdentifier:productIdentifier];
        product.state = VIInAppPurchaseProductStateUnverified;
        [self.logger log:@"verification failed" object:product.productIdentifier forLevel:VILogLevelInfo];
	}
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [self.logger log:@"request failed" object:error forLevel:VILogLevelInfo];

	for (NSString *productIdentifier in request.productIdentifiers) {
        VIInAppPurchaseProduct *product = [self productForIdentifier:productIdentifier];
        product.error = error;
        product.state = VIInAppPurchaseProductStateUnverified;
        [self.logger log:@"verification failed" object:product.productIdentifier forLevel:VILogLevelInfo];
	}
}

#pragma mark - Purchasing Products

- (void)purchaseProduct:(VIInAppPurchaseProduct *)product {
    if (!product) return;
    if (![SKPaymentQueue canMakePayments]) {
        UIAlertView *newAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"purchases_disabled_alert_title", @"") message:NSLocalizedString(@"purchases_disabled_alert_msg", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_button_title", @"") otherButtonTitles:nil];
        [newAlertView show];
        return;
    }
    SKPayment *payment = [SKPayment paymentWithProduct:product.product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


#pragma mark - Restoring previous purchases

- (void)restorePreviousPurchases {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


#pragma mark - Transaction Observer

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {

        VIInAppPurchaseProduct *product = [self productForIdentifier:(transaction.transactionState==SKPaymentTransactionStateRestored)?transaction.originalTransaction.payment.productIdentifier:transaction.payment.productIdentifier];

        switch (transaction.transactionState) {
                
            case SKPaymentTransactionStatePurchasing:
                [self.logger log:@"updated transaction state: purchasing" object:product.productIdentifier forLevel:VILogLevelInfo];
                product.state = VIInAppPurchaseProductStatePurchasing;
                break;
                
            case SKPaymentTransactionStatePurchased:
                [self.logger log:@"updated transaction state: purchased" object:product.productIdentifier forLevel:VILogLevelInfo];
                [self processSuccessfulPurchaseForProduct:product];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                [self.logger log:@"updated transaction state: failed" object:product.productIdentifier forLevel:VILogLevelInfo];
                product.state = VIInAppPurchaseProductStateVerified;
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateRestored:
                [self.logger log:@"updated transaction state: restored" object:product.productIdentifier forLevel:VILogLevelInfo];
                [self processSuccessfulPurchaseForProduct:product];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
}
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    [self.logger log:@"restore previous purchases failed" object:error forLevel:VILogLevelInfo];
}
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    [self.logger log:@"restore previous purchases finished" forLevel:VILogLevelInfo];
}

#pragma mark - Content Delivery
		  
- (void)processSuccessfulPurchaseForProduct:(VIInAppPurchaseProduct *)product {
    if (!product) return;
    [self.logger log:@"process successful purchase" object:product.productIdentifier forLevel:VILogLevelInfo];
	[[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:product.productIdentifier];
    product.state = VIInAppPurchaseProductStatePurchased;
}

- (BOOL)hasPurchasedProductWithIdentifier:(NSString *)productIdentifier {
    if (!productIdentifier) return NO;
	return [[[NSUserDefaults standardUserDefaults] objectForKey:productIdentifier] boolValue];
}

#pragma mark - Logger

- (VILogger *)logger {
    if (!_logger) {
        self.logger = [[VILogger alloc] init];
    }
    return _logger;
}


@end
