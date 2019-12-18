//
//  RCDDataStatistics.m
//  SealTalk
//
//  Created by Sin on 2019/10/15.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDDataStatistics.h"
#import "RCDCommonString.h"
#import <objc/runtime.h>
#import <mach/mach.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>
#import <sys/sysctl.h>

#import <QuartzCore/QuartzCore.h>
#import <SystemConfiguration/SystemConfiguration.h>

static NSString *kInterfaceWiFi = @"en0";
static NSString *kInterfaceWWAN = @"pdp_ip0";
static NSString *kInterfaceNone = @"";

#define kDefaultDataHistorySize 300
#define kTimerInterval 2

@interface NetworkBandwidth : NSObject
@property (nonatomic, copy) NSString *interface;
@property (nonatomic, strong) NSDate *timestamp;

@property (nonatomic, assign) float sent;
@property (nonatomic, assign) uint64_t totalWiFiSent;
@property (nonatomic, assign) uint64_t totalWWANSent;
@property (nonatomic, assign) float received;
@property (nonatomic, assign) uint64_t totalWiFiReceived;
@property (nonatomic, assign) uint64_t totalWWANReceived;
@end

@implementation NetworkBandwidth

@end

@interface RCDDataStatistics ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) int fps;

@property (nonatomic, copy) NSString *currentInterface;
@property (nonatomic, strong) NSMutableArray *networkBandwidthHistory;
@property (nonatomic, assign) CGFloat currentMaxSentBandwidth;
@property (nonatomic, assign) CGFloat currentMaxReceivedBandwidth;
@property (nonatomic, assign) NSUInteger maxSentBandwidthTimes;
@property (nonatomic, assign) NSUInteger maxReceivedBandwidthTimes;
@property (nonatomic, assign) NSUInteger bandwidthHistorySize;
@property (nonatomic, assign) SCNetworkReachabilityRef reachability;
@end

@implementation RCDDataStatistics

+ (void)load {
    [self sharedInstance];
}

+ (instancetype)sharedInstance {
    static RCDDataStatistics *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        BOOL open = [self isOpen];
        if (open) {
            [self start];
        }
        self.networkBandwidthHistory = [NSMutableArray new];
        self.bandwidthHistorySize = 100;
    }
    return self;
}

- (void)notify {
    if ([self isOpen]) {
        [self start];
    } else {
        [self stop];
    }
}

- (BOOL)isOpen {
    return [DEFAULTS boolForKey:RCDDebugDataStatisticsKey];
}

