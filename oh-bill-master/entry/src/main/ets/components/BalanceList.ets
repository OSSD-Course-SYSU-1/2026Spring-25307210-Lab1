// Copyright (c) 2023 Ericple
// OpenBill is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
import common from '@ohos.app.ability.common';
import { BillingDirection, BillingInfo, BillingInfoUtils, StringUtils } from '@ohos/common';

@Component
export struct BalanceList {
  @Link currentBillingInfo: BillingInfo[];
  @Link selectedDate: Date;
  @Link totalBalance: number;
  @Link totalIncome: number;
  context = getContext(this) as common.UIAbilityContext;
  filesDir = this.context.filesDir;

  // 删除账单方法（点击后立刻从列表移除）
  deleteBill(balance: BillingInfo) {
    // 过滤掉要删除的账单，更新列表
    this.currentBillingInfo = this.currentBillingInfo.filter(item => item.id !== balance.id);

    // 重新计算总收入和总支出
    this.totalIncome = 0;
    this.totalBalance = 0;
    this.currentBillingInfo.forEach(info => {
      info.direction == BillingDirection.IN ? this.totalIncome += info.amount : this.totalBalance += info.amount;
    })
  }

  build() {
    Column() {
      if (this.currentBillingInfo.length == 0) {
        Row() {
          Text($r("app.string.no_record"))
            .fontColor(Color.Black)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
        }.height('100%')
      } else {
        List() {
          ForEach(BillingInfoUtils.explodeMonthlyArray(this.currentBillingInfo, this.selectedDate), (balances: BillingInfo[], day: number) => {
            ListItem() {
              Column() {
                if (balances.length > 0) {
                  Text(StringUtils.formatDate(this.selectedDate, 'M月') + `${day + 1}` + "日")
                    .fontColor($r('app.color.text_gray'))
                    .fontSize(14)
                    .width('100%')
                    .margin({ bottom: 4 })
                  Divider()
                    .margin({ bottom: 12 })
                }
                List() {
                  ForEach(balances, (balance: BillingInfo) => {
                    ListItem() {
                      Row() {
                        Row() {
                          Image(balance.type.icon)
                            .width(36)
                            .height(36)
                            .borderRadius(8)
                            .padding(8)
                            .backgroundColor('#ffe2effd')
                            .margin({ right: 16 })
                          Text(balance.remark)
                            .margin({ right: 16 })
                          Text(StringUtils.formatDate(balance.timestamp, 'h:m:s'))
                            .fontColor($r('app.color.text_gray'))
                            .fontSize(12)
                        }

                        Row() {
                          Text(`${balance.direction == BillingDirection.IN ? "+" : "-"} ${balance.amount}`)

                          // ====================== 可点击的删除按钮 ======================
                          Button("删除")
                            .width(45)
                            .height(28)
                            .backgroundColor(Color.Red)
                            .fontSize(11)
                            .margin({ left: 10 })
                            .onClick(() => {
                              this.deleteBill(balance);
                            })
                          // =============================================================
                        }
                      }
                      .width('100%')
                      .justifyContent(FlexAlign.SpaceBetween)
                    }
                    .margin({ bottom: 12 })
                  })
                }
              }
              .width('100%')
            }
          })
        }
        .listDirection(Axis.Vertical)
        .height('100%')
      }
    }.padding(8).width('100%')
  }
}