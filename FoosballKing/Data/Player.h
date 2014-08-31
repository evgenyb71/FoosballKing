//
//  Player.h
//  FoosballKing
//
//  Created by Bochkarev, Eugene on 8/30/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Player : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSString * playerId;
@property (nonatomic, retain) NSNumber * score;

@end
