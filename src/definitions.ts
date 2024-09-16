export interface InAppPurchasePlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  fetchProducts(options: { value: string }): Promise<{ value: string }>;
}
