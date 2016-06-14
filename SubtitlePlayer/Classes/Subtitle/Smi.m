
#import "Smi.h"

/*
 <SAMI>
 <HEAD>
 <TITLE>Aliens.In.America.S01E12.HDTV.XviD-XOR</TITLE>
 <STYLE TYPE="text/css">
 </STYLE>
 </HEAD>
 <BODY>
 <SYNC Start=1800><P Class=KRCC>
 I Am So Nervous And Exciting
 <SYNC Start=4000><P Class=KRCC>&nbsp;
 <SYNC Start=4100><P Class=KRCC>
 It??S Like My Birthday And Last Day<br>
 Of Ramadan

 <SYNC Start=5209><P Class=ENCC>
 How can we don't have the same<br>
 number of containers and lids?
 <SYNC Start=8117><P Class=ENCC>&nbsp;
 <SYNC Start=8118><P Class=ENCC>
 Why would they ever<br>
 get separated?
 */

@implementation Smi

+ (BOOL)sniff:(NSString *)mimetype {
    NSArray *mimetypes = @[@"application/smil", @"application/smil+xml"];
    for (NSString *type in mimetypes) {
        if ([type.lowercaseString isEqualToString:mimetype.lowercaseString])
            return YES;
    }
    return NO;
}

- (void)parse:(NSData *)data {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = (id<NSXMLParserDelegate>)self;

    if (![parser parse]) {
        NSLog(@"%@", parser.parserError.description);
    }
}

@end
