//
//  ViewController.m
//  iosSocket客服端
//
//  Created by SHICHUAN on 2017/5/19.
//  Copyright © 2017年 SHICHUAN. All rights reserved.
//

#import "ViewController.h"

#include <stdlib.h>
#include <sys/types.h>
#include <stdio.h>
#include <sys/socket.h>
#include <string.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <pthread.h>
#include <netdb.h> //把域名专换为IP地址

#import "TableViewCell.h"

typedef struct MySocketInfo{
    int socketCon;
    unsigned long ipaddr;
    unsigned short port;
}_MySocketInfo;

void *fun_thrReceiveHandler(void *socketCon);
int checkThrIsKill(pthread_t thr);

#define kTextFont [UIFont systemFontOfSize:13]//正文的字体







#import "ViewController.h"

@interface ViewController()<UITableViewDataSource,UITableViewDelegate>
{
    int socketCon;
    NSString *_user;
    NSString *_contentNS;
    NSTimer *_timer;
}






@property (weak, nonatomic) IBOutlet UITextField *userNameee;
@property (weak, nonatomic) IBOutlet UITextField *computerIP;
- (IBAction)removeStarView:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *setarView;



@property (weak) IBOutlet UITextView *textFild;

@property (weak) IBOutlet UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *mArray;


- (IBAction)sendButton:(UIButton *)sender;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)NSMutableArray *cellHightArray;
@end





@implementation ViewController

-(NSMutableArray *)mArray
{
    if (_mArray == nil) {
        _mArray = [NSMutableArray array];
    }
    return _mArray;
}
-(NSTimer *)timer
{
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                  target:self
                                                selector:@selector(alarmTimerStar)
                                                userInfo:nil
                                                 repeats:YES];
        //滚动时不会暂停时钟
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}
-(NSMutableArray *)cellHightArray
{
    if (_cellHightArray == nil) {
        _cellHightArray = [NSMutableArray array];
    }
    return _cellHightArray;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
   
    
    
    _contentNS = @"你好" ;
    
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    self.computerIP.text = [userDefault objectForKey:@"computerID"];
    self.userNameee.text = [userDefault objectForKey:@"userName"];
   
    
    
    
    
    
}
int m = 0;
-(void)alarmTimerStar
{
    m +=1;
    
    if (m > 3) {
        

        
        //计算出C字符串的长度
        long len = strlen(content);
        for (int i = 0; i<len; i++) {
            if (content[i] == '}') {//找出括号前的长度
               content[i+1] = '\0';//取出括号后多余字符
            }
        }
        
        
        NSString *dataString = [NSString stringWithCString:content encoding:NSUTF8StringEncoding];
        NSData *sever = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *contentDict=[NSJSONSerialization
                                  JSONObjectWithData:sever
                                  options:NSJSONReadingMutableLeaves
                                  error:nil];
        
        NSString *_contentC = contentDict[@"content"];
        if(contentDict == nil){
            return;
        }
        
        
        
       if (![_contentNS isEqualToString:_contentC]) {
//            
            _contentNS = _contentC;
            NSLog(@"[self.tableView reloadData] = [ %@ ]",_contentNS);
            
            NSLog(@"_contentC = [ %@ ]",_contentC);
            
           
           
           NSDictionary *textDict = @{NSFontAttributeName:kTextFont};
           CGRect textFrame = [_contentC boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-20, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:textDict context:nil];
           NSLog(@"textFrame = [ %@ ]",NSStringFromCGRect(textFrame));
           NSString *strHeight = [NSString stringWithFormat:@"%f",textFrame.size.height];
           
           NSDictionary *dict =@{@"userName":contentDict[ @"userName"],
                                 @"content": contentDict[ @"content"],
                                 @"time": [self getNowTime],
                                 @"couentHight":strHeight
                                 };
           
           
           
           
          [self.cellHightArray addObject:strHeight];
          [self.mArray addObject:dict];
          [self.tableView reloadData];
        
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.mArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
           
        }
        
    }
    
    
}







