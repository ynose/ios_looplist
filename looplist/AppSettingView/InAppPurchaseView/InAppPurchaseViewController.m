//
//  InAppPurchaseViewController.m
//  TapMailer
//
//  Created by Yoshio Nose on 12/03/16.
//  Copyright (c) 2012 ynose Apps. All rights reserved.
//

#import "InAppPurchaseViewController.h"

#import "ProductManager.h"
#import "UIProductCell.h"

static NSString *kCellIdentifier = @"Cell";

@interface InAppPurchaseViewController ()
@property (nonatomic, strong) NSArray *productArray;
@property (nonatomic, strong) NSArray *inAppPurchaseItems;
@end

@implementation InAppPurchaseViewController

-(id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Pro版の追加機能リストを読み込む
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"InAppPurchase" ofType:@"plist"];
        NSMutableArray *items = [NSMutableArray arrayWithContentsOfFile:path];

        // フィルタをかけて販売中のもののみにする
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forsale = %d", YES];
        [items filterUsingPredicate:predicate];

        self.inAppPurchaseItems = items;
    }

    return self;
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    // Pro版の追加機能リストを読み込む
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"InAppPurchase" ofType:@"plist"];
    NSMutableArray *items = [NSMutableArray arrayWithContentsOfFile:path];

    // フィルタをかけて販売中のもののみにする
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forsale = %d", YES];
    [items filterUsingPredicate:predicate];

    self.inAppPurchaseItems = items;


    // 購入処理の通知受信設定
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(paymentCompletedNotification:)
                               name:PAYMENT_COMPLETED_NOTIFICATION object:nil];
    [notificationCenter addObserver:self selector:@selector(paymentErrorNotification)
                               name:PAYMENT_ERROR_NOTIFICATION object:nil];


    // プロダクト情報の取得
    [[PaymentManager sharedManager] setDelegate:self];
    NSSet *productIds = [ProductManager productIds];
    [[PaymentManager sharedManager] startProductRequest:productIds];

    // 再利用セルのクラスを登録(dequeueReusableCellWithIdentifierで使う)
    [self.tableView registerClass:[UIProductCell class] forCellReuseIdentifier:kCellIdentifier];
}

