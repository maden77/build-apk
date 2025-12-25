package com.myapp;

import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

public class App extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setBackgroundColor(Color.WHITE);
        layout.setPadding(50, 100, 50, 50);
        
        TextView title = new TextView(this);
        title.setText("CLEANER APP");
        title.setTextSize(24);
        title.setTextColor(Color.BLUE);
        title.setPadding(0, 0, 0, 50);
        
        Button button = new Button(this);
        button.setText("Clean Cache");
        button.setTextSize(18);
        button.setBackgroundColor(Color.GREEN);
        
        TextView status = new TextView(this);
        status.setText("Click button above");
        status.setTextSize(16);
        status.setPadding(0, 50, 0, 0);
        
        button.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                status.setText("Cleaning...");
                try {
                    Runtime.getRuntime().exec("pm trim-caches 999999999");
                    status.setText("Done!");
                    Toast.makeText(App.this, "Cache cleaned!", Toast.LENGTH_SHORT).show();
                } catch (Exception e) {
                    status.setText("Error");
                }
            }
        });
        
        layout.addView(title);
        layout.addView(button);
        layout.addView(status);
        setContentView(layout);
    }
}
