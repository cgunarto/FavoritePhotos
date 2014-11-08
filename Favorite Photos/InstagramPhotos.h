//
//  InstagramPhotos.h
//  Favorite Photos
//
//  Created by CHRISTINA GUNARTO on 11/8/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstagramPhotos : NSObject

@property (strong, nonatomic) NSData *StandardResolutionPhotoData;
@property BOOL isImage;


- (instancetype) initWithDictionary: (NSDictionary *)photoDictionary;

@end
