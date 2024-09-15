import { WebPlugin } from '@capacitor/core';

import type { InAppPurchasePlugin } from './definitions';

export class InAppPurchaseWeb extends WebPlugin implements InAppPurchasePlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
