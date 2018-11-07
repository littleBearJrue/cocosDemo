/**
 * LuaCallManager.java
 * Boyaa Texas Poker For Android
 * <p>
 * Created by JanRoid on 2014-11-11.
 * Copyright (c) 2008-2014 Boyaa Interactive. All rights reserved.
 */
package com.boyaa.entity.luaManager;

import android.bluetooth.BluetoothAdapter;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Message;
import android.provider.MediaStore;
import android.provider.Settings;
import android.util.Log;


import org.json.JSONException;
import org.json.JSONObject;

/**
 * @author Janroid
 */
public class LuaCallManager {
	private static final String TAG = "LuaCallManager";
	
	private static LuaCallManager luaCallManager;
	
	// 获得key，此key代表需调用的方法名
	public final static String kluaCallEvent = "LuaCallEvent";
	
	public static LuaCallManager getInstance() {
		if (null == luaCallManager) {
			luaCallManager = new LuaCallManager();
		}
		return luaCallManager;
	}

	public static void callEvent(int nKey,String sJsonData)
	{

	}

	public static native void systemCallLuaEvent(int nKey, String sJsonData);
}
