// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import { BalanceViewer } from '../components/BalanceViewer';
import { BalanceList } from '../components/BalanceList';
import { PageEntries } from '../components/pageEntries';
import { BillingDirection, BillingInfo, BillingInfoUtils, DBManager, Logger } from '@ohos/common';
import mediaquery from '@ohos.mediaquery'; // 引入媒体查询以支持多端适配

let TAG = "INDEX";

// 获取与 EntryAbility 共享的 LocalStorage 实例
let storage = LocalStorage.getShared();

@Entry(storage)
@Component
struct Index {
  // 接收来自 EntryAbility 流转恢复的时间戳（若非流转启动则默认为 0）
  @LocalStorageProp('selectedDateTimestamp') transferredTimestamp: number = 0;

  @State selectedDate: Date = new Date();
  @State currentBillingInfo: BillingInfo[] = [];
  @State totalIncome: number = 0.00;
  @State totalBalance: number = 0.00;

  // 定义当前断点状态：sm(手机), md(折叠屏), lg(平板)
  @State currentBreakpoint: string = 'sm';
  
  // 媒体查询监听器
  private smListener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('(width < 520vp)');
  private mdListener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('(520vp <= width < 840vp)');
  private lgListener: mediaquery.MediaQueryListener = mediaquery.matchMediaSync('(840vp <= width)');

  // 注册断点监听
  registerBreakpoint() {
    this.smListener.on('change', (mediaQueryResult) => {
      if (mediaQueryResult.matches) this.currentBreakpoint = 'sm';
    });
    this.mdListener.on('change', (mediaQueryResult) => {
      if (mediaQueryResult.matches) this.currentBreakpoint = 'md';
    });
    this.lgListener.on('change', (mediaQueryResult) => {
      if (mediaQueryResult.matches) this.currentBreakpoint = 'lg';
    });
  }

  // 注销监听
  unregisterBreakpoint() {
    this.smListener.off('change');
    this.mdListener.off('change');
    this.lgListener.off('change');
  }

  aboutToAppear() {
    // 1. 注册多端适配的屏幕监听
    this.registerBreakpoint();

    // 2. 检查并恢复流转过来的选定日期状态
    if (this.transferredTimestamp && this.transferredTimestamp > 0) {
      this.selectedDate = new Date(this.transferredTimestamp);
    }

    // 3. 将当前的日期对象同步到全局，便于源端随时打包准备流转
    globalThis.selectedDateForTransfer = this.selectedDate;
  }

  aboutToDisappear() {
    this.unregisterBreakpoint();
  }

  clearCache() {
    this.totalIncome = 0;
    this.totalBalance = 0;
  }

  onPageShow() {
    DBManager.getInstance().getAllBillingInfo()
      .then(r => {
        this.clearCache();
        this.currentBillingInfo = r;
        this.currentBillingInfo.forEach(info => {
          info.direction == BillingDirection.IN ? this.totalIncome += info.amount : this.totalBalance += info.amount;
        })
        Logger.info(TAG, "get info success ", r);
        Logger.info(TAG, "explode length: ", BillingInfoUtils.explodeMonthlyArray(this.currentBillingInfo, new Date())[19]
          .length)
      })
  }

  build() {
    Column() {
      // 顶部 Title Bar
      Row() {
        Text($r("app.string.app_title"))
          .fontColor(Color.White)
          .fontSize(24)
          .fontWeight(FontWeight.Normal)
          .textAlign(TextAlign.Center)
          .width('100%')
      }
      .padding(24)
      .width('100%')
      .backgroundColor($r("app.color.main_theme_blue"))

      // 核心适配区域：使用栅格布局实现多端自适应
      // sm(手机)共4栏，md(折叠屏)共8栏，lg(平板)共12栏
      GridRow({
        columns: { sm: 4, md: 8, lg: 12 },
        gutter: { x: 12, y: 12 }
      }) {
        // 左侧/上方区域：包含看板和快捷入口
        GridCol({
          span: { sm: 4, md: 4, lg: 4 } // sm占满(4/4), md占一半(4/8), lg占三分之一(4/12)
        }) {
          Column() {
            BalanceViewer({
              selectedDate: $selectedDate,
              currentBillingInfo: $currentBillingInfo,
              totalIncome: $totalIncome,
              totalBalance: $totalBalance
            })
            PageEntries()
          }
          .width('100%')
        }

        // 右侧/下方区域：账单列表
        GridCol({
          span: { sm: 4, md: 4, lg: 8 } // sm占满(4/4), md占一半(4/8), lg占三分之二(8/12)
        }) {
          Column() {
            BalanceList({
              currentBillingInfo: $currentBillingInfo,
              selectedDate: $selectedDate,
              totalBalance: $totalBalance,
              totalIncome: $totalIncome
            })
          }
          .width('100%')
        }
      }
      .width('100%')
      .layoutWeight(1) // 占满剩余垂直空间
      .padding({ left: 12, right: 12, bottom: 12 })
    }
    .width('100%')
    .height('100%')
  }
}