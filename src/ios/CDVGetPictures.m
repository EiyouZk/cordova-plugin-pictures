#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "CDVGetPictures.h"
#import <Cordova/CDV.h>

@interface CDVGetPictures()
@end

static Boolean isFirst=true;
static int oldcount=0;
static bool onPause=false;
static bool flag=true;

@implementation CDVGetPictures:CDVPlugin
-(void)getAllPictures:(CDVInvokedUrlCommand*)command
{
 typedef enum {
        kCLAuthorizationStatusNotDetermined = 0, // 用户尚未做出选择这个应用程序的问候
        kCLAuthorizationStatusRestricted,        // 此应用程序没有被授权访问的照片数据。可能是家长控制权限
        kCLAuthorizationStatusDenied,            // 用户已经明确否认了这一照片数据的应用程序访问
        kCLAuthorizationStatusAuthorized         // 用户已经授权应用访问照片数据
    } CLAuthorizationStatus;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        ALAuthorizationStatus author =[ALAssetsLibrary authorizationStatus];
        if (author == kCLAuthorizationStatusRestricted || author == kCLAuthorizationStatusDenied) {
            //无权限
            NSLog(@"< 8.0");
            CDVPluginResult* pluginResult = nil;
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                              messageAsBool:false];
            [self.commandDelegate sendPluginResult:pluginResult
                                        callbackId:command.callbackId];
            return;
        }
    }
    else {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusRestricted ||
            status == PHAuthorizationStatusDenied) {
            //无权限
            NSLog(@"> 8.0");
            CDVPluginResult* pluginResult = nil;
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                               messageAsBool:false];
            [self.commandDelegate sendPluginResult:pluginResult
                                        callbackId:command.callbackId];
            return;
        }
    }
    
    NSString *value = [command.arguments objectAtIndex:0];
    int type = [value intValue];
    if (type==0) {
        isFirst=true;
        onPause=false;
        oldcount=0;
        flag=true;
        NSThread  *thread=[[NSThread alloc]initWithTarget:self
                                                 selector:@selector(getAllPicture:)
                                                   object:command];
        [thread start];
        return;
    }
    else if (type==1){
        onPause=true;
         return;
    }
}

-(void)getAllPicture:(CDVInvokedUrlCommand*)command
{
 while (flag) {
        NSString *CameraRoll=@"Camera Roll";
        ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        __block int count = 0;
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [assetsLib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if (group) {
                    NSString *GroupPropertyName=[group valueForProperty:ALAssetsGroupPropertyName];
                    if ([GroupPropertyName isEqualToString:CameraRoll]) {
                        count=[group numberOfAssets];
                        if (isFirst) {
                            NSLog(@"first");
                            oldcount=count;
                            isFirst=false;
                        }
                        else if (onPause)
                        {
                            flag=false;
                            return ;
                        }
                        else if (oldcount<count)
                        {
                            NSLog(@"oldcount: %d, count: %d ",oldcount,count);
                            isFirst=true;
                            CDVPluginResult* pluginResult = nil;
                            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                               messageAsBool:true];
                            if (oldcount<count) {
                                [self.commandDelegate sendPluginResult:pluginResult
                                                            callbackId:command.callbackId];
                                oldcount=count;
                                flag=false;
                                return;
                            }
                            
                            return;
                        }
                        //[self callback:command with:count];
                    }
                }
                else {
                    //NSLog( @"2222222222");
                    dispatch_semaphore_signal(sema);
                }
            } failureBlock:^(NSError *error) {
                NSLog(@"enumerateGroupsWithTypes failure %@", [error localizedDescription]);
                dispatch_semaphore_signal(sema);
            }];
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        //NSLog( @"number of groups is: %d", numberOfGroups);
    }
   /*
    NSString *CameraRoll=@"Camera Roll";
    ALAssetsLibraryGroupsEnumerationResultsBlock libraryEnumerationBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil) {
            NSString *GroupPropertyName=[group valueForProperty:ALAssetsGroupPropertyName];
            if ([GroupPropertyName isEqualToString:CameraRoll]) {
                //NSLog(@"名稱: %@, 數目: %d ",[group valueForProperty:ALAssetsGroupPropertyName], [group numberOfAssets]);
                int count=[group numberOfAssets];
                [self callback:command with:count];
            }
        }
    };
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSLog(@"失敗處理常式");
    };
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:libraryEnumerationBlock
                         failureBlock:failureBlock];
                         */
}

-(void)callback:(CDVInvokedUrlCommand*)command with:(int)count
{
    
    if (isFirst) {
        NSLog(@"first");
        oldcount=count;
        isFirst=false;
        NSThread  *thread=[[NSThread alloc]initWithTarget:self selector:@selector(getAllPictures:) object:command];
        [thread start];
    }
    else if (oldcount<count)
    {
        oldcount=count;
        isFirst=true;
        NSLog(@"oldcount: %d, count: %d ",oldcount,count);
        CDVPluginResult* pluginResult = nil;
        NSString *stringInt = [NSString stringWithFormat:@"%d",count];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:stringInt];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    else
    {
        NSThread  *thread=[[NSThread alloc]initWithTarget:self selector:@selector(getAllPictures:) object:command];
        [thread start];
    }
}
@end
