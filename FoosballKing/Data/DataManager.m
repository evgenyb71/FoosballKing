//
//  DataManager.m
//  FoosballKing
//
//  Created by Bochkarev, Eugene on 8/30/14.
//
//

#import "DataManager.h"
#import "CoreData/CoreData.h"

NSString * const DMPlayerListUpdateNotification = @"DMPlayerListUpdateNotification";
NSString * const DMPGameListUpdateNotification = @"DMPGameListUpdateNotification";

NSString* const PlayerEntity = @"Player";
NSString* const GameEntity = @"Game";

@interface DataManager() {
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel *_managedObjectModel;
    
    NSArray *_ratedPlayers; // players, sorted by score
    NSArray *_gamesByDate; // games, sorted by date
    NSMutableDictionary *_playersById; // O(1) search for a player by Id
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
    
    [self initWithDemoItemsIfNeeded];
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
    NSError *err;
    NSUInteger count = [_managedObjectContext countForFetchRequest:request error:&err];
    if (count > 0)
        return;
    request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:GameEntity inManagedObjectContext:_managedObjectContext]];
    count = [_managedObjectContext countForFetchRequest:request error:&err];
    if (count > 0)
        return;
    // if we don't have any recotds in both DBs, recreate these:
    Player *playerAmos = [self createPlayerRecordInternal:@"Amos"];
    Player *playerDiego = [self createPlayerRecordInternal:@"Diego"];
    Player *playerJoel = [self createPlayerRecordInternal:@"Joel"];
    Player *playerTim = [self createPlayerRecordInternal:@"Tim"];
    [self createPlayerRecordInternal:@"Eugene"]; // no games yet!
    
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

- (void)clearAllInMemoryPlayerLists {
    _ratedPlayers = nil;
    _playersById = nil;
    if ([self.delegate respondsToSelector:@selector(dataManagerPlayerListUpdatedEvent)]) {
        [self.delegate dataManagerPlayerListUpdatedEvent];
    }
    // notify observers that are not active now
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DMPlayerListUpdateNotification object:nil];
    });
}

- (void)clearAllInMemoryGamesLists {
    _gamesByDate = nil;
    // we need to reload players too
    _ratedPlayers = nil;
    _playersById = nil;
    if ([self.delegate respondsToSelector:@selector(dataManagerGameListUpdatedEvent)]) {
        [self.delegate dataManagerGameListUpdatedEvent];
    }
    if ([self.delegate respondsToSelector:@selector(dataManagerPlayerListUpdatedEvent)]) {
        [self.delegate dataManagerPlayerListUpdatedEvent];
    }
    // notify observers that are not active now
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DMPGameListUpdateNotification object:nil];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:DMPlayerListUpdateNotification object:nil];
    });
}

- (void)buildRatedPlayersList {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    // look for all players
    [request setEntity:[NSEntityDescription entityForName:PlayerEntity inManagedObjectContext:_managedObjectContext]];
    // sort them by score
	NSSortDescriptor *sortDescScore = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
	NSSortDescriptor *sortDescName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = @[sortDescScore, sortDescName];
	[request setSortDescriptors:sortDescriptors];
	NSError* error = nil;
	_ratedPlayers = [_managedObjectContext executeFetchRequest: request error: &error];

    // rebuild quick access hashtable
    _playersById = [NSMutableDictionary dictionaryWithCapacity:[_ratedPlayers count]];
    for (Player *player in _ratedPlayers) {
        [_playersById setObject:player forKey:player.playerId];
    }
}

- (void)buildGamesByDateList {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    // look for all players
    [request setEntity:[NSEntityDescription entityForName:GameEntity inManagedObjectContext:_managedObjectContext]];
    // sort them by score
	NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	NSArray *sortDescriptors = @[sortDesc];
	[request setSortDescriptors:sortDescriptors];
	NSError* error = nil;
	_gamesByDate = [_managedObjectContext executeFetchRequest: request error: &error];
}

#pragma mark - public access
- (Player *)findThePlayer:(NSString *)name {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:PlayerEntity inManagedObjectContext:_managedObjectContext]];
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name = %@)", name];
    [request setPredicate:pred];

    NSError* error = nil;
    NSArray* result = [_managedObjectContext executeFetchRequest:request error:&error];
    if (result && [result count] == 1) {
        return (Player *)[result objectAtIndex:0];
    }
    return nil;
}

- (Player *)createPlayerRecordInternal:(NSString *)name {
	Player *player = (Player *)[NSEntityDescription insertNewObjectForEntityForName:PlayerEntity inManagedObjectContext:_managedObjectContext];
    player.name = name;
    player.playerId =  [[NSUUID UUID] UUIDString];
    if ([self persistCoreDataChanges] == YES) {
        return player;
    }
    return nil;
}

- (Player *)createPlayerRecord:(NSString *)name {
    // check if player exists
    Player *player = [self findThePlayer:name];
    if (player)
        return nil;
	player = [self createPlayerRecordInternal:name];
    if (player) {
        [self clearAllInMemoryPlayerLists];
    }
    return player;
}

- (BOOL)updatePlayerRecord:(Player *)player1 newName:(NSString *)newName {
    Player *player = [self findThePlayer:newName];
    if (player) {
        return NO; // we already have player with new name
    }
    player1.name = newName;
    if ([self persistCoreDataChanges] == NO) {
        return NO;
    }
    [self clearAllInMemoryPlayerLists];
    return YES;
}

