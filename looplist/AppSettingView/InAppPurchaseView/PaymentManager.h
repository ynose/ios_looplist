//
//  PaymentManager.h
//  TapMailer
//
//  Created by Yoshio Nose on 2013/06/24.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "SVProgressHUD.h"

// In App Purchase用通知名
#define PAYMENT_COMPLETED_NOTIFICATION @"PaymentCompletedNotification"
#define PAYMENT_ERROR_NOTIFICATION @"PaymentErrorNotification"

@protocol PaymentManagerDelegete <NSObject>
@required
-(void)finishRequest:(SKProductsRequest *)request productList:(NSArray *)products;
@end

@interface PaymentManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, assign) id<PaymentManagerDelegete> delegate;

+(PaymentManager*)sharedManager;
-(void)startTransactionObserve;
-(SKProductsRequest *)startProductRequest:(NSSet *)productIds;
-(BOOL)buyProduct:(SKProduct *)product;
-(void)startRestore;

@end
