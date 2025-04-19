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
        
    // Get info from a subscription (price, etc.)
    @PluginMethod
    public void getSubscriptionProductInfo(PluginCall call) {
        String productId = call.getString("productId");
        querySubscriptionInfo(productId, call);
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
    private MyPurchasesUpdatedListener purchaseListener;
    
    private static final String TAG = "Capacitor";  // Define a tag for logging

    // this listener sends back purchase results through `call` parameter, see method `setParams`
    private class MyPurchasesUpdatedListener implements PurchasesUpdatedListener {
        private PluginCall call;
        private String productId;

        public void setParams(PluginCall call, String productId) {
            this.call = call;
            this.productId = productId;
        }

        @Override
        public void onPurchasesUpdated(BillingResult billingResult, List<Purchase> purchases) {
            if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK && purchases != null) {
                // Handle successful purchases here
                Log.d(TAG, "Purchase successful...");

                for (Purchase purchase : purchases) {
                    // acknowledge purchase (see https://developer.android.com/google/play/billing/integrate?authuser=1&hl=fr#process)
                    acknowledgePurchase(purchase);
                }

                JSObject ret = new JSObject();
                ret.put("productId", this.productId);
                ret.put("platform", "android");
                ret.put("status", "active");
                this.call.resolve(ret);
        
            } else if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.USER_CANCELED) {
                // Handle purchase cancellation
                Log.d(TAG, "Purchase canceled...");
                JSObject ret = new JSObject();
                ret.put("productId", this.productId);
                ret.put("platform", "android");
                ret.put("status", "canceled");
                this.call.resolve(ret);
            } else {
                // Handle other error cases
                Log.d(TAG, "Purchase error: " + billingResult.getDebugMessage());
                this.call.reject("Failed", billingResult.getDebugMessage());
            }
        }
    }

    private void initializeBillingClient() {
        Log.d(TAG, "Initializing BillingClient...");
        purchaseListener = new MyPurchasesUpdatedListener();
        billingClient = BillingClient.newBuilder(getContext())
            .enablePendingPurchases()
            // `purchaseListener` will send back results through `call` parameter, see method `setParams`
            .setListener(purchaseListener)
            .build();

        // Connect to the Play Billing service
        billingClient.startConnection(new BillingClientStateListener() {
            @Override
            public void onBillingSetupFinished(@NonNull BillingResult billingResult) {
                Log.d(TAG, "onBillingSetupFinished... " + billingResult.getResponseCode() + " " + billingResult.getDebugMessage());
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

    private void queryActiveSubscriptions(PluginCall call) {
        billingClient.queryPurchasesAsync(BillingClient.ProductType.SUBS, new PurchasesResponseListener() {
            @Override
            public void onQueryPurchasesResponse(BillingResult billingResult, List<Purchase> purchases) {
                if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK && purchases != null) {
                    // Iterate through the list of purchases (active subscriptions)
                    Log.d(TAG, "purchases " + purchases.toString());
                    for (Purchase purchase : purchases) {
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
                } else {
                    // Handle errors (e.g., no active subscriptions or failed query)
                    Log.d(TAG, "Failed to query purchases: " + billingResult.getDebugMessage());
                }
            }
        });
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



    private void querySubscriptionInfo(String productId, PluginCall call) {
        List<QueryProductDetailsParams.Product> productList = new ArrayList<>();
        productList.add(QueryProductDetailsParams.Product.newBuilder()
            .setProductId(productId)
            .setProductType(BillingClient.ProductType.SUBS)
            .build());

        QueryProductDetailsParams params = QueryProductDetailsParams.newBuilder()
            .setProductList(productList)
            .build();

        billingClient.queryProductDetailsAsync(params, (billingResult, productDetailsList) -> {
            if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK && productDetailsList != null) {
                if (!productDetailsList.isEmpty()) {
                    ProductDetails productDetails = productDetailsList.get(0);
                    String name = productDetails.getName();
                    String description = productDetails.getDescription();
                    Log.d(TAG, "productDetails: " + productDetails.toString());
                    Log.d(TAG, "name: " + name);
                    Log.d(TAG, "description: " + description);

                    // Extract the price details
                    List<ProductDetails.SubscriptionOfferDetails> subscriptionOfferDetailsList = productDetails.getSubscriptionOfferDetails();
                    // looks like only active offers are listed, so we take the first
                    ProductDetails.SubscriptionOfferDetails selectedOffer = subscriptionOfferDetailsList.get(0);
                    List<ProductDetails.PricingPhase> pricingPhases = selectedOffer.getPricingPhases().getPricingPhaseList();
                    // look for the first active pricing plan
                    ProductDetails.PricingPhase firstActivePricingPhase = pricingPhases.get(0);
                    if (firstActivePricingPhase == null) {
                        Log.e(TAG, "No active price phase found");
                        call.reject("Failed", "No active price phase found");
                    } else {
                        // Extract price information
                        String price = firstActivePricingPhase.getFormattedPrice(); // Human-readable price, e.g., "$9.99"
                        String periodTag = firstActivePricingPhase.getBillingPeriod();
                        String period = null;
                        if (periodTag.equals("P1M")) period = "mois";
                        if (periodTag.equals("P1Y")) period = "an"; 
                        Log.d(TAG, "price: " + price);
                        Log.d(TAG, "period: " + period);
                        JSObject ret = new JSObject();
                        ret.put("productId", productId);
                        ret.put("platform", "android");
                        ret.put("name", name);
                        ret.put("description", description);
                        ret.put("price", price);
                        ret.put("period", period);
                        call.resolve(ret);
                    }
    
                } else {
                    Log.e(TAG, "No product details found for the subscription.");
                    call.reject("Failed", "No product details found for the subscription.");
                }
            } else {
                Log.e(TAG, "Failed to fetch product details: " + billingResult.getDebugMessage());
                call.reject("Failed", "Failed to fetch product details: " + billingResult.getDebugMessage());
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

                // Set the arguments of the purchase listener so that it can send results through `call`
                purchaseListener.setParams(call, productId);

                // Launch the billing flow
                BillingResult result = billingClient.launchBillingFlow(getActivity(), billingFlowParams);
    
                Log.d(TAG, "Purchase flow launched with result code: " + result.getResponseCode());
            } else {
                Log.e(TAG, "Failed to start purchase flow: " + billingResult.getDebugMessage());
            }
        });
        return null;
    }

}