- (void)start {
    [self enableTimer];
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    self.link.frameInterval = 2;
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
- (void)stop {
    [self disableTimer];
    if (self.link) {
        [self.link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [self.link invalidate];
    }
}

- (void)enableTimer {
    [self disableTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval
                                                  target:self
                                                selector:@selector(dataStatistics)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)disableTimer {
    if (self.timer && [self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)dataStatistics {
    NetworkBandwidth *bandWidth = [self getNetworkBandwidth];
    [self pushNetworkBandwidth:bandWidth];
    NSString *log = [NSString
        stringWithFormat:
            @"{\"cpuUsage\":%@,\"cpuUsageOfOS\":%@,\"memory\":%@,\"fps\":%@,\"netSend\":%@,\"netReceive\":%@}",
            @([self cpuUsage]), @([self cpuUsageOfOS]), @([self appUsesMemoryBytes]), @(self.fps),
            @(bandWidth.sent / kTimerInterval), @(bandWidth.received / kTimerInterval)];
    NSLog(@"statistics form: %@", log);
}

#pragma mark - private method
- (float)cpuUsage {
    thread_act_array_t threads;
    mach_msg_type_number_t threadCount = 0;
    const task_t thisTask = mach_task_self();
    kern_return_t kr = task_threads(thisTask, &threads, &threadCount);
    if (kr != KERN_SUCCESS) {
        return 0;
    }

    integer_t cpuUsage = 0;
    for (int i = 0; i < threadCount; i++) {
        thread_info_data_t threadInfo;
        thread_basic_info_t threadBasicInfo;
        mach_msg_type_number_t threadInfoCount = THREAD_INFO_MAX;

        if (thread_info(threads[i], THREAD_BASIC_INFO, threadInfo, &threadInfoCount) == KERN_SUCCESS) {
            threadBasicInfo = (thread_basic_info_t)threadInfo;
            if (!(threadBasicInfo->flags & TH_FLAGS_IDLE)) {
                cpuUsage += threadBasicInfo->cpu_usage;
            }
        }
    }

    assert(vm_deallocate(thisTask, (vm_address_t)threads, threadCount * sizeof(thread_t)) == KERN_SUCCESS);

    return cpuUsage / 10.0f;
}

- (float)cpuUsageOfOS {
    float cpuUsage = 0.0;
    kern_return_t kr;
    mach_msg_type_number_t count;
    static host_cpu_load_info_data_t previous_info = {0, 0, 0, 0};
    host_cpu_load_info_data_t info;

    count = HOST_CPU_LOAD_INFO_COUNT;

    kr = host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, (host_info_t)&info, &count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }

    natural_t user = info.cpu_ticks[CPU_STATE_USER] - previous_info.cpu_ticks[CPU_STATE_USER];
    natural_t nice = info.cpu_ticks[CPU_STATE_NICE] - previous_info.cpu_ticks[CPU_STATE_NICE];
    natural_t system = info.cpu_ticks[CPU_STATE_SYSTEM] - previous_info.cpu_ticks[CPU_STATE_SYSTEM];
    natural_t idle = info.cpu_ticks[CPU_STATE_IDLE] - previous_info.cpu_ticks[CPU_STATE_IDLE];
    natural_t total = user + nice + system + idle;
    previous_info = info;

    double molecular = (user + nice + system) * 100.0;
    natural_t denominator = total;
    if (molecular > 0 && denominator > 0) {
        cpuUsage = molecular / denominator;
    }

    return cpuUsage;
}

- (NSUInteger)appUsesMemoryBytes {
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t)&vmInfo, &count);
    if (kernelReturn == KERN_SUCCESS) {
        return (NSUInteger)vmInfo.phys_footprint;
    } else {
        return 0;
    }
}

- (void)tick:(CADisplayLink *)link {
    if (self.lastTime == 0) {
        self.lastTime = link.timestamp;
        return;
    }
    self.count += link.frameInterval;
    NSTimeInterval delta = link.timestamp - self.lastTime;
    if (delta < 1)
        return;
    self.lastTime = link.timestamp;
    float fps = self.count / delta;
    self.count = 0;
    //    self.fps = (int)round(fps / 60.0);
    self.fps = (int)roundf(fps);
}

- (NetworkBandwidth *)getNetworkBandwidth {
    self.currentInterface = [self internetInterface];
    NetworkBandwidth *bandwidth = [[NetworkBandwidth alloc] init];
    bandwidth.timestamp = [NSDate date];
    bandwidth.interface = self.currentInterface;

    int mib[] = {CTL_NET, PF_ROUTE, 0, 0, NET_RT_IFLIST2, 0};

    size_t len;
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        NSLog(@"sysctl failed (1)");
        return bandwidth;
    }

    char *buf = malloc(len);
    if (!buf) {
        NSLog(@"malloc() for buf has failed.");
        return bandwidth;
    }

    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        NSLog(@"sysctl failed (2)");
        free(buf);
        return bandwidth;
    }
    char *lim = buf + len;
    char *next = NULL;
    for (next = buf; next < lim;) {
        struct if_msghdr *ifm = (struct if_msghdr *)next;
        next += ifm->ifm_msglen;

/* iOS does't include <net/route.h>, so we define our own macros. */
#define RTM_IFINFO2 0x12
        if (ifm->ifm_type == RTM_IFINFO2)
#undef RTM_IFINFO2
        {
            struct if_msghdr2 *if2m = (struct if_msghdr2 *)ifm;

            char ifnameBuf[IF_NAMESIZE];
            if (!if_indextoname(ifm->ifm_index, ifnameBuf)) {
                NSLog(@"if_indextoname() has failed.");
                continue;
            }
            NSString *ifname = [NSString stringWithCString:ifnameBuf encoding:NSASCIIStringEncoding];

            if ([ifname isEqualToString:kInterfaceWiFi]) {
                bandwidth.totalWiFiSent += if2m->ifm_data.ifi_obytes;
                bandwidth.totalWiFiReceived += if2m->ifm_data.ifi_ibytes;
            } else if ([ifname isEqualToString:kInterfaceWWAN]) {
                bandwidth.totalWWANSent += if2m->ifm_data.ifi_obytes;
                bandwidth.totalWWANReceived += if2m->ifm_data.ifi_ibytes;
            }
        }
    }

    if (self.networkBandwidthHistory.count > 0) {
        NetworkBandwidth *prevBandwidth = [self.networkBandwidthHistory lastObject];

        // Make sure previous bandwidth was at the same interface and measured during last second.
        if ([prevBandwidth.interface isEqualToString:self.currentInterface]) {
            if ([self.currentInterface isEqualToString:kInterfaceWiFi]) {
                bandwidth.sent = bandwidth.totalWiFiSent - prevBandwidth.totalWiFiSent;
                bandwidth.received = bandwidth.totalWiFiReceived - prevBandwidth.totalWiFiReceived;
            } else if ([self.currentInterface isEqualToString:kInterfaceWWAN]) {
                bandwidth.sent = bandwidth.totalWWANSent - prevBandwidth.totalWWANSent;
                bandwidth.received = bandwidth.totalWWANReceived - prevBandwidth.totalWWANReceived;
            }

            [self adjustMaxBandwidth:bandwidth];
        }
    }

    free(buf);
    return bandwidth;
}

