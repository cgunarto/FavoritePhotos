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
    self.collectionView.pagingEnabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.favoritePhotosArray = [@[]mutableCopy];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.collectionView reloadData];
}

#pragma mark Collection View 

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"favoriteCell" forIndexPath:indexPath];
    InstagramPhotos *instaPhoto = self.favoritePhotosArray[indexPath.row];
    photoCell.imageView.image = [UIImage imageWithData:instaPhoto.StandardResolutionPhotoData];

    return photoCell;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.favoritePhotosArray.count;
}




@end
