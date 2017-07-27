#ifndef GetPictures_h
#define GetPictures_h

#import <Cordova/CDV.h>

#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@interface CDVGetPictures : CDVPlugin

-(void)getAllPictures:(CDVInvokedUrlCommand*) command;

@end

#endif 
