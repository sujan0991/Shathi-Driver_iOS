//
//  LegalDocumentUploadViewController.h
//  Oye Driver
//
//  Created by Sujan on 10/4/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LegalDocumentUploadViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *presentAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *permanentAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *nidNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *licenseTextField;
@property (weak, nonatomic) IBOutlet UITextField *registrationNoTextField;
@property (weak, nonatomic) IBOutlet UITextField *bikeModelTextField;
@property (weak, nonatomic) IBOutlet UITextField *bikeEngineTextField;

@property (weak, nonatomic) IBOutlet UIButton *crossButton;


@property (weak, nonatomic) IBOutlet UIImageView *nIDFrontImageView;
@property (weak, nonatomic) IBOutlet UIImageView *nIDBackImageView;
@property (weak, nonatomic) IBOutlet UILabel *nIDFrontSideLabel;
@property (weak, nonatomic) IBOutlet UILabel *nIDBackSideLabel;
@property (weak, nonatomic) IBOutlet UIImageView *licenseFrontImageView;
@property (weak, nonatomic) IBOutlet UIImageView *licenSeBackImageView;
@property (weak, nonatomic) IBOutlet UILabel *licenseFrontSideLabel;
@property (weak, nonatomic) IBOutlet UILabel *licenseBackSideLabel;
@property (weak, nonatomic) IBOutlet UIImageView *registrationFrontImageView;
@property (weak, nonatomic) IBOutlet UIImageView *registrationBackImageView;
@property (weak, nonatomic) IBOutlet UILabel *registrationFrontSideLabel;
@property (weak, nonatomic) IBOutlet UILabel *registrationBackSideLabel;

@property (weak, nonatomic) IBOutlet UIView *spinnerView;

@property BOOL isCrossHidden;

@end
