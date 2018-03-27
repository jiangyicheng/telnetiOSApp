//
//  QRCScannerViewController.m
//  QRScannerDemo
//  blog:www.zhangfei.tk
//  Created by zhangfei on 15/10/15.
//  Copyright © 2015年 zhangfei. All rights reserved.
//

#import "QRCScannerViewController.h"
#import "QRCScanner.h"
#import "SSIDTool.h"
#import "TelnetTableViewController.h"
#import <Masonry.h>
#import "AppDelegate.h"

@interface QRCScannerViewController ()<QRCodeScanneDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
/**  scanner */
@property(nonatomic,weak)QRCScanner* scanner;
@end

@implementation QRCScannerViewController

-(void)dealloc
{
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    QRCScanner *scanner = [[QRCScanner alloc]initQRCScannerWithView:self.view];
    scanner.delegate = self;
    _scanner = scanner;
    [self.view addSubview:_scanner];
    self.title = @"扫描";
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = 2;
    //从相册选取二维码
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(readerImage)];
    [[UIDevice currentDevice]setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait]forKey:@"orientation"];
    [[self class]attemptRotationToDeviceOrientation];
    
}

//支持旋转
 -(BOOL)shouldAutorotate{
         return YES;
 }

//支持的方向 因为界面A我们只需要支持竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
     return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - 扫描二维码成功后结果的代理方法
- (void)didFinshedScanningQRCode:(NSString *)result{
    
//    if ([self.delegate respondsToSelector:@selector(didFinshedScanning:)]) {
//        [self.delegate didFinshedScanning:result];
//    }
//    else{
//        NSLog(@"没有收到扫描结果，看看是不是没有实现协议！");
//    }
    [self hadelResult:result];
}

-(void)hadelResult:(NSString*)result
{
    NSString* ssidStr = [SSIDTool createSSIDStrWithMacStr:result];
    NSString* pwd = [SSIDTool creatPassWordStrWithMacStr:result];
    NSLog(@"wifi=%@,pwd=%@",ssidStr,pwd);
    UIStoryboard* storyborard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TelnetTableViewController* tvc = [storyborard instantiateViewControllerWithIdentifier:NSStringFromClass([TelnetTableViewController class])];
    tvc.wifiName = ssidStr;
    tvc.password = pwd;
    tvc.type = 2;
    NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
    [viewControllers removeLastObject];
    [viewControllers addObject:tvc];
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

#pragma mark - 从相册获取二维码图片

- (void)readerImage{
    
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    photoPicker.view.backgroundColor = [UIColor whiteColor];
    [self presentViewController:photoPicker animated:YES completion:NULL];
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
//    UIImage *srcImage = [info objectForKey:UIImagePickerControllerOriginalImage];
//    NSString *result = [QRCScanner scQRReaderForImage:srcImage];
//    
//    [self hadelResult:result];
//    if ([self.delegate respondsToSelector:@selector(didFinshedScanning:)]) {
//        [self.delegate didFinshedScanning:result];
//    }
//    else{
//        NSLog(@"没有收到扫描结果，看看是不是没有实现协议！");
//    }
//    [self.navigationController popViewControllerAnimated:YES];
}
@end
