//
//  VerifyIdentityViewController.m
//  Oye Driver
//
//  Created by Sujan on 8/23/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "VerifyIdentityViewController.h"
#import "BikePaperCollectionViewCell.h"

@interface VerifyIdentityViewController (){

    NSMutableArray *imageArray;
    UIImage *chosenImage;
    UIImage *frontImage;
    UIImage *backImage;
    
    NSIndexPath *selectedIndex;
    
    BOOL isReplace;
    BOOL isDelete;
    BOOL isSelectFront;
    BOOL isSelectBack;
    
}

@end

@implementation VerifyIdentityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isSelectFront = NO;
    isReplace = NO;
    isDelete = NO;
    isSelectBack = NO;
    
    self.paperCollectionView.delegate = self;
    self.paperCollectionView.dataSource= self;
    
    imageArray = [[NSMutableArray alloc]init];
    
    
    self.collectionViewHeight.constant = ([UIScreen mainScreen].bounds.size.width-50)/2 *0.62;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)frontSideCameraButtonAction:(id)sender {
    
    isSelectFront = YES;
    
    [self openCamera];
}


- (IBAction)backSideButtonAction:(id)sender {
    
    isSelectBack = YES;
    
    [self openCamera];
}




#pragma mark - CollectionView data source

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    
    return  imageArray.count + 1;
    
    //return 2;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    

    
    if (indexPath.row == 0) {
        
        static NSString *identifier = @"addCell";
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
      
        
        return cell;
        
    }else {
        
        
        
        static NSString *identifier = @"paperCell";
        
        BikePaperCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        cell.paperPhoto.image = [UIImage imageWithData:[imageArray objectAtIndex:indexPath.row-1]];
        
        cell.shadeView.hidden=YES;
       
        cell.replaceButton.tag = indexPath.row - 1;
        cell.deleteButton.tag = indexPath.row - 1;
        
        
        return cell;
        
    }
    
    return nil;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    BikePaperCollectionViewCell * cell=(BikePaperCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        
         [self openCamera];
        
    }else{
        
        
        if (selectedIndex != indexPath) {
            
            BikePaperCollectionViewCell * oldCell=(BikePaperCollectionViewCell*)[collectionView cellForItemAtIndexPath:selectedIndex];
            oldCell.shadeView.hidden = YES;
            
            selectedIndex = indexPath;
            cell.shadeView.hidden = NO;
            
        }
        else {
            
           selectedIndex = nil;
            cell.shadeView.hidden = YES;
        }
        
        
    
    }

}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    

        
        return CGSizeMake(([UIScreen mainScreen].bounds.size.width-50)/2, ([UIScreen mainScreen].bounds.size.width-50)/2 *0.62);
    
    
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    

    if (isReplace) {
        
        NSLog(@"isReplace");
        
        chosenImage = info[UIImagePickerControllerOriginalImage];
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(chosenImage)];
        
        [imageArray replaceObjectAtIndex:selectedIndex.row -1 withObject:imageData];
        
        isReplace = NO;
        
        [picker dismissViewControllerAnimated:YES completion:^{
            
            
        }];
        
         [self.paperCollectionView reloadData];
        
    }else if (isSelectFront)
    {
        NSLog(@"isSelectFront");
        
       frontImage = info[UIImagePickerControllerOriginalImage];
        
       self.frontSidePhoto.image = frontImage;
        
       isSelectFront = NO;
        
        [picker dismissViewControllerAnimated:YES completion:^{
            
            
         }];
    
    }else if (isSelectBack)
    {
        NSLog(@"isSelectBack");
        
        backImage = info[UIImagePickerControllerOriginalImage];
        self.backsidePhoto.image = backImage;
        
        isSelectBack = NO;
        
        [picker dismissViewControllerAnimated:YES completion:^{
            
            
        }];
        
    }else{
        
      chosenImage = info[UIImagePickerControllerOriginalImage];
      NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(chosenImage)];
        
      [imageArray addObject:imageData];
    
    
      [picker dismissViewControllerAnimated:NO completion:^{
        
         if (imageArray.count%2 == 0) {
            
            [UIView animateWithDuration:60
            
                        animations:^{
            
                             self.collectionViewHeight.constant  = self.collectionViewHeight.constant+ ([UIScreen mainScreen].bounds.size.width-50)/2 *0.62+ 10;
            
             }
             completion:^(BOOL finished){
            
              }];
            
            
         }
        
        [self.paperCollectionView reloadData];
        
        
        
        }];
    
     }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    if (isReplace) {
        
        isReplace = NO;
    }
    chosenImage=nil;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (IBAction)replaceButtonAction:(UIButton*)sender {
    
    isReplace = YES;
    
    [self openCamera];
    
}
- (IBAction)deleteButtonAction:(UIButton*)sender {
    
    [imageArray removeObjectAtIndex:selectedIndex.row - 1];
    
    if (imageArray.count%2 != 0) {
        
        [UIView animateWithDuration:60
         
                         animations:^{
                             
                             self.collectionViewHeight.constant  = self.collectionViewHeight.constant- ([UIScreen mainScreen].bounds.size.width-50)/2 *0.62 - 10;
                             
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
    [self.paperCollectionView reloadData];
}


- (IBAction)submitButtonAction:(id)sender {
    
    
    
}


- (IBAction)crossButtonAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)openCamera{

    UIImagePickerControllerSourceType source = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
    cameraController.delegate = self;
    cameraController.sourceType = source;
    //cameraController.allowsEditing = YES;
    [self presentViewController:cameraController animated:YES completion:^{
        //iOS 8 bug.  the status bar will sometimes not be hidden after the camera is displayed, which causes the preview after an image is captured to be black
        if (source == UIImagePickerControllerSourceTypeCamera) {
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
            
        }
    }];



}

@end
