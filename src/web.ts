import { WebPlugin } from '@capacitor/core';

import type { InAppPurchasePlugin } from './definitions';

export class InAppPurchaseWeb extends WebPlugin implements InAppPurchasePlugin {

   async echo(options: { value: string }): Promise<{ value: string }> {
      console.log('ECHO', options)
      return options
   }

   async getSubscriptionProductInfo(options: { productId: string }): Promise<{ value: string }> {
      console.log('*** getSubscriptionProductInfo', options)
      return {
         value: "ok"
      }
   }

   async checkSubscription(): Promise<{ value: string }> {
      console.log('*** checkSubscription')
      return {
         value: "ok"
      }
   }

   async buySubscription(options: { productId: string }): Promise<{ value: string }> {
      console.log('*** buySubscription', options)
      return {
         value: "ok"
      }
   }

}
