//
//  QCMainViewController.m
//  und-h
//
//  Created by Daniel on 21.02.13.
//  Copyright (c) 2013 QuantumCow. All rights reserved.
//

#import "QCMainViewController.h"

@interface QCMainViewController ()
@property (nonatomic) NSUInteger vibration_count;
@property (nonatomic) SystemSoundID siri;
@property (nonatomic) NSTimer* next_drink;
@property (nonatomic) NSTimer* vibrate_timer;
@property (nonatomic) unsigned int min_wait;
@property (nonatomic) unsigned int max_wait;
@property (nonatomic) unsigned int hepps_total;
@property (nonatomic) unsigned int hepps_session;

@property (weak, nonatomic) IBOutlet UITextField* min_wait_edit;
@property (weak, nonatomic) IBOutlet UITextField* max_wait_edit;
@property (weak, nonatomic) IBOutlet UILabel* hepps_total_label;
@property (weak, nonatomic) IBOutlet UILabel* hepps_session_label;

@property (nonatomic) CLLocationManager* locationManager;

@end

@implementation QCMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.siri = [self loadSound];
	
	self.min_wait = [NSUserDefaults.standardUserDefaults integerForKey:@"min_wait"];
	self.max_wait = [NSUserDefaults.standardUserDefaults integerForKey:@"max_wait"];
	self.hepps_total = [NSUserDefaults.standardUserDefaults integerForKey:@"hepps_total"];
	
	self.min_wait_edit.text = @(self.min_wait).stringValue;
	self.max_wait_edit.text = @(self.max_wait).stringValue;
	self.hepps_session_label.text = @"0";
	self.hepps_total_label.text = @(self.hepps_total).stringValue;
	
	[self set_new_timer];
	// Do any additional setup after loading the view, typically from a nib.
	
	if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
		UIAlertView* gps_info = [[UIAlertView alloc] initWithTitle:@"Die scheiss Background Scheisse" message:@"Gibt nur Backgrounding, wenn GPS an ist. Aber niedrigste Einstellung, stromsparend. Lelelel." delegate:self cancelButtonTitle:@"kkk" otherButtonTitles:nil, nil];
		[gps_info show];
	} else {
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
		[self.locationManager startUpdatingLocation];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
	[self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)increment_counter {
	self.hepps_session_label.text = [@(++self.hepps_session) stringValue];
	self.hepps_total_label.text = [@(++self.hepps_total) stringValue];
	[NSUserDefaults.standardUserDefaults setInteger:self.hepps_total forKey:@"hepps_total"];
	[NSUserDefaults.standardUserDefaults synchronize];
}


- (void)viewDidAppear:(BOOL)animated {
}

- (void)set_new_timer {
	[self.next_drink invalidate];
	[self.vibrate_timer invalidate];
	int wait_time = [self get_random_wait_time:self.min_wait maximum:self.max_wait];
	self.next_drink =  [NSTimer scheduledTimerWithTimeInterval:wait_time target:self selector:@selector(start_vibrator:) userInfo:nil repeats:YES];
	NSLog(@"wait time: %i", wait_time);
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(QCFlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

- (void)start_vibrator:(NSTimer*)timer {
	[self increment_counter];
	[self scheduleNotificationOn:[NSDate date] text:@"Und hepp!" action:@"View" sound:nil launchImage:nil andInfo:nil];
	self.vibrate_timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(vibrate:) userInfo:nil repeats:YES];
}

- (void)vibrate:(NSTimer*)timer {
	if (++self.vibration_count > 4) {
		self.vibration_count = 0;
		AudioServicesPlaySystemSound(self.siri);
		[timer invalidate];
		[self set_new_timer];
	}
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


- (int)loadSound {
	NSString* str =  [[NSBundle mainBundle] pathForResource:@"siri" ofType:@"caf"];
	
	CFURLRef soundFileURL = (__bridge CFURLRef)[NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	SystemSoundID soundID = 0;
	OSStatus audio_error_code = AudioServicesCreateSystemSoundID(soundFileURL, &soundID);
	if (audio_error_code) {
		UIAlertView* load_error = [[UIAlertView alloc] initWithTitle:@"Siri.caf @[" message:@"Die raketenwissenschaftliche Sounddatei ist nicht da? m(" delegate:self cancelButtonTitle:@"Nein" otherButtonTitles:nil, nil];
		[load_error show];
	}
	return soundID;
}

- (IBAction)save:(id)sender {
	self.min_wait = abs(self.min_wait_edit.text.intValue);
	self.max_wait = abs(self.max_wait_edit.text.intValue);

	self.min_wait = MAX(5, self.min_wait);

	if (self.min_wait > self.max_wait) {	// lel, kein swap
		int tmp = self.min_wait;
		self.min_wait = self.max_wait;
		self.max_wait = tmp;
	}

	self.min_wait_edit.text = @(self.min_wait).stringValue;
	self.max_wait_edit.text = @(self.max_wait).stringValue;

	[NSUserDefaults.standardUserDefaults setInteger:self.min_wait forKey:@"min_wait"];
	[NSUserDefaults.standardUserDefaults setInteger:self.max_wait forKey:@"max_wait"];
	[NSUserDefaults.standardUserDefaults synchronize];
}

- (IBAction)run_state_changed:(UISwitch*)sender {
	if (!sender.on) {
		[self.vibrate_timer invalidate];
		[self.next_drink invalidate];
	} else {
		[self set_new_timer];
	}
	
}

- (int)get_random_wait_time:(int)minimum maximum:(int)maximum {
	return arc4random_uniform(maximum - minimum) + minimum;
}

- (void) scheduleNotificationOn:(NSDate*) fireDate
						   text:(NSString*) alertText
						 action:(NSString*) alertAction
						  sound:(NSString*) soundfileName
					launchImage:(NSString*) launchImage
						andInfo:(NSDictionary*) userInfo

{
	UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireDate;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertBody = alertText;
    localNotification.alertAction = alertAction;
	if(soundfileName == nil) {
		localNotification.soundName = UILocalNotificationDefaultSoundName;
	}
	else {
		localNotification.soundName = soundfileName;
	}
	localNotification.alertLaunchImage = launchImage;
    localNotification.userInfo = userInfo;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end

