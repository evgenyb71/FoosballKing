//
//  AppDelegate.h
//  FoosballKing
//
//  Created by Bochkarev, Eugene on 8/30/14.
//
//

/*
 Foosball King - Simple foosbal rating system.
 
 Feature set for v1:
 - local CoreData:
    - Players table
        - Simple cell.
    - Games table
 - 2 Tabs app
    - Players view: Rating, Add/edit/delete
    - Games view: History, add/edit
 -
 
 Feature set for v2:
 - Delete game? (not in requirements!)
 - Use NSNotification instead of delegate for DataManager updates
 - Search for players
 - Custom Player Cell with more info
 - Search for games
 - Support Notes for a player? (research)
 - Support Notes for a game? (research)
 - List of all games -> Player Info
 - Cloud storage
    - support server APIs for:
        - get players
        - get players image
        - submit players
        - get games
        - submit games
        - submit players image
 - Settings
 - Support images for a game? (Research)
 - Notification on a ratings change / new game
 
 
 Open Items:
 - We can use this system:  
    - Win:  5
    - Draw: 2
    - Loss: 1
    = Score field would be Transient - not stored/persistent, but calculated on fly
 For v1, I just use Score field that summarize all goals.
 
 */


#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
