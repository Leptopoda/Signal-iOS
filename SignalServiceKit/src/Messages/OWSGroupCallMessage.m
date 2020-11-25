//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

#import "OWSGroupCallMessage.h"
#import "TSGroupThread.h"
#import <SignalCoreKit/NSDate+OWS.h>
#import <SignalServiceKit/FunctionalUtil.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface OWSGroupCallMessage ()

@property (nonatomic, getter=wasRead) BOOL read;

@property (nonatomic, nullable, readonly) NSString *eraId;
@property (nonatomic, nullable) NSArray<NSString *> *joinedMemberUuids;
@property (nonatomic, nullable) NSString *creatorUuid;
@property (nonatomic) BOOL hasEnded;

@end

#pragma mark -

@implementation OWSGroupCallMessage

- (instancetype)initWithEraId:(NSString *)eraId
            joinedMemberUuids:(NSArray<NSUUID *> *)joinedMemberUuids
                  creatorUuid:(nullable NSUUID *)creatorUuid
                       thread:(TSGroupThread *)thread
              sentAtTimestamp:(uint64_t)sentAtTimestamp
{
    self = [super initInteractionWithTimestamp:sentAtTimestamp thread:thread];

    if (!self) {
        return self;
    }

    _eraId = eraId;
    _joinedMemberUuids = [joinedMemberUuids map:^(NSUUID *uuid) { return uuid.UUIDString; }];
    _creatorUuid = creatorUuid.UUIDString;

    return self;
}

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run
// `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
             receivedAtTimestamp:(uint64_t)receivedAtTimestamp
                          sortId:(uint64_t)sortId
                       timestamp:(uint64_t)timestamp
                  uniqueThreadId:(NSString *)uniqueThreadId
                     creatorUuid:(nullable NSString *)creatorUuid
                           eraId:(nullable NSString *)eraId
                        hasEnded:(BOOL)hasEnded
               joinedMemberUuids:(nullable NSArray<NSString *> *)joinedMemberUuids
                            read:(BOOL)read
{
    self = [super initWithGrdbId:grdbId
                        uniqueId:uniqueId
               receivedAtTimestamp:receivedAtTimestamp
                            sortId:sortId
                         timestamp:timestamp
                    uniqueThreadId:uniqueThreadId];

    if (!self) {
        return self;
    }

    _creatorUuid = creatorUuid;
    _eraId = eraId;
    _hasEnded = hasEnded;
    _joinedMemberUuids = joinedMemberUuids;
    _read = read;

    return self;
}

// clang-format on

// --- CODE GENERATION MARKER

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    return [super initWithCoder:coder];
}

- (NSArray<SignalServiceAddress *> *)joinedMemberAddresses
{
    return [self.joinedMemberUuids
        map:^(NSString *uuidString) { return [[SignalServiceAddress alloc] initWithUuidString:uuidString]; }];
}

- (nullable SignalServiceAddress *)creatorAddress
{
    if (self.creatorUuid) {
        return [[SignalServiceAddress alloc] initWithUuidString:self.creatorUuid];
    } else {
        return nil;
    }
}

- (OWSInteractionType)interactionType
{
    return OWSInteractionType_Call;
}

#pragma mark - OWSReadTracking

- (uint64_t)expireStartedAt
{
    return 0;
}

- (BOOL)shouldAffectUnreadCounts
{
    return YES;
}

- (void)markAsReadAtTimestamp:(uint64_t)readTimestamp
                       thread:(TSThread *)thread
                 circumstance:(OWSReadCircumstance)circumstance
                  transaction:(SDSAnyWriteTransaction *)transaction
{

    OWSAssertDebug(transaction);

    if (self.read) {
        return;
    }

    OWSLogDebug(@"marking as read uniqueId: %@ which has timestamp: %llu", self.uniqueId, self.timestamp);

    [self anyUpdateGroupCallMessageWithTransaction:transaction
                                             block:^(OWSGroupCallMessage *groupCallMessage) {
                                                 groupCallMessage.read = YES;
                                             }];

    // Ignore `circumstance` - we never send read receipts for calls.
}

#pragma mark - Methods

- (id<ContactsManagerProtocol>)contactsManager
{
    return SSKEnvironment.shared.contactsManager;
}

- (NSString *)previewTextWithTransaction:(SDSAnyReadTransaction *)transaction
{
    if (self.hasEnded) {
        return NSLocalizedString(
            @"GROUP_CALL_ENDED_MESSAGE", @"Text in conversation view for a group call that has since ended");
    } else if (self.creatorAddress) {
        NSString *creatorDisplayName = [self participantNameForAddress:self.creatorAddress transaction:transaction];
        NSString *formatString = NSLocalizedString(@"GROUP_CALL_STARTED_MESSAGE_FORMAT",
            @"Text explaining that someone started a group call. Embeds {{call creator display name}}");
        return [NSString stringWithFormat:formatString, creatorDisplayName];
    } else {
        return NSLocalizedString(@"GROUP_CALL_SOMEONE_STARTED_MESSAGE",
            @"Text in conversation view for a group call that someone started. We don't know who");
    }
}

