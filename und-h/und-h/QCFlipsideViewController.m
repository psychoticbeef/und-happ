//
//  QCFlipsideViewController.m
//  und-h
//
//  Created by Daniel on 21.02.13.
//  Copyright (c) 2013 QuantumCow. All rights reserved.
//

#import "QCFlipsideViewController.h"

@interface QCFlipsideViewController ()

@end

@implementation QCFlipsideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
