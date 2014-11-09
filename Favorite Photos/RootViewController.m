//
//  ViewController.m
//  Favorite Photos
//
//  Created by CHRISTINA GUNARTO on 11/6/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "RootViewController.h"
#import "PhotoCollectionViewCell.h"
#import "InstagramPhotos.h"

@interface RootViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UITabBarControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@end

@implementation RootViewController


#pragma mark View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self load];
    self.collectionView.pagingEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self load];
    [self.collectionView reloadData];
}

#pragma mark Collection View 

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"favoriteCell" forIndexPath:indexPath];
    NSData *imageData= self.favoritePhotosArray[indexPath.row];

    photoCell.imageView.image = [UIImage imageWithData:imageData];

    return photoCell;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.favoritePhotosArray.count;
}


#pragma mark Save and Load Methods

- (void)save
{
    NSURL *plistURL = [[self documentsDirectoryURL]URLByAppendingPathComponent:@"favPhotos.plist"];
    [self.favoritePhotosArray writeToURL:plistURL atomically:YES];
}

- (void)load
{
    NSURL *plistURL = [[self documentsDirectoryURL]URLByAppendingPathComponent:@"favPhotos.plist"];
    self.favoritePhotosArray = [NSMutableArray arrayWithContentsOfURL:plistURL];

    if (self.favoritePhotosArray == nil)
    {
        self.favoritePhotosArray = [@[]mutableCopy];
    }
}

- (NSURL*)documentsDirectoryURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    return url;
}

@end
