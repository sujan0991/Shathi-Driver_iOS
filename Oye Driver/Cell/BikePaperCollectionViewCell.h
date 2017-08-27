//
//  BikePaperCollectionViewCell.h
//  Oye Driver
//
//  Created by Sujan on 8/23/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BikePaperCollectionViewCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UIImageView *paperPhoto;

@property (weak, nonatomic) IBOutlet UIView *shadeView;
@property (weak, nonatomic) IBOutlet UIButton *replaceButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end
