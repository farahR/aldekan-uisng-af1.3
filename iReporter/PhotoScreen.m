//
//  PhotoScreen.m
//  iReporter
//
//  Created by Marin Todorov on 09/02/2012.
//  Copyright (c) 2012 Marin Todorov. All rights reserved.
//

#import "PhotoScreen.h"
#import "API.h"
#import "UIImage+Resize.h"
#import "UIAlertView+error.h"



@interface PhotoScreen(private)
-(void)takePhoto;
-(void)effects;
-(void)uploadPhoto;
-(void)logout;
@end

@implementation PhotoScreen

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Custom initialization
    self.navigationItem.rightBarButtonItem = btnAction;
    self.navigationItem.title = @"Post photo";
    if (![[API sharedInstance] isAuthorized]) {
        [self performSegueWithIdentifier:@"ShowLogin" sender:nil];
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - menu

-(IBAction)btnActionTapped:(id)sender
{
    [fldTitle resignFirstResponder];
    
    //show the app menu
    [[[UIActionSheet alloc] initWithTitle:nil
                                 delegate:self
                        cancelButtonTitle:@"Close"
                   destructiveButtonTitle:nil
                        otherButtonTitles:@"Take photo", @"Effects!", @"Post Photo", @"Logout", nil]
     showInView:self.view];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self takePhoto]; break;
        case 1:
            [self effects];break;
        case 2:
            [self uploadPhoto]; break;
        case 3:
            [self logout]; break;
    }
}
-(void)takePhoto {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
#if TARGET_IPHONE_SIMULATOR
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#else
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
#endif
    imagePickerController.editing = YES;
    imagePickerController.delegate = (id)self;
    
    [self presentModalViewController:imagePickerController animated:YES];
}
#pragma mark - Image picker delegate methdos
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // Resize the image from the camera
	UIImage *scaledImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(photo.frame.size.width, photo.frame.size.height) interpolationQuality:kCGInterpolationHigh];
    // Crop the image to a square (yikes, fancy!)
    UIImage *croppedImage = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -photo.frame.size.width)/2, (scaledImage.size.height -photo.frame.size.height)/2, photo.frame.size.width, photo.frame.size.height)];
    // Show the photo on the screen
    photo.image = croppedImage;
    [picker dismissModalViewControllerAnimated:NO];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:NO];
}
-(void)logout {
    //logout the user from the server, and also upon success destroy the local authorization
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             @"logout",@"command",
                                             nil]
                               onCompletion:^(NSDictionary *json) {
                                   
                                   //logged out from server
                                   [API sharedInstance].user = nil;
                                   [self performSegueWithIdentifier:@"ShowLogin" sender:nil];
                               }];
}
//+ (NSSet *)acceptableContentTypes {
//    return [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
//}
-(void)uploadPhoto {
    //upload the image and the title to the web service
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             @"upload",@"command",
                                             UIImageJPEGRepresentation(photo.image,70),@"file",
                                             fldTitle.text, @"title",
                                             nil]
                               onCompletion:^(NSDictionary *json) {
                                   
                                   //completion
                                   //completion
                                   if ([json objectForKey:@"error"]== Nil) {
                                       
                                       //success
                                       [[[UIAlertView alloc]initWithTitle:@"Success!"
                                                                  message:@"Your photo is uploaded"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"Yay!"
                                                        otherButtonTitles: nil] show];
                                       
                                   } else {
                                       //error, check for expired session and if so - authorize the user
                                       NSString* errorMsg = [json objectForKey:@"error"];
                                       [UIAlertView error:errorMsg];
                                       
                                       if ([@"Authorization required" compare:errorMsg]==NSOrderedSame) {
                                           [self performSegueWithIdentifier:@"ShowLogin" sender:nil];
                                       }
                                   }
                                   
                               }];
}
@end
