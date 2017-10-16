//
//  popViewController.m
//  telnetIosApp
//
//  Created by 姜易成 on 2017/8/24.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import "popViewController.h"

@interface popViewController ()<UITableViewDelegate,UITableViewDataSource>

/**  tableview */
@property(nonatomic,strong)UITableView* mainTableview;

@end

@implementation popViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpTableview];
    // Do any additional setup after loading the view.
}

-(void)setUpTableview
{
    self.mainTableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width)];
    self.mainTableview.dataSource = self;
    self.mainTableview.delegate = self;
    self.mainTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
//    NSIndexPath *ip=[NSIndexPath indexPathForRow:0 inSection:0];
//    [self.mainTableview selectRowAtIndexPath:ip animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self.view addSubview:self.mainTableview];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArr.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.titleArr[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"connectStyleChanged" object:nil userInfo:@{@"style":_titleArr[indexPath.row],@"type":@(self.type)}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