- (BOOL)deletePlayerRecord:(Player *)player {
    // first, let's see if we have any games for this player
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:GameEntity inManagedObjectContext:_managedObjectContext]];
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(player1Id = %@) OR (player2Id = %@)", player.playerId, player.playerId];
    [request setPredicate:pred];
    
    NSError *err;
    NSUInteger count = [_managedObjectContext countForFetchRequest:request error:&err];
    if (count > 0)
        return NO;

    // No games - we're Ok to delete
    [_managedObjectContext deleteObject:player];
    if ([self persistCoreDataChanges] == NO) {
        return NO;
    }
    [self clearAllInMemoryPlayerLists];
    return YES;
}

- (Game *)createGameRecordPlayer1:(Player *)player1 scoreForPlayer1:(NSInteger)score1 player2:(Player *)player2 scoreForPlayer2:(NSInteger)score2
{
    return [self createGameRecordForDateInternal:[NSDate date] player1:player1 scoreForPlayer1:score1 player2:player2 scoreForPlayer2:score2];
}

- (Game *)createGameRecordForDateInternal:(NSDate *)date player1:(Player *)player1 scoreForPlayer1:(NSInteger)score1 player2:(Player *)player2 scoreForPlayer2:(NSInteger)score2 {
	Game *game = (Game *)[NSEntityDescription insertNewObjectForEntityForName:GameEntity inManagedObjectContext:_managedObjectContext];
    game.date = date;
    game.gameId =  [[NSUUID UUID] UUIDString];
    game.player1Id = player1.playerId;
    game.player1Score = [NSNumber numberWithInteger:score1];
    
    game.player2Id = player2.playerId;
    game.player2Score = [NSNumber numberWithInteger:score2];
    
    // update scores for players
    player1.score = [NSNumber numberWithInteger: [player1.score integerValue] + score1];
    player2.score = [NSNumber numberWithInteger: [player2.score integerValue] + score2];
    
    if ([self persistCoreDataChanges] == YES) {
        return game;
    }
    return nil;
}

- (Game *)createGameRecordForDate:(NSDate *)date player1:(Player *)player1 scoreForPlayer1:(NSInteger)score1 player2:(Player *)player2 scoreForPlayer2:(NSInteger)score2 {
    Game *game = [self createGameRecordForDateInternal:date player1:player1 scoreForPlayer1:score1 player2:player2 scoreForPlayer2:score2];
    if (game != nil) {
        [self clearAllInMemoryGamesLists];
    }
    return game;
}

- (BOOL)updateGameRecord:(Game *)game date:(NSDate *)date player1:(Player *)player1 scoreForPlayer1:(NSInteger)score1 player2:(Player *)player2 scoreForPlayer2:(NSInteger)score2
{
    if ([game.player1Id isEqualToString:player1.playerId] == NO) {
        // subtract score from tjhe player we had before
        Player *oldPlayer = [self playerById:game.player1Id];
        oldPlayer.score = [NSNumber numberWithInteger: [oldPlayer.score integerValue] - [game.player1Score integerValue]];
        player1.score = [NSNumber numberWithInteger: [player1.score integerValue] + score1];
    } else {
        player1.score = [NSNumber numberWithInteger: [player1.score integerValue] - [game.player1Score integerValue] + score1];
    }
    if ([game.player2Id isEqualToString:player2.playerId] == NO) {
        // subtract score from tjhe player we had before
        Player *oldPlayer = [self playerById:game.player2Id];
        oldPlayer.score = [NSNumber numberWithInteger: [oldPlayer.score integerValue] - [game.player2Score integerValue]];
    } else {
        player2.score = [NSNumber numberWithInteger: [player2.score integerValue] - [game.player2Score integerValue] + score2];
    }
    game.date = date;

    game.player1Id = player1.playerId;
    game.player1Score = [NSNumber numberWithInteger:score1];
    
    game.player2Id = player2.playerId;
    game.player2Score = [NSNumber numberWithInteger:score2];
    
    if ([self persistCoreDataChanges] == NO) {
        return NO;
    }
    [self clearAllInMemoryGamesLists];
    return YES;
}

#pragma mark - data access wrappers
- (NSArray *)ratedPlayers {
    if (_ratedPlayers == nil) {
        [self buildRatedPlayersList];
    }
    return _ratedPlayers;
}

- (NSArray *)gamesByDate {
    if (_gamesByDate == nil) {
        [self buildGamesByDateList];
    }
    return _gamesByDate;
}

- (Player *)playerById:(NSString *)playerId {
    if (_playersById == nil) {
        [self buildRatedPlayersList];
    }
    return [_playersById objectForKey:playerId];
}


#pragma mark - potential network code

/*
 
 // getting data from network
 
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:dataURL];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    [[urlSession dataTaskWithURL:url
               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                   dispatch_async(dispatch_get_main_queue(), ^{
                       // update on Main
                       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                   });
                   if (!error) {
                       [self handleDataReceived:data response:response];
                   } else {
                       [self notifyOnError:error];
                   }
               }] resume];
}

// process data:
 
- (void)handleDataReceived:(NSData *)data response:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode != 200) {
        NSError *error = [NSError errorWithDomain:@"NETWORK" code:httpResponse.statusCode userInfo:nil];
        [self notifyOnError:error];
        return;
    }
    
    // convert JSON response to dictionary or array
    NSError *jsonError;
    id dataJSON = [NSJSONSerialization JSONObjectWithData:data
                                                  options:NSJSONReadingAllowFragments
                                                    error:&jsonError];
    if (jsonError) {
        [self notifyOnError:jsonError];
        return;
    }
    // parse Array or Dictionary
}

 */

@end
