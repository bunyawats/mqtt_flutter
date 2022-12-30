# mqtt_flutter

$ flutter pub add mqtt_client

Android
Add the following Android permissions to the AndroidManifest.xml file, located in android/app/src/main/AndroidManifest.xml:

<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

[//]: # (connect to local machine)
final client = MqttServerClient('10.0.2.2', '');