-(void)yyy
{
   
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *switchStatu = [userDefault objectForKey:@"computerID"];
    int IP = [switchStatu intValue];
    
    NSLog(@"IP= [ %d ]",IP);
    
    
    printf("开始socket\n");
    /* 创建TCP连接的Socket套接字 */
    socketCon = socket(AF_INET, SOCK_STREAM, 0);
    
    if(socketCon < 0){
        printf("创建TCP连接套接字失败\n");
        exit(-1);
    }
    

    struct hostent* host;
    host = gethostbyname("0.tcp.ngrok.io");
    const char *hostip = inet_ntoa(*((struct in_addr*)host->h_addr));//把域名专换为IP地址，
    
    
    
    
    /* 填充客户端端口地址信息，以便下面使用此地址和端口监听 */
    struct sockaddr_in server_addr;
    bzero(&server_addr,sizeof(struct sockaddr_in));
    server_addr.sin_family=AF_INET;
    server_addr.sin_addr.s_addr=inet_addr(hostip); /* 这里地址使用全0，即所有 */
    server_addr.sin_port=htons(IP);
    /* 连接服务器 */
    int res_con = connect(socketCon,(struct sockaddr *)(&server_addr),sizeof(struct sockaddr));
    if(res_con != 0){
        printf("连接失败\n");
        exit(-1);
    }
    printf("连接成功,连接结果为：%d\n",res_con);
    //开启新的实时接受数据线程
    pthread_t thrReceive;
    pthread_create(&thrReceive,NULL,fun_thrReceiveHandler,&socketCon);
    
    /* 实时发送数据 */
    //    while(1){
    //检测接受服务器数据线程是否被杀死
    //        sleep(2.0);
    
    char userStr[] = "客服端";
    // 可以录入用户操作选项，并进行相应操作
    //        scanf("%s",userStr);
    //        if(strcmp(userStr,"q") == 0){
    //            printf("用户选择退出！\n");
    //            break;
    //        }
    // 发送消息
    //        int sendMsg_len = send(socketCon, userStr, 30, 0);
    long sendMsg_len = write(socketCon,userStr,sizeof(userStr));
    if(sendMsg_len > 0){
        printf("发送成功,服务端套接字句柄:%d\n",socketCon);
    }else{
        printf("发送失败\n");
    }
    
    //if(checkThrIsKill(thrReceive) == 1){
    //printf("接受服务器数据的线程已被关闭，退出程序\n");
    //break;
    //}
    //    }
    // 关闭套接字
    //    close(socketCon);
    
}

char *content;


void *fun_thrReceiveHandler(void *socketCon){
    while(1){
       
        char buffer[1000];

        
        int _socketCon = *((int *)socketCon);
        //int buffer_length = recv(_socketCon,buffer,30,0);
        long buffer_length = read(_socketCon,buffer,1000);
        if(buffer_length == 0){
            printf("服务器端异常关闭\n");
            exit(-1);
        }else if(buffer_length < 0){
            printf("接受客户端数据失败\n");
            break;
        }
        
        content = buffer;
        printf("buffer[0] = %c\n",buffer[0]);
        
       
        
        
        
        
        
        buffer[buffer_length] = '\0';
        printf("服务器说：%s\n",buffer);
        
        
        
        
    }
    printf("退出接受服务器数据线程\n");
    return NULL;
}

int checkThrIsKill(pthread_t thr){
    int res = 1;
    int res_kill = pthread_kill(thr,0);
    if(res_kill == 0){
        res = 0;
    }
    
    
    
    
    
    return res;
}



