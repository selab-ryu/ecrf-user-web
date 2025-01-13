package ecrf.user.crf.util.data;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.util.Validator;
import com.sx.icecap.service.DataTypeLocalServiceUtil;

import java.util.Iterator;

public class CRFGroupCaculation {
	private Log _log = LogFactoryUtil.getLog(this.getClass().getName());
	
	public CRFGroupCaculation() {
		//_log = LogFactoryUtil.getLog(this.getClass().getName());
	}
	
	public int getTotalLength(long dataTypeId) {
		int totalLength = 0;
		JSONArray crfForm = null;
		//_log.info(dataTypeId);
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
			
			_log.info(termPackage.toJSONString());
			
			// TODO: need to analyze
			Iterator<String> groupKeys = termPackage.keys();	// group name iterator
			while(groupKeys.hasNext()) {	// each by group 'G'
				String groupName = groupKeys.next();
				int terms = 0;
				int answers = 0;
				boolean hasSubGroup = false;
				JSONObject tempPackage = null;
				
				// check 2nd depth group
				// what if group has more group? => terms variable value is zero
				for(int k = 0; k < crfForm.length(); k++) {	// each by all term | term 'T'
					if(crfForm.getJSONObject(k).has("groupTermId")) {	// T has groupTermId => group's slave term
						if(crfForm.getJSONObject(k).getJSONObject("groupTermId").getString("name").equals(groupName)){	// T's master group is matched to G
							if(crfForm.getJSONObject(k).getString("termType").equals("Group")) {	// T is also group => 2-depth
								String subGroupName = crfForm.getJSONObject(k).getString("termName");	// sub group name (T)
								hasSubGroup = true;
								for(int m = 0; m < crfForm.length(); m++) {		// each by all term
									if(crfForm.getJSONObject(m).has("groupTermId")){	// term T2 has groupTermId => group's slave term
										if(crfForm.getJSONObject(m).getJSONObject("groupTermId").getString("name").equals(subGroupName)){	 // T2's master group is matched to T(sub group)
											if(!crfForm.getJSONObject(m).getString("termType").equals("Group")) {	// T2 is not group
												terms++;
												if(answerForm.has(crfForm.getJSONObject(m).getString("termName"))) {	// T2 has value
													answers++;
												}
											}										
										}
									}
								}
							}else {	// T is not group
								if(crfForm.getJSONObject(k).has("groupTermId")){	// T has master group 
									if(crfForm.getJSONObject(k).getJSONObject("groupTermId").getString("name").equals(groupName)){	// T's master group is matched to G
										terms++;
										if(answerForm.has(crfForm.getJSONObject(k).getString("termName"))) {	// T has value
											answers++;
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
				if(terms > 0) {
					
				} else {
					
				}
				
			}
		}
		
		//_log.info(termPackage.toJSONString());
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
