//
//  PaymentManager.m
//  TapMailer
//
//  Created by Yoshio Nose on 2013/06/24.
//
//

#import "PaymentManager.h"

@implementation PaymentManager

static PaymentManager *_sharedInstance = nil;

#define REMAIN_TRANSACTION @"RemainTracsaction"


#pragma mark - シングルトン定義
+(PaymentManager*)sharedManager
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [self new];
        }
    }
    return _sharedInstance;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [super allocWithZone:zone];
            return _sharedInstance;
        }
    }
    return nil;
}

-(id)copyWithZone:(NSZone*)zone {
	return self;        // シングルトン状態を保持するため何もせず self を返す
}

#pragma mark - 製品情報取得
-(SKProductsRequest *)startProductRequest:(NSSet *)productIds
{
    // プログレス表示（処理中)
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIds];
    productRequest.delegate = self;
    [productRequest start];

    return productRequest;
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    for (NSString *invalidProductIndentifier in response.invalidProductIdentifiers) {
        NSLog(@"%s invalidProductIndentifiers : %@", __PRETTY_FUNCTION__, invalidProductIndentifier);
    }

    if ([_delegate respondsToSelector:@selector(finishRequest:productList:)]) {
        [_delegate finishRequest:request productList:response.products];
    }

    // プログレス表示
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if ([response.invalidProductIdentifiers count] > 0) {
        [SVProgressHUD showErrorWithStatus:LSTR(@"InAppPurchase-ProductError")];
    } else {
        [SVProgressHUD dismiss];
    }
}

#pragma mark - PaymentManager
-(void)startTransactionObserve
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

#pragma mark 購入/リストア処理
-(BOOL)buyProduct:(SKProduct *)product
{
    if ([SKPaymentQueue canMakePayments] == NO) {
        return NO;
    }

    // プログレス表示（処理中)
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];

    // 購入処理を開始する
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];

    return YES;
}

-(void)startRestore
{
    // プログレス表示（処理中)
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];

    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


#pragma mark - SKPaymentTransactionObserver
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing:
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

                // トランザクションが開始されたことを記録しておく
                @synchronized(self) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:REMAIN_TRANSACTION];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                break;

            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;

            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;

            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;

            default:
                break;
        }
    }
}

-(void)completeTransaction:(SKPaymentTransaction *)transaction
{
    // 通知を発行
    [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_COMPLETED_NOTIFICATION object:transaction];

    // プログレス表示（正常終了)
    [SVProgressHUD showSuccessWithStatus:nil];

    // ペイメントキューからトランザクションを削除する
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    // 通知を発行
    [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_COMPLETED_NOTIFICATION object:transaction];

    // プログレス表示（正常終了)
    [SVProgressHUD showSuccessWithStatus:nil];

    // ペイメントキューからトランザクションを削除する
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    switch (error.code) {
        case SKErrorPaymentCancelled:
            // 復元をキャンセル
            [SVProgressHUD dismiss];
            break;
        case SKErrorUnknown:
        case SKErrorClientInvalid:
        case SKErrorPaymentInvalid:
        case SKErrorPaymentNotAllowed:
        default:
            // プログレス表示（異常終了)
            [SVProgressHUD showErrorWithStatus:@"Error"];
            break;
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)failedTransaction:(SKPaymentTransaction *)transaction
{
    switch (transaction.error.code) {
        case SKErrorPaymentCancelled:
            // 購入をキャンセル
            [SVProgressHUD dismiss];
            break;
        case SKErrorUnknown:
        case SKErrorClientInvalid:
        case SKErrorPaymentInvalid:
        case SKErrorPaymentNotAllowed:
        default:
            // プログレス表示（異常終了)
            [SVProgressHUD showErrorWithStatus:@"Error"];
            break;
    }

    // 通知を発行
    [[NSNotificationCenter defaultCenter] postNotificationName:PAYMENT_ERROR_NOTIFICATION object:transaction];

    // ペイメントキューからトランザクションを削除する
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    // トランザクションが終了したことを記録しておく
    @synchronized(self) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:REMAIN_TRANSACTION];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    // プログレス非表示
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