- (void)adjustMaxBandwidth:(NetworkBandwidth *)bandwidth {
    if (bandwidth.sent > self.currentMaxSentBandwidth) {
        self.currentMaxSentBandwidth = bandwidth.sent;
        self.maxSentBandwidthTimes = 0;
    }
    if (bandwidth.received > self.currentMaxReceivedBandwidth) {
        self.currentMaxReceivedBandwidth = bandwidth.received;
        self.maxReceivedBandwidthTimes = 0;
    }

    self.maxSentBandwidthTimes++;
    self.maxReceivedBandwidthTimes++;

    if (self.maxSentBandwidthTimes > self.bandwidthHistorySize) {
        CGFloat newMaxSent = 0;
        for (NetworkBandwidth *b in self.networkBandwidthHistory) {
            newMaxSent = MAX(newMaxSent, b.sent);
        }
        self.currentMaxSentBandwidth = newMaxSent;
        self.maxSentBandwidthTimes = 0;

        CGFloat newMaxReceived = 0;
        for (NetworkBandwidth *b in self.networkBandwidthHistory) {
            newMaxReceived = MAX(newMaxReceived, b.received);
        }
        self.currentMaxReceivedBandwidth = newMaxReceived;
        self.maxReceivedBandwidthTimes = 0;
    }
}

- (NSString *)internetInterface {
    if (!self.reachability) {
        [self initReachability];
    }

    if (!self.reachability) {
        NSLog(@"cannot initialize reachability.");
        return kInterfaceNone;
    }

    SCNetworkReachabilityFlags flags;
    if (!SCNetworkReachabilityGetFlags(self.reachability, &flags)) {
        NSLog(@"failed to retrieve reachability flags.");
        return kInterfaceNone;
    }

    if ((flags & kSCNetworkFlagsReachable) && (!(flags & kSCNetworkReachabilityFlagsIsWWAN))) {
        return kInterfaceWiFi;
    }

    if ((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsWWAN)) {
        return kInterfaceWWAN;
    }

    return kInterfaceNone;
}

- (void)initReachability {
    if (!self.reachability) {
        struct sockaddr_in hostAddress;
        bzero(&hostAddress, sizeof(hostAddress));
        hostAddress.sin_len = sizeof(hostAddress);
        hostAddress.sin_family = AF_INET;

        self.reachability =
            SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&hostAddress);

        if (!self.reachability) {
            NSLog(@"reachability create has failed.");
            return;
        }

        BOOL result;
        SCNetworkReachabilityContext context = {0, (__bridge void *)self, NULL, NULL, NULL};

        result = SCNetworkReachabilitySetCallback(self.reachability, reachabilityCallback, &context);
        if (!result) {
            NSLog(@"error setting reachability callback.");
            return;
        }

        result =
            SCNetworkReachabilityScheduleWithRunLoop(self.reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        if (!result) {
            NSLog(@"error setting runloop mode.");
            return;
        }
    }
}
static void reachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    assert(info != NULL);
    //    assert([(__bridge NSObject*)(info) isKindOfClass:[NetworkInfoController class]]);
    //
    //    NetworkInfoController *networkCtrl = (__bridge NetworkInfoController*)(info);
    //    [networkCtrl reachabilityStatusChangedCB];
}
- (void)pushNetworkBandwidth:(NetworkBandwidth *)bandwidth {
    [self.networkBandwidthHistory addObject:bandwidth];

    while (self.networkBandwidthHistory.count > self.bandwidthHistorySize) {
        [self.networkBandwidthHistory removeObjectAtIndex:0];
    }
}
@end
