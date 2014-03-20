//
//  ViewController.m
//  FlickrKitTest
//
//  Created by Aizawa Takashi on 2014/03/14.
//  Copyright (c) 2014年 Aizawa Takashi. All rights reserved.
//

#import "ViewController.h"
#import "FlickrKit.h"
//#import "FKDUNetworkOperation.h"

@interface ViewController ()
@property (nonatomic, retain) FKFlickrNetworkOperation *todaysInterestingOp;
@property (nonatomic, retain) FKDUNetworkOperation *checkAuthOp;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) FKDUNetworkOperation *completeAuthOp;

- (IBAction)loginButtonClicked:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAuthenticateCallback:) name:@"UserAuthCallbackNotification" object:nil];
  
	self.checkAuthOp = [[FlickrKit sharedFlickrKit] checkAuthorizationOnCompletion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!error) {
				[self userLoggedIn:userName userID:userId];
			} else {
				[self userLoggedOut];
			}
        });
	}];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.todaysInterestingOp cancel];
    [self.checkAuthOp cancel];
    [self.completeAuthOp cancel];
}

- (void) userLoggedIn:(NSString *)username userID:(NSString *)userID {
	self.userID = userID;
//	[self.authButton setTitle:@"Logout" forState:UIControlStateNormal];
//	self.authLabel.text = [NSString stringWithFormat:@"You are logged in as %@", username];
}

- (void) userLoggedOut {
//	[self.authButton setTitle:@"Login" forState:UIControlStateNormal];
//	self.authLabel.text = @"Login to flickr";
}

- (void)userAuthenticateCallback:(NSNotification *)notification
{
	NSURL *callbackURL = notification.object;
    self.completeAuthOp = [[FlickrKit sharedFlickrKit] completeAuthWithURL:callbackURL completion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!error) {
				[self userLoggedIn:userName userID:userId];
			} else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];
			}
			[self.navigationController popToRootViewControllerAnimated:YES];
		});
	}];
    
}

- (IBAction)loginButtonClicked:(id)sender {
}
@end
