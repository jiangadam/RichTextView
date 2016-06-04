//
//  ViewController.m
//  RichTextView
//
//  Created by     songguolin on 16/1/7.
//  Copyright © 2016年 innos-campus. All rights reserved.
//



//－－－－－－－－－－－demo下载地址:https://github.com/songguolin/RichTextView－－－－－－－－－
//－－－－－－－－－－－－－ TYAttributedLabel 给大家借鉴的，富文本显示－－－－－－－－－－－－－－
//－－－－－－－－－－－相关介绍博客http://doc.okbase.net/qianglong/archive/119421.html





#import "ViewController.h"
#import "RichTextViewController.h"
#import "TableViewController.h"
#import "TableViewController1.h"

@interface ViewController ()<RichTextViewControllerDelegate>
{
    NSString * jsonString;
    BOOL textNeedAttribute;  //文字是否需要属性
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


//富文本编辑里面的图片都是调整了显示大小的，毕竟不能让图片影响到编辑，但是图片没有压缩过，不用担心失真
//编辑富文本，这种方式图片全部重新上传，网络不佳的情况不建议
//生成 上传富文本,注意初次编辑 和以后的
- (IBAction)richtext:(id)sender {
    RichTextViewController * ctrl=[RichTextViewController ViewController];
    
    //控制 文字是否需要 颜色，大小等属性
    ctrl.changText=YES;

    //本页控制之后的操作，
    textNeedAttribute=ctrl.changText;
    
    if (textNeedAttribute) {
        //设置内容,因为有字体颜色 上传用的是数组
        [ctrl setContent:[NSArray arrayWithJSON:jsonString]];

    }
    else
    {
        //设置内容
        ctrl.content=jsonString;
    }

    __weak typeof(self) weakSelf=self;
   //    无需返回网页
    ctrl.finished=^(id content,NSArray * imageArr){
      
        [weakSelf uploadData:content withImageArray:imageArr];

//        if (arr.count>0) {
//            for (NSDictionary * dict in arr) {
//                NSLog(@"title---%@",[dict objectForKey:@"title"]);
//               //注意这里的lineSpace==0的时候，说明是富文本里面的自动换行，不是的话就是手动点击return的换行
//               
//            }
//        }
        
  
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:ctrl animated:YES];
}
#pragma mark uploadData 上传服务器
- (void)uploadData:(id )contentData withImageArray:(NSArray *)imageArr
{
    //这是选择完图片一次性上传，可能会慢,.另一种就是在用户选择图片的时候就上传，这种方法大家可以考虑
   //1.先上传图片
    
   //2.模拟上传
   /*
    arr--(
    {
    bold = 0;
    color = "#00ff00";
    font = 16;
    lineSpace = 5;
    title = "Rerr ";
    },
    {
    bold = 0;
    color = "#ff0000";
    font = 25;
    lineSpace = 5;
    title = "rrrrr ";
    },
    {
    bold = 0;
    font = 12;
    lineSpace = 5;
    title = "\n";
    },
    {
    bold = 0;
    font = 12;
    image = "<UIImage: 0x7f9c0e06c110> size {310, 206} orientation 0 scale 1.000000";
    lineSpace = 0;
    title = "[UIImageView]";
    },
    {
    bold = 0;
    color = "#ff0000";
    font = 25;
    lineSpace = 0;
    title = "\n";
    },
    {
    bold = 0;
    color = "#ff0000";
    font = 25;
    lineSpace = 5;
    title = "Ffff ";
    }
    )

      
    这个时候重新组装数据，吧image替换成url

    来代替的图片地址
    http://pic32.nipic.com/20130829/12906030_124355855000_2.png
    http://pic55.nipic.com/file/20141208/19462408_171130083000_2.jpg
    http://pic36.nipic.com/20131217/6704106_233034463381_2.jpg
    http://img05.tooopen.com/images/20140604/sy_62331342149.jpg
    http://img05.tooopen.com/images/20150531/tooopen_sy_127457023651.jpg
    http://pic44.nipic.com/20140721/11624852_001107119409_2.jpg

    */
    
    
    //比如这是服务器返回的数据
    NSArray * urlarr=@[@"<img src=\"http://pic32.nipic.com/20130829/12906030_124355855000_2.png\" w=\"240\" h=\"321\"/>",
                       @"<img src=\"http://pic55.nipic.com/file/20141208/19462408_171130083000_2.jpg\" w=\"240\" h=\"321\"/>",
                       @"<img src=\"http://pic36.nipic.com/20131217/6704106_233034463381_2.jpg\" w=\"240\" h=\"321\"/>",
                       @"<img src=\"http://img05.tooopen.com/images/20140604/sy_62331342149.jpg\" w=\"240\" h=\"321\"/>",
                       @"<img src=\"http://img05.tooopen.com/images/20150531/tooopen_sy_127457023651.jpg\" w=\"240\" h=\"321\"/>",
                       @"<img src=\" http://pic44.nipic.com/20140721/11624852_001107119409_2.jpg\" w=\"240\" h=\"321\"/>"
                      ];
   
    if (textNeedAttribute) {
        
        //1.如果是带有字体颜色，大小
        NSArray * dataArr=(NSArray *)contentData;
        dispatch_queue_t queue=dispatch_queue_create("com.innos", NULL);
        dispatch_sync(queue, ^{
            //组装数据
            for (int i=0; i<dataArr.count;i++ ) {
                NSDictionary * dict=dataArr[i];
                if (dict[@"image"]!=nil) {
                    //这个是为了图片加载的时候有个默认 宽高
                    
                    [dict setValue:urlarr[i%6] forKey:@"image"];
                    NSLog(@"图片顺序比对地址－－－%@",urlarr[i%6]);
                }
            }
            //上传服务器
            jsonString=[dataArr toJSON];
//            NSLog(@"jsonString--%@",jsonString);
            
        });
    }
    else
    {
        //2.如果只有普通字体，图片
        //这里是把字符串分割成数组，
        NSArray * strArr=[contentData  componentsSeparatedByString:RICHTEXT_IMAGE];
        
        NSString * newContent=@"";
        for (int i=0; i<strArr.count; i++) {
            
            NSString * imgTag=@"";
            if (i<strArr.count-1) {
                //这是用url 地址替换 图片标示 imgTag=urlarr[i];
                imgTag=urlarr[i%6];
                NSLog(@"图片顺序比对地址－－－%@",urlarr[i%6]);
            }
            
            //因为cutstr 可能是null
            NSString * cutStr=[strArr objectAtIndex:i];
            newContent=[NSString stringWithFormat:@"%@%@%@",newContent,cutStr,imgTag];
            
        }
        
        
        //上传服务器
        jsonString=newContent;
        NSLog(@"jsonString--%@",jsonString);
    }
    

    
    
  
    
}

#pragma mark prepareForSegue 列表展示
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //1.如果是 changText＝NO
    UIViewController * ctrl=segue.destinationViewController;
    if ([ctrl isKindOfClass:[TableViewController class]]) {
        if (textNeedAttribute==NO) {
            TableViewController * table=(TableViewController *)ctrl;
            table.title=@"无属性文字";
            table.jsonString=jsonString;
        }

        
    }
    
