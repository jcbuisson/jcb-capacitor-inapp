package com.jcbuisson.inapp;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import android.content.Context;
import androidx.annotation.NonNull;
import android.util.Log;

import com.android.billingclient.api.*;
import com.android.billingclient.api.BillingFlowParams.*;

import java.util.*;


//////////          PLUGIN INTERFACE          //////////

@CapacitorPlugin(name = "InAppPurchase")
public class InAppPurchasePlugin extends Plugin {

    @Override
    public void load() {
        super.load();
        initializeBillingClient();
    }

    @PluginMethod
    public void echo(PluginCall call) {
        String value = call.getString("value");

        JSObject ret = new JSObject();
        ret.put("value", value);
        call.resolve(ret);

    }
    
    // Query products for purchase
    @PluginMethod
    public void checkSubscription(PluginCall call) {
        Log.d(TAG, "checkSubscription...");
        queryActiveSubscriptions(call);
    }
    
    // Launch purchase flow
    @PluginMethod
    public void buySubscription(PluginCall call) {
        String productId = call.getString("productId");
        queryAndBuySubscription(productId, call);
    }

    //////////          IMPLEMENTATION          //////////

    private BillingClient billingClient;
    
    private static final String TAG = "Capacitor";  // Define a tag for logging

    private void initializeBillingClient() {
        Log.d(TAG, "Initializing BillingClient...");
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
                Log.d(TAG, "onBillingSetupFinished... " + billingResult.getResponseCode() + " " + BillingClient.BillingResponseCode.OK);
                if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK) {
                    // Billing client setup complete, ready for further actions
                    notifyBillingReady();
                }
            }

            @Override
            public void onBillingServiceDisconnected() {
                // Reconnect when the billing service is disconnected
                Log.d(TAG, "onBillingServiceDisconnected...");
            }
        });
    }

    // Notify the JS layer that the billing client is ready
    private void notifyBillingReady() {
        Log.d(TAG, "notifyBillingReady...");
        JSObject ret = new JSObject();
        ret.put("message", "Billing client is ready");
        notifyListeners("billingReady", ret);
    }

    // Notify the JS layer about a purchase update
    private void notifyPurchaseUpdate(List<Purchase> purchases) {
        Log.d(TAG, "notifyPurchaseUpdate...");
        JSObject ret = new JSObject();
        ret.put("message", "Purchase successful");
        notifyListeners("purchaseUpdate", ret);
    }

    // Notify about purchase cancellation
    private void notifyPurchaseCancel() {
        Log.d(TAG, "notifyPurchaseCancel...");
        JSObject ret = new JSObject();
        ret.put("message", "Purchase canceled");
        notifyListeners("purchaseCancel", ret);
    }

    // Notify about purchase error
    private void notifyPurchaseError(String error) {
        Log.d(TAG, "notifyPurchaseError...");
        JSObject ret = new JSObject();
        ret.put("message", "Purchase error: " + error);
        notifyListeners("purchaseError", ret);
    }

    private void queryActiveSubscriptions(PluginCall call) {
        billingClient.queryPurchasesAsync(BillingClient.ProductType.SUBS, new PurchasesResponseListener() {
            @Override
            public void onQueryPurchasesResponse(BillingResult billingResult, List<Purchase> purchases) {
                if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK && purchases != null) {
                    // Iterate through the list of purchases (active subscriptions)
                    Log.d(TAG, "purchases " + purchases.toString());
                    for (Purchase purchase : purchases) {
                        checkSubscriptionStatus(purchase);
                    }
                } else {
                    // Handle errors (e.g., no active subscriptions or failed query)
                    Log.d(TAG, "Failed to query purchases: " + billingResult.getDebugMessage());
                }
            }
        });
    }
    
    private void checkSubscriptionStatus(Purchase purchase) {
        // Check if the subscription is acknowledged
        if (purchase.getPurchaseState() == Purchase.PurchaseState.PURCHASED) {
            // Subscription is active (purchased)
            if (!purchase.isAcknowledged()) {
                // Acknowledge the purchase if not acknowledged
                acknowledgePurchase(purchase);
            }
    
            // Here, you can check additional details, such as purchase time, order ID, etc.
            Log.d("BillingClient", "Subscription is active: " + purchase.getOrderId());
        } else if (purchase.getPurchaseState() == Purchase.PurchaseState.PENDING) {
            // Handle pending subscription
            Log.d("BillingClient", "Subscription is pending: " + purchase.getOrderId());
        } else {
            // Handle other states (expired, canceled, etc.)
            Log.d("BillingClient", "Subscription state: " + purchase.getPurchaseState());
        }
    }

    private void acknowledgePurchase(Purchase purchase) {
        AcknowledgePurchaseParams acknowledgePurchaseParams = AcknowledgePurchaseParams.newBuilder()
                .setPurchaseToken(purchase.getPurchaseToken())
                .build();
    
        billingClient.acknowledgePurchase(acknowledgePurchaseParams, new AcknowledgePurchaseResponseListener() {
            @Override
            public void onAcknowledgePurchaseResponse(BillingResult billingResult) {
                if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK) {
                    Log.d("BillingClient", "Purchase acknowledged successfully.");
                } else {
                    Log.d(TAG, "Failed to acknowledge purchase: " + billingResult.getDebugMessage());
                }
            }
        });
    }

    private BillingResult queryAndBuySubscription(String productId, PluginCall call) {
        Log.d(TAG, "queryAndBuySubscription called with productId: " + productId);

        List<QueryProductDetailsParams.Product> productList = new ArrayList<>();
        productList.add(QueryProductDetailsParams.Product.newBuilder()
            .setProductId(productId)
            .setProductType(BillingClient.ProductType.SUBS)
            .build());

        QueryProductDetailsParams params = QueryProductDetailsParams.newBuilder()
            .setProductList(productList)
            .build();

        billingClient.queryProductDetailsAsync(params, (billingResult, productDetailsList) -> {
            Log.d(TAG, "queryProductDetailsAsync for purchase finished with result code: " + billingResult.getResponseCode());

            if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK && !productDetailsList.isEmpty()) {
                ProductDetails productDetails = productDetailsList.get(0);

                Log.d(TAG, "Launching purchase flow for product: " + productDetails.toString());

                List<ProductDetails.SubscriptionOfferDetails> subscriptionOfferDetailsList = productDetails.getSubscriptionOfferDetails();
                ProductDetails.SubscriptionOfferDetails selectedOffer = subscriptionOfferDetailsList.get(0);
                Log.d(TAG, "selectedOffer = " + selectedOffer.toString());

                List<ProductDetailsParams> productDetailsParamsList = List.of(
                    ProductDetailsParams.newBuilder()
                        .setProductDetails(productDetails)
                        .setOfferToken(selectedOffer.getOfferToken())
                        .build()
                );
            
                BillingFlowParams billingFlowParams = BillingFlowParams.newBuilder()
                    .setProductDetailsParamsList(productDetailsParamsList)
                    .build();
                
                // Launch the billing flow
                BillingResult result = billingClient.launchBillingFlow(getActivity(), billingFlowParams);
                JSObject ret = new JSObject();
                ret.put("productId", productId);
                ret.put("status", "active");
                call.resolve(ret);
    
                Log.d(TAG, "Purchase flow launched with result code: " + result.getResponseCode());
            } else {
                Log.e(TAG, "Failed to start purchase flow: " + billingResult.getDebugMessage());
            }
        });
        return null;
    }

}
