//
//  QCMainViewController.h
//  und-h
//
//  Created by Daniel on 21.02.13.
//  Copyright (c) 2013 QuantumCow. All rights reserved.
//

#import "QCFlipsideViewController.h"
#import <AudioToolbox/AudioServices.h>
#import <CoreLocation/CoreLocation.h>

@interface QCMainViewController : UIViewController <QCFlipsideViewControllerDelegate, UIAlertViewDelegate>

- (IBAction)run_state_changed:(UISwitch*)sender;
- (IBAction)save:(UITextField*)sender;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
