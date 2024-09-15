import { InAppPurchase } from 'jcb-capacitor-inapp';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    InAppPurchase.echo({ value: inputValue })
}
