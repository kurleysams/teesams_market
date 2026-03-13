# Generated automatically by Android Gradle plugin
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider


# Stripe keep rules
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**

# Stripe Android SDK internal models
-keep class com.stripe.android.model.** { *; }

# Stripe PaymentSheet
-keep class com.stripe.android.paymentsheet.** { *; }

# Flutter Stripe plugin
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**