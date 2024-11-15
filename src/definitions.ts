// import type { PluginListenerHandle } from '@capacitor/core';

export interface InAppPurchasePlugin {

  echo(options: { value: string }): Promise<{ value: string }>;

  // // ? MARCHE PAS
  // addListener(
  //   eventName: 'billingReady',
  //   listenerFunc: (code: { type: number }) => void,
  // ): Promise<PluginListenerHandle> & PluginListenerHandle;

  isBillingReady(): Promise<{ value: boolean }>;

  // return information on an inapp product of type subscription
  // {
  //    productId,
  //    name, "Abonnement standard mensuel"
  //    description, "Accès à toutes les rerssources"
  //    price, "2,99 €"
  //    period, "mois"
  // }
  getSubscriptionProductInfo(options: { productId: string }): Promise<{ value: string }>;

  // return the subscription status of the mobile user regarding productId
  // {
  //     productId,
  //     status, ("active", "expired", "canceled", "pending", "unverified")
  // }
  checkSubscription(): Promise<{ value: string }>;
  
  // buy for the mobile user a subscription for productId
  // return its status, which should normally be "active"
  // {
  //     productId,
  //     status, ("active", "expired", "canceled", "pending", "unverified")
  // }
  buySubscription(options: { productId: string }): Promise<{ value: string }>;
}
