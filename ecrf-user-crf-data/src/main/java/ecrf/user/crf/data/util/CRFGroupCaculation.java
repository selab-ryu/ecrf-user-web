package ecrf.user.crf.data.util;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.util.Validator;
import com.sx.icecap.service.DataTypeLocalServiceUtil;

import java.util.Iterator;

public class CRFGroupCaculation {
	private Log _log;
	
	public CRFGroupCaculation() {
		_log = LogFactoryUtil.getLog(this.getClass().getName());
	}
	
	public int getTotalLength(long dataTypeId) {
		int totalLength = 0;
		JSONArray crfForm = null;
		System.out.println(dataTypeId);
		try {
			String crfFormStr = DataTypeLocalServiceUtil.getDataTypeStructure(dataTypeId);
			JSONObject crfFormTmp = JSONFactoryUtil.createJSONObject(crfFormStr);
			crfForm = crfFormTmp.getJSONArray("terms");
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		if(Validator.isNotNull(crfForm)) {
			for(int k = 0; k < crfForm.length(); k++){
				if(!crfForm.getJSONObject(k).getString("termType").equals("Group")){
					totalLength++;
				}
			}
		}
		return totalLength;
	}
	
	public JSONObject getEachGroupProgress(long dataTypeId, JSONObject answerForm) {
		JSONArray crfForm = null;
		
		try {
			String crfFormStr = DataTypeLocalServiceUtil.getDataTypeStructure(dataTypeId);
			JSONObject crfFormTmp = JSONFactoryUtil.createJSONObject(crfFormStr);
			crfForm = crfFormTmp.getJSONArray("terms");
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		JSONObject termPackage = JSONFactoryUtil.createJSONObject();
		if(Validator.isNotNull(crfForm)) {
			for(int i = 0; i < crfForm.length(); i++) {
				if(crfForm.getJSONObject(i).getString("termType").equals("Group")) {
					if(!crfForm.getJSONObject(i).has("groupTermId")) {
						String groupName = crfForm.getJSONObject(i).getString("termName");
						termPackage.put(groupName, JSONFactoryUtil.createJSONObject());
					}
				}
			}
			
			Iterator<String> groupKeys = termPackage.keys();
			while(groupKeys.hasNext()) {
				String groupName = groupKeys.next();
				int terms = 0;
				int answers = 0;
				boolean hasSubGroup = false;
				JSONObject tempPackage = null;
				for(int k = 0; k < crfForm.length(); k++) {
					if(crfForm.getJSONObject(k).has("groupTermId")) {
						if(crfForm.getJSONObject(k).getJSONObject("groupTermId").getString("name").equals(groupName)){
							if(crfForm.getJSONObject(k).getString("termType").equals("Group")) {
								String subGroupName = crfForm.getJSONObject(k).getString("termName");
								hasSubGroup = true;
								for(int m = 0; m < crfForm.length(); m++) {
									if(crfForm.getJSONObject(m).has("groupTermId")){
										if(crfForm.getJSONObject(m).getJSONObject("groupTermId").getString("name").equals(subGroupName)){
											if(!crfForm.getJSONObject(m).getString("termType").equals("Group")) {
												terms++;
												if(answerForm.has(crfForm.getJSONObject(m).getString("termName"))) {
													answers++;
												}
											}										
										}
									}
								}
							}else {
								if(crfForm.getJSONObject(k).has("groupTermId")){
									if(crfForm.getJSONObject(k).getJSONObject("groupTermId").getString("name").equals(groupName)){
										if(!crfForm.getJSONObject(k).getString("termType").equals("Group")) {
											terms++;
											if(answerForm.has(crfForm.getJSONObject(k).getString("termName"))) {
												answers++;
											}
										}										
									}
								}
							}
						}
					}
				}
				tempPackage = termPackage.getJSONObject(groupName);
				tempPackage.put("total", answers + "/" + terms);
				tempPackage.put("percent", answers * 100 / terms + "%");
			}
		}
		
		System.out.println(termPackage.toJSONString());
		return termPackage;
	}
	
	public String getDisplayName(long dataTypeId, String termName) {
		JSONArray crfForm = null;
		try {
			String crfFormStr = DataTypeLocalServiceUtil.getDataTypeStructure(dataTypeId);
			JSONObject crfFormTmp = JSONFactoryUtil.createJSONObject(crfFormStr);
			crfForm = crfFormTmp.getJSONArray("terms");
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		String displayName = "";
		
		for(int i = 0; i < crfForm.length(); i++) {
			if(crfForm.getJSONObject(i).getString("termName").equals(termName)) {
				displayName = crfForm.getJSONObject(i).getJSONObject("displayName").getString("en_US");
			}
		}
		return displayName;
	}
}
