//
//  FirstViewController.m
//  FoosballKing
//
//  Created by Bochkarev, Eugene on 8/30/14.
//
//

#import "FirstViewController.h"
#import "AddPlayerViewController.h"

@interface FirstViewController () <DataManagerDelegateProtocol> {
    NSInteger _selectedIndex;
}

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [DataManager sharedInstance].delegate = self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AddPlayerViewController *vc = [segue destinationViewController];
    if ([[segue identifier] isEqualToString:@"AddNewPlayer"]) {
        vc.addMode = YES;
        vc.player = nil;
        return;
    }
    if ([[segue identifier] isEqualToString:@"EditPlayer"]) {
        vc.addMode = NO;
        vc.player = [DataManager sharedInstance].ratedPlayers[_selectedIndex];
        return;
    }
}

#pragma mark - UITableViewDelegate

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        self.addButton.enabled = NO;
    } else {
        self.addButton.enabled = YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Player *player = [DataManager sharedInstance].ratedPlayers[indexPath.row];
        if ([[DataManager sharedInstance] deletePlayerRecord:player] == NO) {
            [Utils showSimpleError:@"Cannot remove a player with recorded games!"];
            return;
        }
    }
}

#pragma mark - DataManagerDelegateProtocol

- (void)dataManagerPlayerListUpdatedEvent {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

// each deal is a section with 1 row
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[DataManager sharedInstance].ratedPlayers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SimpleInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    Player *player = [DataManager sharedInstance].ratedPlayers[indexPath.row];
    cell.textLabel.text = player.name;
    cell.detailTextLabel.text = [player.score stringValue];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"EditPlayer" sender:self];
}

@end
