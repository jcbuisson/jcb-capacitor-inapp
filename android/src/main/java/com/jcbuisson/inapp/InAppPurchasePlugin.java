package com.jcbuisson.inapp;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import android.content.Context;
import androidx.annotation.NonNull;
import android.util.Log;

import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.PurchasesUpdatedListener;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.Purchase;

import java.util.ArrayList;
import java.util.List;


@CapacitorPlugin(name = "InAppPurchase")
public class InAppPurchasePlugin extends Plugin {

    private BillingClient billingClient;

    @Override
    public void load() {
        super.load();

        // Initialize BillingClient
        billingClient = BillingClient.newBuilder(getContext())
            .enablePendingPurchases()
            .setListener(new PurchasesUpdatedListener() {
                @Override
                public void onPurchasesUpdated(BillingResult billingResult, List<Purchase> purchases) {
                    if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK && purchases != null) {
                        // Handle successful purchases here
                        notifyPurchaseUpdate(purchases);
                    } else if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.USER_CANCELED) {
                        // Handle purchase cancellation
                        notifyPurchaseCancel();
                    } else {
                        // Handle other error cases
                        notifyPurchaseError(billingResult.getDebugMessage());
                    }
                }
            })
            .build();

        // Connect to the Play Billing service
        billingClient.startConnection(new BillingClientStateListener() {
            @Override
            public void onBillingSetupFinished(@NonNull BillingResult billingResult) {
                if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK) {
                    // Billing client setup complete, ready for further actions
                    notifyBillingReady();
                }
            }

            @Override
            public void onBillingServiceDisconnected() {
                // Reconnect when the billing service is disconnected
            }
        });
    }

    // Notify the JS layer that the billing client is ready
    private void notifyBillingReady() {
        JSObject ret = new JSObject();
        ret.put("message", "Billing client is ready");
        notifyListeners("billingReady", ret);
    }

    // Notify the JS layer about a purchase update
    private void notifyPurchaseUpdate(List<Purchase> purchases) {
        JSObject ret = new JSObject();
        ret.put("message", "Purchase successful");
        notifyListeners("purchaseUpdate", ret);
    }

    // Notify about purchase cancellation
    private void notifyPurchaseCancel() {
        JSObject ret = new JSObject();
        ret.put("message", "Purchase canceled");
        notifyListeners("purchaseCancel", ret);
    }

    // Notify about purchase error
    private void notifyPurchaseError(String error) {
        JSObject ret = new JSObject();
        ret.put("message", "Purchase error: " + error);
        notifyListeners("purchaseError", ret);
    }

    @PluginMethod
    public void echo(PluginCall call) {
        String value = call.getString("value");

        JSObject ret = new JSObject();
        Log.i("Echo", value);
        ret.put("value", value);
        call.resolve(ret);

    }

}
