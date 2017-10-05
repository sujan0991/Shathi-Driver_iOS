//
//  LegalDocumentUploadViewController.m
//  Oye Driver
//
//  Created by Sujan on 10/4/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "LegalDocumentUploadViewController.h"
#import "ServerManager.h"

@interface LegalDocumentUploadViewController (){
    
    UIImage *chosenImage;
    
    BOOL isSelectNIDFront;
    BOOL isSelectNIDBack;
    BOOL isSelectLicenseFront;
    BOOL isSelectLicenseBack;
    BOOL isSelectRegistrationFront;
    BOOL isSelectRegistrationBack;
}

@end

@implementation LegalDocumentUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isSelectNIDFront = NO;
    isSelectNIDBack = NO;
    isSelectLicenseFront = NO;
    isSelectLicenseBack = NO;
    isSelectRegistrationFront = NO;
    isSelectRegistrationBack = NO;
    
    [self.presentAddressTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.permanentAddressTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.nidNumberTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.licenseTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.registrationNoTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.bikeModelTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.bikeEngineTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    
    [self.scrollView addGestureRecognizer:tapGesture];
    
    [self registerForKeyboardNotifications];

}

-(void)hideKeyboard
{
    [self.presentAddressTextField resignFirstResponder];
    [self.permanentAddressTextField resignFirstResponder];
    [self.nidNumberTextField resignFirstResponder];
    [self.licenseTextField resignFirstResponder];
    [self.registrationNoTextField resignFirstResponder];
    [self.bikeModelTextField resignFirstResponder];
    [self.bikeEngineTextField resignFirstResponder];
}

