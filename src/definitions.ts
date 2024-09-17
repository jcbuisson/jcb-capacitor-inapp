export interface InAppPurchasePlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  buyProduct(options: { productId: string }): Promise<{ value: string }>;
  getPurchases(options: { value: string }): Promise<{ value: string }>;
  test(options: { value: string }): Promise<{ value: string }>;
}
