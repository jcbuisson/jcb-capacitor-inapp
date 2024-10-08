# jcb-capacitor-inapp

Capacitor plugin for inApp purchase

## Install

```bash
npm install jcb-capacitor-inapp
npx cap sync
```

## API

<docgen-index>

* [`echo(...)`](#echo)
* [`buyProduct(...)`](#buyproduct)
* [`checkSubscription()`](#checksubscription)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### echo(...)

```typescript
echo(options: { value: string; }) => Promise<{ value: string; }>
```

| Param         | Type                            |
| ------------- | ------------------------------- |
| **`options`** | <code>{ value: string; }</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### buyProduct(...)

```typescript
buyProduct(options: { productId: string; }) => Promise<{ value: string; }>
```

| Param         | Type                                |
| ------------- | ----------------------------------- |
| **`options`** | <code>{ productId: string; }</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### checkSubscription()

```typescript
checkSubscription() => Promise<{ value: string; }>
```

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------

</docgen-api>