- (void)registerForKeyboardNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}
- (void)keyboardWasShown:(NSNotification*)aNotification{
    
    NSDictionary* info = [aNotification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    
    self.scrollView.contentInset = contentInsets;
    
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    
    // Your app might not need or want this behavior.
    
    CGRect aRect = self.view.frame;
    
    aRect.size.height -= kbSize.height;
    
    if (!CGRectContainsPoint(aRect, self.bikeEngineTextField.frame.origin) && [self.bikeEngineTextField isEditing] ) {
        
        [self.scrollView scrollRectToVisible:self.bikeEngineTextField.frame animated:YES];
        
    }else if (!CGRectContainsPoint(aRect, self.bikeModelTextField.frame.origin) && [self.bikeModelTextField isEditing] ) {
        
        [self.scrollView scrollRectToVisible:self.bikeModelTextField.frame animated:YES];
        
    }else if (!CGRectContainsPoint(aRect, self.registrationNoTextField.frame.origin) && [self.registrationNoTextField isEditing] ) {
        
        [self.scrollView scrollRectToVisible:self.registrationNoTextField.frame animated:YES];
        
    }else if (!CGRectContainsPoint(aRect, self.licenseTextField.frame.origin) && [self.licenseTextField isEditing]) {
        
        [self.scrollView scrollRectToVisible:self.licenseTextField.frame animated:YES];
        
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    self.scrollView.contentInset = contentInsets;
    
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField{
//    
//    [self.pre resignFirstResponder];
//    [self.passText resignFirstResponder];
//    [self.nickNameTextView resignFirstResponder];
//    
//    return YES;
//}

- (IBAction)nIDfrontCameraButtonAction:(id)sender {
    
    isSelectNIDFront = YES;
    
    [self openCamera];
    
}

- (IBAction)nIDbackCameraButtonAction:(id)sender {
    isSelectNIDBack = YES;
    
    [self openCamera];
    
}
- (IBAction)licenseFrontCameraButtonAction:(id)sender {
    isSelectLicenseFront = YES;
    
    [self openCamera];
    
}
- (IBAction)licenseBackCameraButtonAction:(id)sender {
    isSelectLicenseBack = YES;
    
    [self openCamera];
    
}
- (IBAction)registrationFrontCameraButtonAction:(id)sender {
    isSelectRegistrationFront = YES;
    
    [self openCamera];
    
}
- (IBAction)registrationBackCameraButtonAction:(id)sender {
    isSelectRegistrationBack = YES;
    
    [self openCamera];
    
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    

if (isSelectNIDFront)
{
    NSLog(@"isSelectFront");
    
    chosenImage = info[UIImagePickerControllerOriginalImage];
    
    self.nIDFrontImageView.image = chosenImage;
    
    isSelectNIDFront = NO;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
}else if (isSelectNIDBack)
{
    NSLog(@"isSelectBack");
    
    chosenImage = info[UIImagePickerControllerOriginalImage];
    self.nIDBackImageView.image = chosenImage;
    
    isSelectNIDBack = NO;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
}
else if (isSelectLicenseFront)
{
    NSLog(@"isSelectLicenseFront");
    
    chosenImage = info[UIImagePickerControllerOriginalImage];
    self.licenseFrontImageView.image = chosenImage;
    
    isSelectLicenseFront = NO;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
}
else if (isSelectLicenseBack)
{
    NSLog(@"isSelectLicenseBack");
    
    chosenImage = info[UIImagePickerControllerOriginalImage];
    self.licenSeBackImageView.image = chosenImage;
    
    isSelectLicenseBack = NO;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
}
else if (isSelectRegistrationFront)
{
    NSLog(@"isSelectRegistrationFront");
    
    chosenImage = info[UIImagePickerControllerOriginalImage];
    self.registrationFrontImageView.image = chosenImage;
    
    isSelectRegistrationFront = NO;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
}
else if (isSelectRegistrationBack)
{
    NSLog(@"isSelectRegistrationBack");
    
    chosenImage = info[UIImagePickerControllerOriginalImage];
    self.registrationBackImageView.image = chosenImage;
    
    isSelectRegistrationBack = NO;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
   
    chosenImage=nil;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
}

- (IBAction)submitButtonAction:(id)sender {
    
    //NSData *imageData = UIImageJPEGRepresentation([imageArray objectAtIndex:i], 0.5);
    
    NSMutableDictionary * documentDic = [[NSMutableDictionary alloc]init];
    
    [documentDic setObject:self.presentAddressTextField.text forKey:@"present_address"];
    [documentDic setObject:self.permanentAddressTextField.text forKey:@"permanent_address"];
    [documentDic setObject:self.nidNumberTextField.text forKey:@"nid_number"];
    [documentDic setObject:self.licenseTextField.text forKey:@"license_number"];
    [documentDic setObject:self.registrationNoTextField.text forKey:@"bike_number"];
    [documentDic setObject:self.bikeModelTextField.text forKey:@"bike_model"];
    [documentDic setObject:self.bikeEngineTextField.text forKey:@"bike_engine"];
    
    NSMutableDictionary * imageDic = [[NSMutableDictionary alloc]init];
    
    if (![self.nIDFrontImageView isEqual:nil]){
      NSData *imageDataForNIDfront = UIImageJPEGRepresentation(self.nIDFrontImageView.image, 0.5);
      [imageDic setObject:imageDataForNIDfront forKey:@"nid_front"];
    }else if (![self.nIDBackImageView isEqual:nil]){
        
      NSData *imageDataForNIDback = UIImageJPEGRepresentation(self.nIDBackImageView.image, 0.5);
      [imageDic setObject:imageDataForNIDback forKey:@"nid_back"];
        
    }else if (![self.licenseFrontImageView isEqual:nil]){

      NSData *imageDataForLicensefront = UIImageJPEGRepresentation(self.licenseFrontImageView.image, 0.5);
      [imageDic setObject:imageDataForLicensefront forKey:@"license_front"];
    
    }else if (![self.licenSeBackImageView isEqual:nil]){
    NSData *imageDataForLicenseback = UIImageJPEGRepresentation(self.licenSeBackImageView.image, 0.5);
    [imageDic setObject:imageDataForLicenseback forKey:@"license_back"];
   
    }else if (![self.registrationFrontImageView isEqual:nil]){
      NSData *imageDataForRegistrationfront = UIImageJPEGRepresentation(self.registrationFrontImageView.image, 0.5);
      [imageDic setObject:imageDataForRegistrationfront forKey:@"bike_registration_front"];
    
    }else if (![self.registrationBackImageView isEqual:nil]){
      NSData *imageDataForRegistrationback = UIImageJPEGRepresentation(self.registrationBackImageView.image, 0.5);
      [imageDic setObject:imageDataForRegistrationback forKey:@"bike_registration_back"];
    }

    
//    NSLog(@"documentDic %@",documentDic);
//    NSLog(@"iamgeDic %@",imageDic);
    

        
        [[ServerManager sharedManager] postDocumentWithData:documentDic andImage:imageDic withCompletion:^(BOOL success) {
            
            if (success) {
                
                NSLog(@"successfully update document");
                
            }
            else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    chosenImage = nil;
                    
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed!"
                                                                    message:@"Couldnt change the profile pic, please try again"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles: nil];
                    [alert show];
                    
                });
            }
            
        }];
        
        
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
