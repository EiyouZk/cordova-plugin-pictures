package org.apache.cordova.GetPictures;

import android.os.Environment;



import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class GetPictures extends CordovaPlugin
{
	public static boolean flag=true;
	public boolean execute(String action,JSONArray args,final CallbackContext callbackContext) throws JSONException
	{
		class MainThread extends Thread  {
			public MainThread(){
				super();
				flag=true;
			}

			public void run() {
					int oldcount=0;
					boolean isfirst=true;
					while(flag){
						int count=0;

						// 得到sd卡内路径
						String DCIM_Path = Environment.getExternalStorageDirectory().toString()+ "/"+Environment.DIRECTORY_DCIM;
						String PICTURES_Path =Environment.getExternalStorageDirectory().toString()+ "/"+Environment.DIRECTORY_PICTURES;



						List<String> list = new ArrayList<String>();


						File mfile = new File(DCIM_Path);
						File[] files = mfile.listFiles();
						for (int i = 0; i < files.length; i++) {
							File file = files[i];
							list.add(list.size(),file.toString());
						}

						mfile = new File(PICTURES_Path);
						files = mfile.listFiles();
						for (int i = 0; i < files.length; i++) {
							File file = files[i];
							list.add(list.size(),file.toString());
						}

						for(int i=0;i<list.size();i++){
							String str=list.get(i);
							File file=new File(str);

							if(file.isDirectory()){
								File[] _files=file.listFiles();
								for (int j = 0; j < _files.length; j++) {
									list.add(list.size(), _files[j].toString());
								}
							}
							else if(checkIsImageFile(file.getPath())) {
								count+=1;
							}
						}


						if(isfirst){
							oldcount=count;
							isfirst=false;
						}
						else if(oldcount<count){
							oldcount=count;
							PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, true);
							pluginResult.setKeepCallback(false);
							if (flag) {
								callbackContext.sendPluginResult(pluginResult);
								flag=false;
							}
							return;
						}
					}
				}

			private boolean checkIsImageFile(String fName) {
				boolean isImageFile = false;

				// 获取扩展名
				String FileEnd = fName.substring(fName.lastIndexOf(".") + 1,
						fName.length()).toLowerCase();
				if (FileEnd.equals("jpg") || FileEnd.equals("gif")
						|| FileEnd.equals("png") || FileEnd.equals("jpeg")
						|| FileEnd.equals("bmp")) {
					isImageFile = true;
				} else {
					isImageFile = false;
				}

				return isImageFile;

			}
		}
		class EndThread extends Thread{

			public EndThread(){
				super();
				flag=false;
			}
			public void run() {
				flag=false;
			}
		}
		final int value = args.getInt(0);
		if(action.equals("getAllPictures")){
			if (value==0){
				MainThread begin=new MainThread();
				begin.start();
				return true;
			}
			else if(value==1){
				EndThread end=new EndThread();
				end.start();
				return true;
			}
			else if(value==2){
				MainThread begin=new MainThread();
				begin.start();
				return true;
			}
		}
		return false;
	}
}
