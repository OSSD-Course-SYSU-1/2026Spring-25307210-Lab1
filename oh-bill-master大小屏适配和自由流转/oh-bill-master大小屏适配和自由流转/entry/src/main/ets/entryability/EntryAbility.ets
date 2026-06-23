import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import {SettingManager, DBManager} from '@ohos/common';
import Want from '@ohos.app.ability.Want';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';

export default class EntryAbility extends UIAbility {
  // 定义一个变量存储恢复的数据
  private restoreData: Record<string, Object> | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    globalThis.context = this.context;
    globalThis.__settingManager__ = new SettingManager(this.context);
    globalThis.__dbManager__ = new DBManager(this.context);

    // 1. 检查是否是从流转（自由流转）启动
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      this.restoreData = want.parameters;
      // 允许流转连续性
      this.context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE);
    }
  }

  // 2. 如果实例已经存在，流转触发时会走 onNewWant
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onNewWant');
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      this.restoreData = want.parameters;
    }
  }

  // 3. 源端设备触发流转时，保存数据
  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onContinue');
    try {
      // 从全局或特定持久化层读取当前 Index 页面选择的日期
      // 这里暂定保存 selectedDate 的时间戳（流转入参建议传基础类型）
      if (globalThis.selectedDateForTransfer) {
        wantParam['selectedDateTimestamp'] = globalThis.selectedDateForTransfer.getTime();
      }
      return AbilityConstant.OnContinueResult.AGREE;
    } catch (err) {
      hilog.error(0x0000, 'testTag', 'onContinue failed: %{public}s', JSON.stringify(err));
      return AbilityConstant.OnContinueResult.REJECT;
    }
  }

  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    
    // 4. 将流转恢复的数据打包进 localStorage 传给 Index 页面
    let storage = new LocalStorage();
    if (this.restoreData) {
      storage.setOrCreate('selectedDateTimestamp', this.restoreData['selectedDateTimestamp']);
    }

    // 传入 storage 实例
    windowStage.loadContent('pages/Index', storage, (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
    // 页面回到前台时，主动将迁移状态设为 ACTIVE，开启多端流转图标
    this.context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE);
  }

  onBackground() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}