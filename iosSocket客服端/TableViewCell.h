//
//  TableViewCell.h
//  iosSocket客服端
//
//  Created by SHICHUAN on 2017/5/22.
//  Copyright © 2017年 SHICHUAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
+(TableViewCell *)TableView:(UITableView *)table;
@property(nonatomic,strong)NSDictionary *contentDict;
@end
