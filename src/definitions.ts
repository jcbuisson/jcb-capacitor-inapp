export interface InAppPurchasePlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  buySubscription(options: { productId: string }): Promise<{ value: string }>;
  // getPurchases(options: { value: string }): Promise<{ value: string }>;
  // checkSubscription(options: { value: string }): Promise<{ value: string }>;
  checkSubscription(): Promise<{ value: string }>;
}
