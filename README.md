# jcb-capacitor-inapp

Capacitor plugin for inApp purchase on iOS (StoreKit2) and Android (Billing library v6+)

iOS: see https://developer.apple.com/documentation/storekit/in-app_purchase
Android : https://developer.android.com/google/play/billing

API : see definitions.ts

## Build
```
npm run build
```

## Publish
```
npm publish
```

## Utilisation dans une application Capacitor (webapp, app iOS, app Android)
```bash
npm install jcb-capacitor-inapp
npx cap sync
```

iOS : can be tested on simulator, with a StoreKit configuration file
Android : does not work on simulator
