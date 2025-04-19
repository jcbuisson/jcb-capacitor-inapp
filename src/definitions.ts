// import type { PluginListenerHandle } from '@capacitor/core';

export interface InAppPurchasePlugin {

  echo(options: { value: string }): Promise<{ value: string }>;

  // // ? MARCHE PAS
  // addListener(
  //    eventName: 'billingReady',
  //    listenerFunc: (code: { type: number }) => void,
  // ): Promise<PluginListenerHandle> & PluginListenerHandle;


  // return information on an inapp product of type subscription
  // {
  //    productId, ex: "premium_monthly"
  //    platform, ex: "ios"
  //    name, ex: "Abonnement standard mensuel"
  //    description, ex: "Accès à toutes les rerssources"
  //    price, ex: "2,99 €"
  //    period, ex: "mois"
  // }
  getSubscriptionProductInfo(options: { productId: string }): Promise<{ value: string }>;

  // return the subscription status of the mobile user regarding productId
  // {
  //    productId, ex: "premium_monthly"
  //    platform, ex: "ios"
  //    status, ("active", "expired", "canceled", "pending", "unverified")
  // }
  checkSubscription(): Promise<{ value: string }>;
  
  // buy for the mobile user a subscription for productId
  // return
  // {
  //    productId,
  //    platform, ex: "ios"
  //    status, (normally "active")
  // }
  buySubscription(options: { productId: string }): Promise<{ value: string }>;
}
