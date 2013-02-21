//
//  QCFlipsideViewController.h
//  und-h
//
//  Created by Daniel on 21.02.13.
//  Copyright (c) 2013 QuantumCow. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QCFlipsideViewController;

@protocol QCFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(QCFlipsideViewController *)controller;
@end

@interface QCFlipsideViewController : UIViewController

@property (weak, nonatomic) id <QCFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