- (NSString *)systemTextWithTransaction:(SDSAnyReadTransaction *)transaction
{
    NSString *moreThanThreeFormat = NSLocalizedString(@"GROUP_CALL_MANY_PEOPLE_HERE_FORMAT",
        @"Text explaining that there are more than three people in the group call. Embeds {{ %1$@ participant1, %2$@ "
        @"participant2, %3$@ participantCount-2 }}");
    NSString *threeFormat = NSLocalizedString(@"GROUP_CALL_THREE_PEOPLE_HERE_FORMAT",
        @"Text explaining that there are three people in the group call. Embeds {{ %1$@ participant1, %2$@ "
        @"participant2 }}");
    NSString *twoFormat = NSLocalizedString(@"GROUP_CALL_TWO_PEOPLE_HERE_FORMAT",
        @"Text explaining that there are two people in the group call. Embeds {{ %1$@ participant1, %2$@ participant2 "
        @"}}");
    NSString *onlyCreatorFormat = NSLocalizedString(@"GROUP_CALL_STARTED_MESSAGE_FORMAT",
        @"Text explaining that someone started a group call. Embeds {{call creator display name}}");
    NSString *onlyYouFormat
        = NSLocalizedString(@"GROUP_CALL_YOU_ARE_HERE", @"Text explaining that you are in the group call.");
    NSString *onlyOneFormat = NSLocalizedString(@"GROUP_CALL_ONE_PERSON_HERE_FORMAT",
        @"Text explaining that there is one person in the group call. Embeds {member name}");
    NSString *endedString = NSLocalizedString(
        @"GROUP_CALL_ENDED_MESSAGE", @"Text in conversation view for a group call that has since ended");
    NSString *someoneString = NSLocalizedString(@"GROUP_CALL_SOMEONE_STARTED_MESSAGE",
        @"Text in conversation view for a group call that someone started. We don't know who");


    // Sort the addresses to prioritize the local user and originator, then the rest of the participants alphabetically
    NSArray<SignalServiceAddress *> *sortedAddresses = [self.joinedMemberAddresses
        sortedArrayUsingComparator:^NSComparisonResult(SignalServiceAddress *obj1, SignalServiceAddress *obj2) {
            if ([obj1 isEqualToAddress:obj2]) {
                return NSOrderedSame;
            } else if (obj1.isLocalAddress || obj2.isLocalAddress) {
                return obj1.isLocalAddress ? NSOrderedAscending : NSOrderedDescending;
            } else if ([obj1 isEqualToAddress:self.creatorAddress] || [obj2 isEqualToAddress:self.creatorAddress]) {
                return [obj1 isEqualToAddress:self.creatorAddress] ? NSOrderedAscending : NSOrderedDescending;
            } else {
                NSString *compareString1 = [self.contactsManager comparableNameForAddress:obj1 transaction:transaction];
                NSString *compareString2 = [self.contactsManager comparableNameForAddress:obj2 transaction:transaction];
                return [compareString1 compare:compareString2];
            }
        }];

    if (self.hasEnded) {
        return endedString;

    } else if (sortedAddresses.count >= 4) {
        NSString *firstName = [self participantNameForAddress:sortedAddresses[0] transaction:transaction];
        NSString *secondName = [self participantNameForAddress:sortedAddresses[1] transaction:transaction];
        NSString *remainingCount = [OWSFormat formatInt:(sortedAddresses.count - 2)];
        return [NSString stringWithFormat:moreThanThreeFormat, firstName, secondName, remainingCount];

    } else if (sortedAddresses.count == 3) {
        NSString *firstName = [self participantNameForAddress:sortedAddresses[0] transaction:transaction];
        NSString *secondName = [self participantNameForAddress:sortedAddresses[1] transaction:transaction];
        return [NSString stringWithFormat:threeFormat, firstName, secondName];

    } else if (sortedAddresses.count == 2) {
        NSString *firstName = [self participantNameForAddress:sortedAddresses[0] transaction:transaction];
        NSString *secondName = [self participantNameForAddress:sortedAddresses[1] transaction:transaction];
        return [NSString stringWithFormat:twoFormat, firstName, secondName];

    } else if (sortedAddresses.count == 1 && [sortedAddresses[0] isEqualToAddress:self.creatorAddress]) {
        NSString *name = [self participantNameForAddress:sortedAddresses[0] transaction:transaction];
        return [NSString stringWithFormat:onlyCreatorFormat, name];

    } else if (sortedAddresses.count == 1 && sortedAddresses[0].isLocalAddress) {
        return onlyYouFormat;

    } else if (sortedAddresses.count == 1) {
        NSString *name = [self participantNameForAddress:sortedAddresses[0] transaction:transaction];
        return [NSString stringWithFormat:onlyOneFormat, name];

    } else {
        return someoneString;
    }
}

- (void)updateWithHasEnded:(BOOL)hasEnded transaction:(SDSAnyWriteTransaction *)transaction
{
    [self anyUpdateGroupCallMessageWithTransaction:transaction
                                             block:^(OWSGroupCallMessage *message) {
                                                 message.hasEnded = hasEnded;
                                                 message.joinedMemberUuids = @[];
                                             }];
}

- (void)updateWithJoinedMemberUuids:(NSArray<NSUUID *> *)joinedMemberUuids
                        creatorUuid:(NSUUID *)uuid
                        transaction:(SDSAnyWriteTransaction *)transaction
{
    [self anyUpdateGroupCallMessageWithTransaction:transaction
                                             block:^(OWSGroupCallMessage *message) {
                                                 message.hasEnded = joinedMemberUuids.count == 0;
                                                 message.creatorUuid = uuid.UUIDString;
                                                 message.joinedMemberUuids = [joinedMemberUuids
                                                     map:^(NSUUID *uuid) { return uuid.UUIDString; }];
                                             }];
}

#pragma mark - Private

- (NSString *)participantNameForAddress:(SignalServiceAddress *)address transaction:(SDSAnyReadTransaction *)transaction
{
    if (address.isLocalAddress) {
        return NSLocalizedString(@"GROUP_CALL_YOU", "Text describing the local user as a participant in a group call.");
    } else {
        return [self.contactsManager displayNameForAddress:address transaction:transaction];
    }
}

@end

NS_ASSUME_NONNULL_END
