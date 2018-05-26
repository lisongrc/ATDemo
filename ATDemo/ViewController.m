//
//  ViewController.m
//  ATDemo
//
//  Created by lisong on 2018/5/25.
//  Copyright © 2018年 lisong. All rights reserved.
//

#import "ViewController.h"
#import "HPGrowingTextView.h"
#import "SelectUserController.h"
#import "CommentTableCell.h"

static NSString * const identifier = @"cell";

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, HPGrowingTextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet HPGrowingTextView *growingTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentViewBottom;

@property (strong, nonatomic) NSMutableArray<NSString *> *comments;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.growingTextView.delegate = self;
    self.growingTextView.font = [UIFont systemFontOfSize:13];
    self.growingTextView.minNumberOfLines = 1;
    self.growingTextView.maxNumberOfLines = 10;
    self.growingTextView.placeholder = @"输入评论";
    self.growingTextView.returnKeyType = UIReturnKeySend;
    self.growingTextView.enablesReturnKeyAutomatically = YES;
    self.growingTextView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
    
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([CommentTableCell class]) bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:identifier];
    self.tableView.estimatedRowHeight = 50;
    self.tableView.tableFooterView = [UIView new];
    
    // 先添加一条数据
    NSString *aCommment = @"假数据，一个@和空格之间视为一个艾特，例如@小松哥 ，末尾没有空格的不视为艾特，例@小松哥";
    self.comments = [@[aCommment] mutableCopy];
}


#pragma mark - UIKeyboardNotification

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect endRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.commentViewBottom.constant = endRect.size.height;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.commentViewBottom.constant = 0;
        [self.view layoutIfNeeded];
    } completion:nil];
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.comments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.comment = self.comments[indexPath.row];
    return cell;
}


#pragma mark - UITextViewDelegate

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    self.commentViewHeight.constant = height + 14;
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    [self.growingTextView resignFirstResponder];
    return YES;
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@""])
    {
        NSRange selectRange = growingTextView.selectedRange;
        if (selectRange.length > 0)
        {
            //用户长按选择文本时不处理
            return YES;
        }
        
        // 判断删除的是一个@中间的字符就整体删除
        NSMutableString *string = [NSMutableString stringWithString:growingTextView.text];
        NSArray *matches = [self findAllAt];
        
        BOOL inAt = NO;
        NSInteger index = range.location;
        for (NSTextCheckingResult *match in matches)
        {
            NSRange newRange = NSMakeRange(match.range.location + 1, match.range.length - 1);
            if (NSLocationInRange(range.location, newRange))
            {
                inAt = YES;
                index = match.range.location;
                [string replaceCharactersInRange:match.range withString:@""];
                break;
            }
        }
        
        if (inAt)
        {
            growingTextView.text = string;
            growingTextView.selectedRange = NSMakeRange(index, 0);
            return NO;
        }
    }
    
    //判断是回车键就发送出去
    if ([text isEqualToString:@"\n"])
    {
        [self.comments addObject:growingTextView.text];
        self.growingTextView.text = @"";
        [self.growingTextView resignFirstResponder];
        [self.tableView reloadData];
        return NO;
    }
    
    return YES;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    UITextRange *selectedRange = growingTextView.internalTextView.markedTextRange;
    NSString *newText = [growingTextView.internalTextView textInRange:selectedRange];

    if (newText.length < 1)
    {
        // 高亮输入框中的@
        UITextView *textView = self.growingTextView.internalTextView;
        NSRange range = textView.selectedRange;
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:textView.text];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, string.string.length)];
        
        NSArray *matches = [self findAllAt];
        
        for (NSTextCheckingResult *match in matches)
        {
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(match.range.location, match.range.length - 1)];
        }
        
        textView.attributedText = string;
        textView.selectedRange = range;
    }
}

- (void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView
{
    // 光标不能点落在@词中间
    NSRange range = growingTextView.selectedRange;
    if (range.length > 0)
    {
        // 选择文本时可以
        return;
    }
    
    NSArray *matches = [self findAllAt];
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange newRange = NSMakeRange(match.range.location + 1, match.range.length - 1);
        if (NSLocationInRange(range.location, newRange))
        {
            growingTextView.internalTextView.selectedRange = NSMakeRange(match.range.location + match.range.length, 0);
            break;
        }
    }
}


#pragma mark - Private

- (NSArray<NSTextCheckingResult *> *)findAllAt
{
    // 找到文本中所有的@
    NSString *string = self.growingTextView.text;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kATRegular options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, [string length])];
    return matches;
}


#pragma mark - Push

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // 去选择@的人
    [self.growingTextView.internalTextView unmarkText];
    NSInteger index = self.growingTextView.text.length;

    if (self.growingTextView.isFirstResponder)
    {
        index = self.growingTextView.selectedRange.location + self.growingTextView.selectedRange.length;
        [self.growingTextView resignFirstResponder];
    }

    SelectUserController *atVC = segue.destinationViewController;
    atVC.selectBlock = ^(NSString *name)
    {
        UITextView *textView = self.growingTextView.internalTextView;

        NSString *insertString = [NSString stringWithFormat:kATFormat,name];
        NSMutableString *string = [NSMutableString stringWithString:textView.text];
        [string insertString:insertString atIndex:index];
        self.growingTextView.text = string;

        [self.growingTextView becomeFirstResponder];
        textView.selectedRange = NSMakeRange(index + insertString.length, 0);
    };
}

@end
