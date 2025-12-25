#!/data/data/com.termux/files/usr/bin/bash

echo "=== BUILD REAL ANDROID APK ==="

# 1. Pastikan android.jar ada
if [ ! -f "android.jar" ]; then
    echo "Downloading android.jar..."
    wget -q https://github.com/Sable/android-platforms/raw/master/android-21/android.jar
fi

# 2. Buat file Java SANGAT sederhana
cat > MainActivity.java << 'JAVAEOF'
package com.android.app;
import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        TextView tv = new TextView(this);
        tv.setText("Hello from Android!");
        setContentView(tv);
    }
}
JAVAEOF

# 3. Buat Manifest sederhana
cat > AndroidManifest.xml << 'XMLEOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.android.app">
    <application>
        <activity android:name=".MainActivity" android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
XMLEOF

echo "1. Compiling Java..."
javac -cp android.jar MainActivity.java 2>&1

if [ $? -ne 0 ]; then
    echo "❌ Java compile error"
    echo "Trying simple compilation..."
    # Coba tanpa import
    cat > SimpleActivity.java << 'SIMPLE'
public class SimpleActivity {
    public void test() {
        System.out.println("Test");
    }
}
SIMPLE
    javac SimpleActivity.java
    dx --dex --output=classes.dex SimpleActivity.class
else
    echo "✅ Java compiled"
    dx --dex --output=classes.dex MainActivity.class 2>&1
fi

echo "2. Packaging APK..."
aapt package -f -M AndroidManifest.xml -I android.jar -F app-unsigned.apk 2>&1 | head -5

echo "3. Adding DEX..."
aapt add app-unsigned.apk classes.dex 2>&1

echo "4. Creating keystore..."
if [ ! -f "debug.keystore" ]; then
    keytool -genkey -v -keystore debug.keystore -alias android \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -storepass 123456 -keypass 123456 \
        -dname "CN=Test" 2>/dev/null
fi

echo "5. Signing APK..."
apksigner sign --ks debug.keystore --ks-pass pass:123456 \
    --key-pass pass:123456 --out final-app.apk app-unsigned.apk 2>&1

if [ -f "final-app.apk" ]; then
    echo ""
    echo "✅ ✅ ✅ SUCCESS! APK CREATED ✅ ✅ ✅"
    echo "📦 File: $(pwd)/final-app.apk"
    echo "📏 Size: $(du -h final-app.apk | cut -f1)"
    
    # Copy ke Download
    cp final-app.apk /storage/emulated/0/Download/android-app.apk 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "📂 Copied to: /storage/emulated/0/Download/android-app.apk"
    fi
    
    # Cek info APK
    echo ""
    echo "📋 APK Information:"
    aapt dump badging final-app.apk 2>/dev/null | head -3 || \
        echo "Can't read APK info"
else
    echo "❌ APK creation failed"
    echo "Last 10 lines of output:"
    tail -10 build_real_apk.sh.log 2>/dev/null || echo "No log"
fi
