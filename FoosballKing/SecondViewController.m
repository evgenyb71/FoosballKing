//
//  SecondViewController.m
//  FoosballKing
//
//  Created by Bochkarev, Eugene on 8/30/14.
//
//

#import "SecondViewController.h"
#import "GameInfoViewController.h"

@interface SecondViewController () <DataManagerDelegateProtocol> {
    NSInteger _selectedIndex;
}

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [DataManager sharedInstance].delegate = self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    GameInfoViewController *vc = [segue destinationViewController];
    if ([[segue identifier] isEqualToString:@"AddNewGame"]) {
        vc.addMode = YES;
        vc.game = nil;
        return;
    }
    if ([[segue identifier] isEqualToString:@"EditGame"]) {
        vc.addMode = NO;
        vc.game = [DataManager sharedInstance].gamesByDate[_selectedIndex];
        return;
    }
}

#pragma mark - DataManagerDelegateProtocol

- (void)dataManagerGameListUpdatedEvent {
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
    return [[DataManager sharedInstance].gamesByDate count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SimpleSubCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    Game *game = [DataManager sharedInstance].gamesByDate[indexPath.row];
    Player *player1 = [[DataManager sharedInstance] playerById:game.player1Id];
    Player *player2 = [[DataManager sharedInstance] playerById:game.player2Id];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ : %d --- %@ : %d", player1.name, [game.player1Score integerValue], player2.name, [game.player2Score integerValue]];
//    NSString *winPlayer;
//    if ([game.player1Score integerValue] > [game.player2Score integerValue]) {
//        winPlayer = [NSString stringWithFormat:@"%@ won", player1.name];
//    } else if ([game.player1Score integerValue] < [game.player2Score integerValue]) {
//        winPlayer = [NSString stringWithFormat:@"%@ won", player2.name];
//    } else {
//        winPlayer = @"Draw";
//    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@. Date: %@", winPlayer, [dateFormatter stringFromDate:game.date]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:game.date]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"EditGame" sender:self];
}

@end
