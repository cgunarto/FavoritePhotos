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

@property (strong, nonatomic) NSMutableArray *favoritedPhotosArray;
@property (strong, nonatomic) NSMutableArray *favoritedPhotosLatitudeArray;
@property (strong, nonatomic) NSMutableArray *favoritedPhotosLongitudeArray;

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
    NSData *imageData= self.favoritedPhotosArray[indexPath.row];

    photoCell.imageView.image = [UIImage imageWithData:imageData];

    return photoCell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.favoritedPhotosArray.count;
}

#pragma mark Long Press to Edit

- (IBAction)onPhotoLongPressed:(UILongPressGestureRecognizer *)gesture
{
    CGPoint selectedPoint = [gesture locationInView:self.collectionView];
    NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint:selectedPoint];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DELETE" message:@"Delete Photo?" preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *deleteButton = [UIAlertAction actionWithTitle:@"Delete"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
                                                     {
                                                         [self.favoritedPhotosArray removeObjectAtIndex:selectedIndexPath.item];

                                                         [self.favoritedPhotosLatitudeArray removeObjectAtIndex:selectedIndexPath.item];

                                                         [self.favoritedPhotosLongitudeArray removeObjectAtIndex:selectedIndexPath.item];

                                                         [self save];
                                                         [self.collectionView reloadData];
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                     }];

    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                    style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action)
                                                         {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];

                                                         }];

    [alert addAction:deleteButton];
    [alert addAction:cancelButton];

    [self presentViewController:alert
                       animated:YES
                     completion:nil];

}






#pragma mark Save and Load Methods

- (void)save
{
    NSURL *plistURL = [[self documentsDirectoryURL]URLByAppendingPathComponent:@"favPhotos.plist"];
    [self.favoritedPhotosArray writeToURL:plistURL atomically:YES];

    plistURL = [[self documentsDirectoryURL]URLByAppendingPathComponent:@"favPhotosLatitude.plist"];
    [self.favoritedPhotosLatitudeArray writeToURL:plistURL atomically:YES];

    plistURL = [[self documentsDirectoryURL]URLByAppendingPathComponent:@"favPhotosLongitude.plist"];
    [self.favoritedPhotosLongitudeArray writeToURL:plistURL atomically:YES];

}

- (void)load
{
    NSURL *plistURL = [[self documentsDirectoryURL]URLByAppendingPathComponent:@"favPhotos.plist"];
    self.favoritedPhotosArray = [NSMutableArray arrayWithContentsOfURL:plistURL];

    plistURL = [[self documentsDirectoryURL]URLByAppendingPathComponent:@"favPhotosLatitude.plist"];
    self.favoritedPhotosLatitudeArray = [NSMutableArray arrayWithContentsOfURL:plistURL];

    plistURL = [[self documentsDirectoryURL]URLByAppendingPathComponent:@"favPhotosLongitude.plist"];
    self.favoritedPhotosLongitudeArray = [NSMutableArray arrayWithContentsOfURL:plistURL];

    if (self.favoritedPhotosArray == nil)
    {
        self.favoritedPhotosArray = [@[]mutableCopy];
        self.favoritedPhotosLatitudeArray = [@[]mutableCopy];
        self.favoritedPhotosLongitudeArray = [@[]mutableCopy];
    }
}

- (NSURL*)documentsDirectoryURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    return url;
}

@end
