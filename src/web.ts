import { WebPlugin } from '@capacitor/core';

import type { InAppPurchasePlugin } from './definitions';

export class InAppPurchaseWeb extends WebPlugin implements InAppPurchasePlugin {

   async echo(options: { value: string }): Promise<{ value: string }> {
      console.log('ECHO', options)
      return options
   }

   async buySubscription(options: { productId: string }): Promise<{ value: string }> {
      console.log('buySubscription', options)
      return {
         value: "ok"
      }
   }

   async getPurchases(options: { value: string }): Promise<{ value: string }> {
      console.log('GETPURCHASES', options)
      return {
         value: "ok"
      }
   }

   async checkSubscription(): Promise<{ value: string }> {
      console.log('CHECK SUBSCRIPTION')
      return {
         value: "ok"
      }
   }

}
