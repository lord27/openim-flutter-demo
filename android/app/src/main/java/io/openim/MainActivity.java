package io.openim;

import android.content.Context;
import android.media.AudioManager;
import android.media.AudioRecordingConfiguration;
import android.os.Build;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MainActivity extends FlutterFragmentActivity {
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "openim/mic_diag")
        .setMethodCallHandler((call, result) -> {
          if ("activeRecordings".equals(call.method)) {
            result.success(getActiveRecordings());
          } else if ("deviceInfo".equals(call.method)) {
            Map<String, Object> m = new HashMap<>();
            m.put("manufacturer", Build.MANUFACTURER == null ? "" : Build.MANUFACTURER);
            m.put("model", Build.MODEL == null ? "" : Build.MODEL);
            m.put("sdk", Build.VERSION.SDK_INT);
            result.success(m);
          } else {
            result.notImplemented();
          }
        });
  }

  // Active recording sessions (uid + package name), used to diagnose "mic occupied causing silent recording"
  private List<Map<String, Object>> getActiveRecordings() {
    List<Map<String, Object>> out = new ArrayList<>();
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) return out;
    try {
      AudioManager am = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
      if (am == null) return out;
      for (AudioRecordingConfiguration c : am.getActiveRecordingConfigurations()) {
        Map<String, Object> m = new HashMap<>();
        int uid = -1;
        try {
          uid = (Integer) c.getClass().getMethod("getClientUid").invoke(c);
        } catch (Throwable t) {
        }
        m.put("uid", uid);
        String name = getPackageManager().getNameForUid(uid);
        m.put("pkg", name == null ? ("uid:" + uid) : name);
        out.add(m);
      }
    } catch (Exception e) {
      // Query failure does not affect normal recording flow
    }
    return out;
  }
}