- (IBAction)sendButton:(UIButton *)sender {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *switchStatu = [userDefault objectForKey:@"userName"];
   
    NSDictionary *dict =@{@"userName":[NSString stringWithFormat:@"%@:",switchStatu],
                          @"content": self.textFild.text,
                          @"time": [self getNowTime]};
    
    NSData *sentData= [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    
//    NSString *sentText = [NSString stringWithFormat:@"1%@",self.textFild.text];
    
    
//    const char *s = [sentText UTF8String];
//    char userStr[1000];
//    strncpy(userStr, s, 1000);
    
    // 可以录入用户操作选项，并进行相应操作
    //        scanf("%s",userStr);
    //        if(strcmp(userStr,"q") == 0){
    //            printf("用户选择退出！\n");
    //            break;
    //        }
    // 发送消息
    //        int sendMsg_len = send(socketCon, userStr, 30, 0);
    
    long sendMsg_len = write(socketCon,[sentData bytes],1000);
    if(sendMsg_len > 0){
        printf("发送成功,服务端套接字句柄:%d\n",socketCon);
    }else{
        printf("发送失败\n");
    }
    
    
    self.textFild.text= @"";
    _user = @"我自己";
//    [self.timer fire];
    
    [self.timer setFireDate:[NSDate date]];
    
}

// 设置行数

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell = [TableViewCell TableView:self.tableView];
    cell.contentDict = self.mArray[indexPath.row];
//    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellHStr = self.cellHightArray[indexPath.row];
    NSLog(@"cellHStr= [ %@ ]",cellHStr);
    return [cellHStr floatValue]+30+10+10;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"你点击了第行 = %ld",(long)indexPath.row);
}




-(NSString *)getNowTime
{
    
    NSDate  *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss  MM.dd.yyyy";
    NSString *dateStr = [formatter stringFromDate:date];
    return  dateStr;
    
}



- (IBAction)removeStarView:(UIButton *)sender {
    
    if (!(self.userNameee.text.length>1)) {
        [self topPromptViewWithPromptContent:@"请输入两位以上的名字...."];
        return;
    }
    
    if (!(self.computerIP.text.length>3)) {
        [self topPromptViewWithPromptContent:@"请输入4位以上的链接地址...."];
        return;
    }
    
    
    //获取userDefault单例
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.userNameee.text forKey:@"userName"];
    [userDefaults setObject:self.computerIP.text forKey:@"computerID"];
    //同步到list文件中
    [userDefaults synchronize];

    
    
    
    [self yyy];
    [self.setarView removeFromSuperview];
    
    
    
}

#define KScreenHeight ([UIScreen mainScreen].bounds.size.height)

-(void)topPromptViewWithPromptContent:(NSString *)str
{
    
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    UIView *dataView = [[UIView alloc]initWithFrame:CGRectMake(0,- 60, KScreenHeight, 60)];
    dataView.backgroundColor = [UIColor whiteColor];
    dataView.layer.shadowColor = [UIColor blackColor].CGColor;
    dataView.layer.shadowOpacity = 0.2;
    dataView.layer.shadowOffset = CGSizeMake(5, 5);
    UILabel *dataLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0, KScreenHeight, 60)];
    dataLabel.text = str;
    dataLabel.font = [UIFont boldSystemFontOfSize:14];
    [dataView addSubview:dataLabel];
    [[UIApplication sharedApplication].keyWindow addSubview:dataView];
    
    
    [UIView animateWithDuration:0.25 animations:^{
        dataView.frame = CGRectMake(0,10, KScreenHeight, 60);
        dataLabel.frame = CGRectMake(10,0, KScreenHeight, 60);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            dataView.frame = CGRectMake(0,-5, KScreenHeight, 60);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                dataView.frame = CGRectMake(0,0, KScreenHeight, 60);
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:3.0 animations:^{
                    
                    dataView.alpha = 1.1;
                    
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.15 animations:^{
                        
                        dataView.frame = CGRectMake(0,-60, KScreenHeight, 60);
                        dataLabel.frame = CGRectMake(10,0, KScreenHeight, 60);
                        
                    } completion:^(BOOL finished) {
                        [dataView removeFromSuperview];
                        [dataLabel removeFromSuperview];
                        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                        
                        
                        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
                        
                    }];
                }];
            }];
            
            
        }];
    }];
    
}



@end







