export const gameDeploy = {
  systemIdPrefix: 'happiJack.systems',
  systems: [
    //below are eno systems
    'StoreU256SetSystem', // eno system
    //below are game systems
    'LotteryGameSystem',
    'LotteryGameSystemConfig',
    'LotteryGameConstantVariableSystem',
    'LotteryGameBonusPoolSystem',
    'LotteryGameTicketSystem',
    'LotteryGameLuckyNumberSystem',
    'LotteryGameSellSystem',
    'LotteryGameTicketNFTSystem',
    'LotteryGameLotteryCoreSystem',
    'LotteryGameLotteryResultVerifySystem',
    'LotteryGameLotteryWalletSafeBoxSystem',
    'LotteryGameTicketBonusRewardSystem',
    'LotteryGameLotteryNFTSystem',
    'LotteryGameLotteryResultVerifyBonusPoolRefundSystem',
  ],
  //special system ids
  systemId: function (systemName: string) {
    switch (systemName) {
      case 'StoreU256SetSystem':
        return 'eno.systems.StoreU256SetSystem';
    }
    return `${this.systemIdPrefix}.${systemName}`;
  },
};
