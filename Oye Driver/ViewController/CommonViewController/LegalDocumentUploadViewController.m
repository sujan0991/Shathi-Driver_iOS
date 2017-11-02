//
//  LegalDocumentUploadViewController.m
//  Oye Driver
//
//  Created by Sujan on 10/4/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "LegalDocumentUploadViewController.h"
#import "ServerManager.h"
#import "JTMaterialSpinner.h"

@interface LegalDocumentUploadViewController (){
    
    
    
    BOOL isSelectNIDFront;
    BOOL isSelectNIDBack;
    BOOL isSelectLicenseFront;
    BOOL isSelectLicenseBack;
    BOOL isSelectRegistrationFront;
    BOOL isSelectRegistrationBack;
    
    JTMaterialSpinner *spinner;
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
    
    
    spinner=[[JTMaterialSpinner alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 17, self.view.frame.size.height/2-17, 35, 35)];
    [self.spinnerView bringSubviewToFront:spinner];
    [self.spinnerView addSubview:spinner];
    spinner.hidden =YES;
    self.spinnerView.hidden = YES;
    
    
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
        
     
        
        self.nIDFrontImageView.image = info[UIImagePickerControllerOriginalImage];
        
        isSelectNIDFront = NO;
        
        [picker dismissViewControllerAnimated:YES completion:^{
            
            
        }];
        
    }else if (isSelectNIDBack)
    {
        NSLog(@"isSelectBack");
        
       
        self.nIDBackImageView.image =  info[UIImagePickerControllerOriginalImage];
        
        isSelectNIDBack = NO;
        
        [picker dismissViewControllerAnimated:YES completion:^{
            
            
        }];
        
    }
    else if (isSelectLicenseFront)
    {
        NSLog(@"isSelectLicenseFront");
        
       
        self.licenseFrontImageView.image = info[UIImagePickerControllerOriginalImage];
        
        isSelectLicenseFront = NO;
        
        [picker dismissViewControllerAnimated:YES completion:^{
            
            
        }];
        
    }
    else if (isSelectLicenseBack)
    {
        NSLog(@"isSelectLicenseBack");
        
       
        self.licenSeBackImageView.image = info[UIImagePickerControllerOriginalImage];
        
        isSelectLicenseBack = NO;
        
        [picker dismissViewControllerAnimated:YES completion:^{
            
            
        }];
        
    }
    else if (isSelectRegistrationFront)
    {
        NSLog(@"isSelectRegistrationFront");
        
       
        self.registrationFrontImageView.image = info[UIImagePickerControllerOriginalImage];
        
        isSelectRegistrationFront = NO;
        
        [picker dismissViewControllerAnimated:YES completion:^{
            
            
        }];
        
    }
    else if (isSelectRegistrationBack)
    {
        NSLog(@"isSelectRegistrationBack");
        
        
        self.registrationBackImageView.image = info[UIImagePickerControllerOriginalImage];
        
        isSelectRegistrationBack = NO;
        
        [picker dismissViewControllerAnimated:YES completion:^{
            
            
        }];
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    

    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
}

- (IBAction)submitButtonAction:(id)sender {
    
    self.spinnerView.hidden = NO;
    spinner.hidden = NO;
    [spinner beginRefreshing];
    
    NSMutableDictionary * documentDic = [[NSMutableDictionary alloc]init];
    
    [documentDic setObject:self.presentAddressTextField.text forKey:@"present_address"];
    [documentDic setObject:self.permanentAddressTextField.text forKey:@"permanent_address"];
    [documentDic setObject:self.nidNumberTextField.text forKey:@"nid_number"];
    [documentDic setObject:self.licenseTextField.text forKey:@"license_number"];
    [documentDic setObject:self.registrationNoTextField.text forKey:@"bike_number"];
    [documentDic setObject:self.bikeModelTextField.text forKey:@"bike_model"];
    [documentDic setObject:self.bikeEngineTextField.text forKey:@"bike_engine"];
    
    NSMutableDictionary * imageDic = [[NSMutableDictionary alloc]init];
    
    if (self.nIDFrontImageView.image !=nil){
      
        
      NSData *imageDataForNIDfront = UIImageJPEGRepresentation(self.nIDFrontImageView.image, 0.5);
      [imageDic setObject:imageDataForNIDfront forKey:@"nid_front"];
        
    }
    if (self.nIDBackImageView.image !=nil){
        
      NSData *imageDataForNIDback = UIImageJPEGRepresentation(self.nIDBackImageView.image, 0.5);
      [imageDic setObject:imageDataForNIDback forKey:@"nid_back"];
        
    }
    if (self.licenseFrontImageView.image !=nil){

      NSData *imageDataForLicensefront = UIImageJPEGRepresentation(self.licenseFrontImageView.image, 0.5);
      [imageDic setObject:imageDataForLicensefront forKey:@"license_front"];
    
    }
    if (self.licenSeBackImageView.image !=nil){
        
      NSData *imageDataForLicenseback = UIImageJPEGRepresentation(self.licenSeBackImageView.image, 0.5);
      [imageDic setObject:imageDataForLicenseback forKey:@"license_back"];
   
    }
    if (self.registrationFrontImageView.image !=nil){
        
      NSData *imageDataForRegistrationfront = UIImageJPEGRepresentation(self.registrationFrontImageView.image, 0.5);
      [imageDic setObject:imageDataForRegistrationfront forKey:@"bike_registration_front"];
    
    }
    if (self.registrationBackImageView.image !=nil){
        
      NSData *imageDataForRegistrationback = UIImageJPEGRepresentation(self.registrationBackImageView.image, 0.5);
      [imageDic setObject:imageDataForRegistrationback forKey:@"bike_registration_back"];
    }

    
//    NSLog(@"documentDic %@",documentDic);
    NSLog(@"iamgeDic in viewcontroller %@",imageDic);
    

        
        [[ServerManager sharedManager] postDocumentWithData:documentDic andImage:imageDic withCompletion:^(BOOL success, NSMutableDictionary *responseObject) {
            
            if (success) {
                
                NSLog(@"successfully update document");
                
                spinner.hidden = YES;
                self.spinnerView.hidden = YES;
                [spinner endRefreshing];
                
            }
            else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    spinner.hidden = YES;
                    self.spinnerView.hidden = YES;
                    [spinner endRefreshing];
                    
                    
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
