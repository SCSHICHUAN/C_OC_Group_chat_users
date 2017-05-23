//
//  TableViewCell.m
//  iosSocket客服端
//
//  Created by SHICHUAN on 2017/5/22.
//  Copyright © 2017年 SHICHUAN. All rights reserved.
//

#import "TableViewCell.h"

@interface TableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UITextView *coutent;
@property (weak, nonatomic) IBOutlet UILabel *senttime;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *couentHight;

@end


@implementation TableViewCell

+(TableViewCell *)TableView:(UITableView *)table
{
    static NSString *identfer = @"identfer";
    TableViewCell *cell = [table dequeueReusableCellWithIdentifier:identfer];
    
    cell = [[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:nil options:nil].firstObject;
    
    return cell;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setContentDict:(NSDictionary *)contentDict
{
    _contentDict = contentDict;
    
    
       
        self.userName.text = contentDict[@"userName"];
        self.coutent.text = contentDict[@"content"];
        self.senttime.text = contentDict[@"time"];
        self.couentHight.constant = [contentDict[@"couentHight"] floatValue]+10;
        NSLog(@"self.couentHight.constant= [ %f ]",self.couentHight.constant);
        NSLog(@"dict[content]= [ %@ ]",contentDict[@"content"]);
    
    
    
    
    
    
}

@end
