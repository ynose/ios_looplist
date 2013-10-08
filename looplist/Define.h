//
//  Define.h
//  Looplist
//
//  Created by Yoshio Nose on 2013/07/12.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#ifndef Looplist_Define_h
#define Looplist_Define_h

#define LONGPRESS_DURATION 1.0f //0.7f

#ifdef DEBUG
#define MACRO_ICLOUD_AVAILABLE YES
#else
#define MACRO_ICLOUD_AVAILABLE [[NSUserDefaults standardUserDefaults] boolForKey:SETTING_ICLOUD_AVAILABLE]
#endif

// KeyValuCodingのためのプロパティ名（大文字小文字も識別される）
#define KVO_CHECKEDDATE @"checkedDate"

// UserDefaultキー
#define SETTING_ACTIVETAB @"ActiveTab"
#define SETTING_SHOWTABS @"ShowTabs"
#define SETTING_ICLOUD_AVAILABLE @"iCloudAvailable"

#define SHOWLIST_MAX 5
#define SHOWLIST_COUNT [[NSUserDefaults standardUserDefaults] integerForKey:SETTING_SHOWTABS]

// カラー
#define UIColorMain [UIColor colorWithRed:0.216 green:0.396 blue:0.078 alpha:1.000]
#define UIColorMainDisable [UIColor colorWithRed:0.533 green:0.635 blue:0.459 alpha:1.000]
#define UIColorButtonText [UIColor whiteColor]
#define UIColorTitleMain [UIColor blackColor]

#define UIColorCellUncheck [UIColor whiteColor]
#define UIColorCellChecked [UIColor colorWithRed:0.902 green:0.902 blue:0.902 alpha:1.000]
#define UIColorTextUncheck [UIColor blackColor]
#define UIColorTextChecked [UIColor grayColor]

#define UIColorSectionBackground [UIColor colorWithRed:0.729 green:0.737 blue:0.627 alpha:0.9]
#define UIColorSectionText [UIColor whiteColor]

// フォントサイズ
#define UIFontStandard [UIFont systemFontOfSize:17.0f]
#define UIFontStandardBold [UIFont boldSystemFontOfSize:17.0f]


// リストのフィルター
#define FILTER_ALL 0
#define FILTER_UNCHECKED 1

// アプリスペック
#define MAX_CHECKLIST 20                        // チェックリスト上限数
#define MAX_FINISHCOUNT MIN(9999, NSIntegerMax) // チェック完了回数上限数

#endif
