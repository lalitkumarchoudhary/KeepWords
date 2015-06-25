//
//  AddNoteViewController.m
//  MyColorNote
//
//  Created by Lalit Choudhary on 23/04/15.
//  Copyright (c) 2015 Lalit Choudhary. All rights reserved.
//

#import "AddNoteViewController.h"

@interface AddNoteViewController ()
{
    UIBarButtonItem *doneButton;
    UITextView *textView;
    UIBarButtonItem *editButton;
}
@end

@implementation AddNoteViewController
@synthesize note;

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect mainScreen = [UIScreen mainScreen].bounds;
    self.view = [[UIView alloc] initWithFrame:mainScreen];
    
    textView = [[UITextView alloc] initWithFrame:mainScreen];
    textView.textColor = [UIColor blueColor];
    textView.font = [UIFont fontWithName:@"ArialMT" size:20];
    textView.backgroundColor = [UIColor lightTextColor];
    
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.title = @"New Note";
    
    if (self.note) {
        [textView setText:[self.note valueForKey:@"note"]];
        [textView setEditable:NO];
        editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed:)];
        self.navigationItem.rightBarButtonItem = editButton;
        self.navigationItem.title = textView.text;
    }
    else{
        doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
        self.navigationItem.rightBarButtonItem = doneButton;
        self.navigationItem.title = @"New Note";
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];

    [self.view addSubview:textView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fetch the devices from persistent data store
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)doneButtonPressed:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save Note"
                                                    message:@"Do you really want to save this note?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Save", nil];
    [alert show];
    
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    //NSLog(@"button index = %@",buttonIndex);
    if(buttonIndex == 0) {
        NSLog(@"OK Button is clicked");
    }
    else if(buttonIndex == 1) {
        
        if([[textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]!=0)
        {
            if(!self.note)
            {
                NSManagedObjectContext *context = [self managedObjectContext];
                NSManagedObject *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Notes" inManagedObjectContext:context];
                
                NSLog(@"%@",textView.text);
                
                [newNote setValue:textView.text forKey:@"note"];
                if([textView.text length]>30)
                {
                    [newNote setValue:[NSString stringWithFormat:@"%@...",[textView.text substringToIndex:25]] forKey:@"title"];
                }
                else
                [newNote setValue:textView.text forKey:@"title"];
                [newNote setValue:[NSDate date] forKey:@"mod_time"];
                //[newDevice setValue:self.versionTextField.text forKey:@"version"];
                //[newDevice setValue:self.companyTextField.text forKey:@"company"];
                
                NSError *error = nil;
                // Save the object to persistent store
                if (![context save:&error]) {
                    NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                }
            }
            else
            {
                [self.note setValue:textView.text forKey:@"note"];
                if([textView.text length]>30)
                {
                    [self.note setValue:[NSString stringWithFormat:@"%@...",[textView.text substringToIndex:25]] forKey:@"title"];
                }
                else
                [self.note setValue:textView.text forKey:@"title"];
                [self.note setValue:[NSDate date] forKey:@"mod_time"];
            }
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unsuccessful"
                                                            message:@"Empty Note cannot be saved!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
            [alert show];
        }
 
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)editButtonPressed:(id)sender
{
    [textView setEditable:YES];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    NSLog(@"double-tap");
    if (sender.state == UIGestureRecognizerStateRecognized) {
        // handling code
        [textView setEditable:YES];
         self.navigationItem.rightBarButtonItem = doneButton;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}



@end
