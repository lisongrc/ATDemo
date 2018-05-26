//
//  SelectUserController.m
//  ATDemo
//
//  Created by lisong on 2018/5/25.
//  Copyright © 2018年 lisong. All rights reserved.
//

#import "SelectUserController.h"

@interface SelectUserController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SelectUserController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"用户%ld",(long)indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.selectBlock)
    {
        self.selectBlock([NSString stringWithFormat:@"用户%ld",(long)indexPath.row]);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
