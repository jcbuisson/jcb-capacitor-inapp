import { registerPlugin } from '@capacitor/core';

import type { InAppPurchasePlugin } from './definitions';

const InAppPurchase = registerPlugin<InAppPurchasePlugin>('InAppPurchase', {
  web: () => import('./web').then(m => new m.InAppPurchaseWeb()),
});

export * from './definitions';
export { InAppPurchase };
