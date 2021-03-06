//
//  InstagramPhotos.h
//  Favorite Photos
//
//  Created by CHRISTINA GUNARTO on 11/8/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstagramPhotos : NSObject

@property (strong, nonatomic) NSData *standardResolutionPhotoData;
@property (strong, nonatomic) NSString *photoID;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;

@property BOOL isFavorited;

- (instancetype) initWithDictionary: (NSDictionary *)photoDictionary;

@end
