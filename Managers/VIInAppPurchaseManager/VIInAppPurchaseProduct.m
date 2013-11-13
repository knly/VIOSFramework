//
//  VIInAppPurchaseProduct.m
//  21
//
//  Created by Nils Fischer on 06.11.13.
//
//

#import "VIInAppPurchaseProduct.h"

@implementation VIInAppPurchaseProduct

+ (VIInAppPurchaseProduct *)productWithIdentifier:(NSString *)productIdentifier {
    VIInAppPurchaseProduct *product = [[VIInAppPurchaseProduct alloc] init];
    product.productIdentifier = productIdentifier;
    return product;
}

- (id)init {
    if ((self=[super init])) {
        _state = VIInAppPurchaseProductStateUnverified;
    }
    return self;
}

#pragma mark - States

- (void)setState:(uint)state {
    if (_state==state) return;
    _state = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:VIInAppPurchaseProductDidChangeStateNotification object:self userInfo:nil];
}

#pragma mark - Product Information

- (NSString *)title {
    return self.product.localizedTitle;
}

- (NSString *)description {
    return self.product.localizedDescription;
}

- (NSString *)priceAsString {
    if (!self.product) return nil;

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:[self.product priceLocale]];

    return [formatter stringFromNumber:[self.product price]];
}

@end
