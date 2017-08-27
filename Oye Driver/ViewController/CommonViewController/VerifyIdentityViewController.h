//
//  VerifyIdentityViewController.h
//  Oye Driver
//
//  Created by Sujan on 8/23/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerifyIdentityViewController : UIViewController<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *paperCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *frontSidePhoto;
@property (weak, nonatomic) IBOutlet UIImageView *backsidePhoto;
@property (weak, nonatomic) IBOutlet UIButton *crossButton;

@property (weak, nonatomic) IBOutlet UIButton *frontCameraButton;
@property (weak, nonatomic) IBOutlet UILabel *frontSideLabel;
@property (weak, nonatomic) IBOutlet UIButton *backCameraButton;
@property (weak, nonatomic) IBOutlet UILabel *backSideLabel;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;


@end
