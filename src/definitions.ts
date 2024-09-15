export interface InAppPurchasePlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
