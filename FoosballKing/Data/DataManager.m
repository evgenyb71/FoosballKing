//
//  DataManager.m
//  FoosballKing
//
//  Created by Bochkarev, Eugene on 8/30/14.
//
//

#import "DataManager.h"
#import "CoreData/CoreData.h"

NSString* const PlayerEntity = @"Player";
NSString* const GameEntity = @"Game";

@interface DataManager() {
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel *_managedObjectModel;
}

@end

@implementation DataManager

+ (DataManager *)sharedInstance {
    static DataManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[DataManager alloc] init];
    });
    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initAllForCoreDataAccess];
    }
    return self;
}

#pragma mark - Core Data

- (void)initAllForCoreDataAccess {
    // 1 - model
    NSURL* modelURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource:@"Model" ofType: @"momd"]];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
    // 2 - store
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"foosball.sqlite"]];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES};
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
    NSPersistentStore *store = nil;
    store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error];
    if (!store) {
        NSLog(@"Database error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    // 3 - context
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator: _persistentStoreCoordinator];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initWithDemoItemsIfNeeded];
    });
}

- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
    return basePath;
}

-(BOOL)persistCoreDataChanges {
	NSError *anyError;
    if (_managedObjectContext) {
        if ([_managedObjectContext save:&anyError] == YES)
            return YES;
        // error - rollback
        NSLog(@"Persist Error: %@, %@", anyError, [anyError userInfo]);
        [_managedObjectContext rollback];
    }
    return NO;
}

// see if no records - add some default values
- (void)initWithDemoItemsIfNeeded {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:PlayerEntity inManagedObjectContext:_managedObjectContext]];
    [request setIncludesSubentities:NO];
    NSError *err;
    NSUInteger count = [_managedObjectContext countForFetchRequest:request error:&err];
    if (count > 0)
        return;
    Player *playerAmos = [self createPlayerRecord:@"Amos"];
    Player *playerDiego = [self createPlayerRecord:@"Diego"];
    Player *playerJoel = [self createPlayerRecord:@"Joel"];
    Player *playerTim = [self createPlayerRecord:@"Tim"];
    
    [self createGameRecordPlayer1:playerAmos scoreForPlayer1:4 player2:playerDiego scoreForPlayer2:5];
    [self createGameRecordPlayer1:playerAmos scoreForPlayer1:1 player2:playerDiego scoreForPlayer2:5];
    [self createGameRecordPlayer1:playerAmos scoreForPlayer1:2 player2:playerDiego scoreForPlayer2:5];
    [self createGameRecordPlayer1:playerAmos scoreForPlayer1:0 player2:playerDiego scoreForPlayer2:5];
    [self createGameRecordPlayer1:playerAmos scoreForPlayer1:6 player2:playerDiego scoreForPlayer2:5];
    [self createGameRecordPlayer1:playerAmos scoreForPlayer1:5 player2:playerDiego scoreForPlayer2:2];
    [self createGameRecordPlayer1:playerAmos scoreForPlayer1:4 player2:playerDiego scoreForPlayer2:0];
    [self createGameRecordPlayer1:playerJoel scoreForPlayer1:4 player2:playerDiego scoreForPlayer2:5];
    [self createGameRecordPlayer1:playerTim scoreForPlayer1:4 player2:playerAmos scoreForPlayer2:5];
    [self createGameRecordPlayer1:playerTim scoreForPlayer1:5 player2:playerAmos scoreForPlayer2:2];
    [self createGameRecordPlayer1:playerAmos scoreForPlayer1:3 player2:playerTim scoreForPlayer2:5];
    [self createGameRecordPlayer1:playerAmos scoreForPlayer1:5 player2:playerTim scoreForPlayer2:3];
    [self createGameRecordPlayer1:playerAmos scoreForPlayer1:5 player2:playerJoel scoreForPlayer2:4];
    [self createGameRecordPlayer1:playerJoel scoreForPlayer1:5 player2:playerTim scoreForPlayer2:2];
}

#pragma mark - public access
- (Player *)createPlayerRecord:(NSString *)name {
	Player *player = (Player *)[NSEntityDescription insertNewObjectForEntityForName:PlayerEntity inManagedObjectContext:_managedObjectContext];
    player.name = name;
    player.playerId =  [[NSUUID UUID] UUIDString];
    if ([self persistCoreDataChanges] == YES) {
        return player;
    }
    return nil;
}

- (Game *)createGameRecordPlayer1:(Player *)player1 scoreForPlayer1:(NSInteger)score1 player2:(Player *)player2 scoreForPlayer2:(NSInteger)score2 {
	Game *game = (Game *)[NSEntityDescription insertNewObjectForEntityForName:GameEntity inManagedObjectContext:_managedObjectContext];
    game.date = [NSDate date];
    game.gameId =  [[NSUUID UUID] UUIDString];
    game.player1Id = player1.playerId;
    game.player2Id = player1.playerId;
    game.player1Score = [NSNumber numberWithInteger:score1];
    game.player2Score = [NSNumber numberWithInteger:score2];
    
    if ([self persistCoreDataChanges] == YES) {
        return game;
    }
    return nil;
}

@end