    //2.如果是 changText＝YES
    
    if ([ctrl isKindOfClass:[TableViewController1 class]]) {
        if (textNeedAttribute) {
            TableViewController1 * table1=(TableViewController1 *)ctrl;
             table1.title=@"属性文字富文本";
            table1.jsonString=jsonString;
        }

        
    }
}

//    需要返回的是网页,开启代理
//    ctrl.RTDelegate=self;
//    ctrl.feedbackHtml=YES;
#pragma mark RichTextViewControllerDelegate 生成网页
-(void)uploadImageArray:(NSArray *)imageArr withCompletion:(NSString * (^)(NSArray * urlArray))completion;
{
    
    //上传图片
    
    
    //把图片地址传入
    NSMutableArray * urlArr=[NSMutableArray array];
    //模拟图片上传，返回每个图片的地址和大小
    for (int i=0; i<imageArr.count; i++) {
        PictureModel * model=[[PictureModel alloc]init];
        model.imageurl=@"http://photocdn.sohu.com/20160426/Img446187083.jpg";
        [urlArr addObject:model];
    }
    
    
    
    //获取到网页
   NSString * htmlStr=completion(urlArr);
    
    NSLog(@"htmlStr--%@",htmlStr);

    
    //这个显示就看大家怎么处理了
    [self.webView loadHTMLString:htmlStr baseURL:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
