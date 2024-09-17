export interface InAppPurchasePlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  buyProduct(options: { value: string }): Promise<{ value: string }>;
  test(options: { value: string }): Promise<{ value: string }>;
}
