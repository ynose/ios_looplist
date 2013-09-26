//
//  Define.h
//  EverList
//
//  Created by Yoshio Nose on 2013/07/12.
//  Copyright (c) 2013年 Yoshio Nose. All rights reserved.
//

#ifndef EverList_Define_h
#define EverList_Define_h

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
#define SETTING_ICLOUD_AVAILABLE @"iCloudAvailable"

// カラー
#define UIColorMain [UIColor colorWithRed:0.176 green:0.588 blue:0.094 alpha:1.000]

// フォントサイズ
#define UIFontStandard [UIFont systemFontOfSize:17.0f]
#define UIFontStandardBold [UIFont boldSystemFontOfSize:17.0f]

// ECSlidingViewControllerの影
#define SLIDINGVIEW_SHADOWOPACITY 0.75f
#define SLIDINGVIEW_SHADOWRADIUS 10.0f
#define SLIDINGVIEW_SHADOWCOLOR [UIColor blackColor].CGColor

// リストのフィルター
#define FILTER_ALL 0
#define FILTER_UNCHECKED 1

// アプリスペック
#define MAX_CHECKLIST 20                        // チェックリスト上限数
#define MAX_FINISHCOUNT MIN(9999, NSIntegerMax) // チェック完了回数上限数

#endif
