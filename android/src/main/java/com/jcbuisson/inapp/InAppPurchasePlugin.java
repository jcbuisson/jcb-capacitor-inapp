package com.jcbuisson.inapp;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingResult;


@CapacitorPlugin(name = "InAppPurchase")
public class InAppPurchasePlugin extends Plugin {

    private InAppPurchase implementation = new InAppPurchase();

    @PluginMethod
    public void echo(PluginCall call) {
        // String value = call.getString("value");

        // JSObject ret = new JSObject();
        // ret.put("value", implementation.echo(value));
        // call.resolve(ret);

        BillingClient billingClient;

        billingClient = BillingClient.newBuilder(this)
            // .setListener(purchaseListener)
            .enablePendingPurchases()
            .build();

        billingClient.startConnection(new BillingClientStateListener() {
            @Override
            public void onBillingSetupFinished(BillingResult billingResult) {
                if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK) {
                    // BillingClient is ready. You can now query purchases.
                    System.out.println("Ready!");
                    // queryAvailableProducts();
                }
            }

            @Override
            public void onBillingServiceDisconnected() {
                // Handle billing service disconnect.
                // Optionally retry startConnection() or alert the user.
            }
        });
    }

}