-(void)finishRequest:(SKProductsRequest *)request productList:(NSArray *)products
{
    // 購入エラーが起きたらエラーメッセージを表示して設定画面に戻る
    if (products == nil) {
        return;
    }

    // プロダクト情報が取得できたら機能の一覧を表示する
    self.productArray = products;

    // 購入画面を更新して購入済みを反映する
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - 購入処理通知
// 正常終了
-(void)paymentCompletedNotification:(NSNotification *)notification
{
    SKPaymentTransaction *paymentTransaction = (SKPaymentTransaction *)notification.object;
    DEBUGLOG(@"%@", paymentTransaction.payment.productIdentifier);

    // 購入処理
    [[ProductManager sharedManager] bought:paymentTransaction.payment.productIdentifier];

    // 購入画面を更新して購入済みを反映する
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

    // デリゲートに通知
    if ([self.delegate respondsToSelector:@selector(inAppPurchaseDone:)]) {
        [self.delegate inAppPurchaseDone:self];
    }
}

// 異常終了
-(void)paymentErrorNotification
{
    // 購入をキャンセルした場合
}

// セルの高さ調整はうまくいかないので保留
//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    
//    _viewDidAppear = YES;
//    [self.tableView beginUpdates];
//    [self.tableView endUpdates];
//}

-(void)viewDidDisappear:(BOOL)animated
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    // 購入処理の通知受信設定を削除
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:PAYMENT_COMPLETED_NOTIFICATION object:nil];
    [notificationCenter removeObserver:self name:PAYMENT_ERROR_NOTIFICATION object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // 購入ボタンセクション + 機能情報セクション
    return 1 + [self.inAppPurchaseItems count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:         // 購入ボタンセクション
            return 2;   // 購入ボタン + 復元ボタン
            break;
        default:        // 機能情報セクション(1機能/セクション)
            return 1;   // 機能情報
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:             // 購入ボタンセクション
            if (indexPath.row == 0) {
                return 66;  // 購入ボタン
            } else {
                return 44;  // 復元ボタン
            }
            break;
            
        default:            // 機能情報セクション
            return 88;
            // セルの高さ調整はうまくいかないので保留
//        {
//            if (_viewDidAppear) {
//                UIProductCell *cell = (UIProductCell *)[tableView cellForRowAtIndexPath:indexPath];
//                return MAX(88, (cell.descriptionLabel.frame.origin.y + cell.descriptionLabel.frame.size.height));
//            } else {
//                return 88;
//            }
//        }
        }
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    // 購入すると使用できる機能の説明
    if (section == 0) {
        return LSTR(@"Setting-InAppPurchase-ProFunctions");
    } else {
        return nil;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIProductCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];

    switch (indexPath.section) {
        case 0:     // 購入ボタンセクション
        {
            switch (indexPath.row) {
                case 0:
                {
                    // 購入ボタン
                    // プロダクト情報を表示
                    SKProduct *product = [self.productArray objectAtIndex:0];
                    cell.productLabel.text = product.localizedTitle;
                    cell.priceLabel.text = nil;
                    cell.descriptionLabel.text = product.localizedDescription;

                    if ([ProductManager isAppPro]) {
                        // 購入済み
                        UILabel *purchasedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
                        purchasedLabel.text = LSTR(@"Setting-InAppPurchase-Purchased");
                        purchasedLabel.font = [UIFont systemFontOfSize:14.0f];
                        purchasedLabel.backgroundColor = [UIColor clearColor];
                        [purchasedLabel sizeToFit];
                        cell.accessoryView = purchasedLabel;

                    } else {
                        // 未購入

                        // 価格を表示
                        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                        [numberFormatter setLocale:product.priceLocale];
                        NSString *priceString = [numberFormatter stringFromNumber:product.price];

                        cell.priceLabel.text = priceString;

                        // 購入ボタンを表示
                        UIButton *paymentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                        [paymentButton setTitle:LSTR(@"InAppPurchase-Purchase") forState:UIControlStateNormal];
                        [paymentButton sizeToFit];
                        [paymentButton addTarget:self action:@selector(paymentButtonTapped:event:)
                                forControlEvents:UIControlEventTouchUpInside];
                        cell.accessoryView = paymentButton;
                    }
                    break;
                }
                default:
                {
                    // 復元ボタン
                    cell.productLabel.text = LSTR(@"InAppPurchase-RestoreCaption");
                    cell.priceLabel.text = nil;
                    cell.descriptionLabel.text = nil;
                    // 復元ボタンを表示
                    UIButton *restoreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [restoreButton setTitle:LSTR(@"InAppPurchase-Restore") forState:UIControlStateNormal];
                    [restoreButton sizeToFit];
                    [restoreButton addTarget:self action:@selector(restoreButtonTapped:event:)
                            forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = restoreButton;

                    break;
                }
            }
            break;
        }
        default:    // 機能情報セクション
        {
            NSDictionary *item = [self.inAppPurchaseItems objectAtIndex:indexPath.section - 1];
            DEBUGLOG(@"%@", [item objectForKey:@"feature"]);
            cell.productLabel.text = [item objectForKey:@"feature"];
            cell.descriptionLabel.text = [item objectForKey:@"description"];
            cell.accessoryView = nil;
            break;
        }
    }

    return cell;
}


#pragma mark - ボタン
// 購入ボタン
-(void)paymentButtonTapped:(id)sender event:(id)event
{
    // 購入処理を開始する
    SKProduct *product = [self.productArray objectAtIndex:0];
    [[PaymentManager sharedManager] buyProduct:product];
}

// 復元ボタン
-(void)restoreButtonTapped:(id)sender event:(id)event
{
    // 復元処理を開始する
    [[PaymentManager sharedManager] startRestore];
}

@end
