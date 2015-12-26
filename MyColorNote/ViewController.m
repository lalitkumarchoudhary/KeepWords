//
//  ViewController.m
//  MyColorNote
//
//  Created by Lalit Choudhary on 22/04/15.
//  Copyright (c) 2015 Lalit Choudhary. All rights reserved.
//

#import "ViewController.h"
#import "AddNoteViewController.h"
#import <CoreData/CoreData.h>
#import "TableViewCell.h"

@interface ViewController ()
{
    UITableView *tableView;
    UIBarButtonItem *addButton;
    UIBarButtonItem *optionButton;
    NSDateFormatter *formatter;
    UISearchBar *searchBar;
    int search;
    NSMutableString *searchStr;
}
@property (strong) NSMutableArray *notes;
@property (strong) NSMutableArray *searchResults;
@end

@implementation ViewController

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
    // Do any additional setup after loading the view, typically from a nib.
    CGRect mainScreen = [UIScreen mainScreen].bounds;
    self.view = [[UIView alloc] initWithFrame:mainScreen];
    
    tableView = [[UITableView alloc] initWithFrame:mainScreen style:UITableViewStylePlain];
    
    addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.title = @"ColorNote";
    optionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonPressed:)];
    self.navigationItem.leftBarButtonItem = optionButton;
    tableView.dataSource = self;
    tableView.delegate = self;
    //tableView.style = UITableViewStyleGrouped;
    
    [self.view addSubview:tableView];
    
    formatter = [[NSDateFormatter alloc] init];
    formatter.doesRelativeDateFormatting = YES;
    formatter.locale = [NSLocale currentLocale];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    
    searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .5; //seconds
    //lpgr.delegate = self;
    [tableView addGestureRecognizer:lpgr];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Notes"];
    
    NSError *error = nil;
    self.notes = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    NSSortDescriptor *titleSorter= [[NSSortDescriptor alloc] initWithKey:@"mod_time" ascending:NO];
    
    [self.notes sortUsingDescriptors:[NSArray arrayWithObject:titleSorter]]
    ;
   
     NSLog(@"Your Error - %@",error.description);
    
    [tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.notes.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

//    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"Cell"];
//    if(cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
//    }
    
    TableViewCell *cell = (TableViewCell*)[aTableView dequeueReusableCellWithIdentifier:@"MycellIdentifier"];
    
    if(cell == nil)
    {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MycellIdentifier"];
        
    }
    
    // Configure the cell...
    NSManagedObject *note = [self.notes objectAtIndex:indexPath.row];
    
    NSDate *date = [note valueForKey:@"mod_time"];
    
    NSString *dateString = [formatter stringFromDate:date];
    
    cell.title.text = [note valueForKey:@"title"];
    cell.time.text = dateString;
    return cell;
}


- (void)tableView:(UITableView *)bTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AddNoteViewController *noteVC = [AddNoteViewController new];
    NSManagedObject *selectedNote = [self.notes objectAtIndex:[[bTableView indexPathForSelectedRow] row]];
    noteVC.note = selectedNote;

    [self.navigationController pushViewController:noteVC animated:NO];
}

- (void)addButtonPressed:(id)sender
{
    AddNoteViewController *addNoteVC = [AddNoteViewController new];
    [self.navigationController pushViewController:addNoteVC animated:NO];
    
}

-(NSArray *)tableView:(UITableView *)aTableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //insert your editAction here
        AddNoteViewController *noteVC = [AddNoteViewController new];
        noteVC.note = [self.notes objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:noteVC animated:NO];
        
    }];
    editAction.backgroundColor = [UIColor lightGrayColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //insert your deleteAction here
        [context deleteObject:[self.notes objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        // Remove device from table view
        [self.notes removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction,editAction];
}


//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}
//
//
//- (void)tableView:(UITableView *)cTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSManagedObjectContext *context = [self managedObjectContext];
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete object from database
//        [context deleteObject:[self.notes objectAtIndex:indexPath.row]];
//        
//        NSError *error = nil;
//        if (![context save:&error]) {
//            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
//            return;
//        }
//        
//        // Remove device from table view
//        [self.notes removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//}

- (void)searchButtonPressed:(id)sender
{
    if(search==0)
    {
        self.navigationItem.titleView = searchBar;
        search++;
    }
    else
    {
        self.navigationItem.titleView = nil;
        search = 0;
        
    }
    
}


-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:tableView];
    
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:p];
    
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        // get the cell at indexPath (the one you long pressed)
        TableViewCell *cell = (TableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        // do stuff with the cell
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:cell.title.text
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Show",@"Edit",@"Delete",nil];
        [alert show];
    }
}


//- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar{
//    
//    searchStr = [NSMutableString stringWithFormat:@"%@",aSearchBar.text];
//    
//    self.searchResults = (NSMutableArray *)[self.notes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(note == %@)", searchStr]];
//    
//    [tableView reloadData];
//}

//-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//    
//        autocompleteTableView.hidden = NO;
//        if (filteredTableData == nil)
//            filteredTableData = [[NSMutableArray alloc] init];
//        else
//            [filteredTableData removeAllObjects];
//        
//        for (NSString* string in masterCityList)
//        {
//            NSRange nameRange = [string rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
//            if(nameRange.location != NSNotFound)
//            {
//                [filteredTableData addObject:string];
//            }
//        }
//    }
//    [tableView reloadData];
//}

//-(NSUInteger)differentDates
//{
//    
//    NSMutableArray *diffDateArray = nil;
//    NSUInteger count = [self.notes count];
//    
//    for(int i=0;i<count;i++)
//    {
//        
//        [diffDateArray addObject:[formatter stringFromDate:[[self.notes objectAtIndex:i] valueForKey:@"mod_time"]]];
//        NSLog(@"%@",[diffDateArray objectAtIndex:i]);
//    }
//    NSSet *uniqueDate = [NSSet setWithArray:diffDateArray];
//    NSLog(@"%lu",(unsigned long)[diffDateArray count]);
//    return [uniqueDate count];
//}
@end
