//
//  CommentTableCell.m
//  ATDemo
//
//  Created by lisong on 2018/5/26.
//  Copyright © 2018年 lisong. All rights reserved.
//

#import "CommentTableCell.h"
#import "MLLinkLabel.h"

@interface CommentTableCell ()

@property (weak, nonatomic) IBOutlet MLLinkLabel *titleLabel;

@end

@implementation CommentTableCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.dataDetectorTypes = MLDataDetectorTypeNone;
    self.titleLabel.lineSpacing = 2;
    self.titleLabel.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor redColor]};
    self.titleLabel.didClickLinkBlock = ^(MLLink *link, NSString *linkText, MLLinkLabel *label)
    {
        NSLog(@"点击了%@",linkText);
    };
}

- (void)setComment:(NSString *)comment
{
    _comment = comment;
    
    self.titleLabel.text = comment;
    
    // 高亮@
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kATRegular options:NSRegularExpressionCaseInsensitive error:nil];
    [regex enumerateMatchesInString:comment options:NSMatchingReportProgress range:NSMakeRange(0, comment.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop)
    {
        [self.titleLabel addLinkWithType:MLLinkTypeUserHandle value:comment range:result.range];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
