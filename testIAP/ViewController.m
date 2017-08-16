//
//  ViewController.m
//  testIAP
//
//  Created by rongchen on 2017/8/16.
//  Copyright © 2017年 Yoncn. All rights reserved.
//

#import "ViewController.h"
#import <StoreKit/StoreKit.h>

#define ProductID @"justalk_plus_6_month_20170321"

@interface ViewController ()<SKPaymentTransactionObserver,SKProductsRequestDelegate>
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 添加购买监听
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    
}

//请求商品信息
- (void)requestProductData:(NSString *)type {
    NSLog(@"开始请求商品信息");
    self.statusLabel.text = @"正在请求商品信息";
    
    //将商品信息存入SET
    NSArray *product = @[ProductID];
    NSSet *productSet = [NSSet setWithArray:product];
    
    //请求
    SKProductsRequest *request = [[SKProductsRequest alloc]initWithProductIdentifiers:productSet];
    request.delegate = self;
    [request start];
}


//收到返回的商品信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"收到了请求反馈");
    
    NSArray *product = response.products;
    if (product.count == 0) {
        NSLog(@"没有商品");
        return;
    }
    
    NSLog(@"无效的ProductID:%@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量：%lu",(unsigned long)product.count);
    
    //从返回的array中找到刚才购买的那个商品
    SKProduct *p = nil;
    for (SKProduct *pro in product) {
        NSLog(@"商品：%@\n商品名称：%@\n商品描述：%@\n商品价格：%@\n商品ID：%@",pro.description,pro.localizedTitle,pro.localizedDescription,pro.price,pro.productIdentifier);
        if ([pro.productIdentifier isEqualToString:ProductID]) {
            p = pro;
            break;
        }
    }
    
    //发送购买请求
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    NSLog(@"发送购买请求");
    self.statusLabel.text = @"正在发送购买请求";
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//请求成功
- (void)requestDidFinish:(SKRequest *)request {
    NSLog(@"请求结束");
}

//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"请求商品信息错误：%@",error);
    self.statusLabel.text = [NSString stringWithFormat:@"%@",error];
}

//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"交易完成");
                [self completeTransaction:transaction];
                self.statusLabel.text = @"交易完成";
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品正在请求");
                self.statusLabel.text = @"正在请求付费信息";
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"商品已经购买过了");
                self.statusLabel.text = @"商品已经购买过了";
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"购买失败");
                self.statusLabel.text = @"交易失败";
                break;
            case SKPaymentTransactionStateDeferred:
                NSLog(@"待定");
                
            default:
                NSLog(@"待定");
                break;
        }
    }
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"交易结束");
    self.statusLabel.text = @"交易结束";
    NSString *productIdentifier = [[NSString alloc]initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
    NSString *receipt = [[productIdentifier dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    if (productIdentifier.length > 0) {
        //向服务器验证
        NSLog(@"%@\n%@",productIdentifier,receipt);
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}





- (IBAction)buyAction:(id)sender {
    //检测是否允许内购
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"可以内购");
        [self requestProductData:ProductID];
        
    } else {
        NSLog(@"不允许内购");
    }
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
