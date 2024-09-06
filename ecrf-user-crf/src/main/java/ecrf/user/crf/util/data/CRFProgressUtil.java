package ecrf.user.crf.util.data;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.util.Validator;
import com.sx.icecap.service.DataTypeLocalServiceUtil;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;

import javax.portlet.RenderRequest;

public class CRFProgressUtil {
	private Log _log = LogFactoryUtil.getLog(this.getClass().getName());

	private long dataTypeId;
	private RenderRequest utilRenderRequest;
	private JSONObject answerForm;
	
	public CRFProgressUtil(RenderRequest renderRequest, long dataTypeId, JSONObject answerObj) {
		_log = LogFactoryUtil.getLog(this.getClass().getName());

		this.utilRenderRequest = renderRequest;
		this.dataTypeId = dataTypeId;
		this.answerForm = answerObj;
		_log.info("CRFProgressUtil loaded");
	}
	
	/*
	 * Export Functions
	 */
	
	public int getProgressPercentage() {
		int progressPercent = 0;
		JSONArray crfForm = getCRFForm();
		if(Validator.isNotNull(crfForm)) {
			int totalLength = crfForm.length();
			JSONObject activeTermsPackage = getActiveTermPackage(crfForm);
			totalLength = calculateActiveTermsNum(activeTermsPackage, totalLength);
			progressPercent = answerForm.length() * 100 / totalLength ;
		}
		
		return progressPercent;
	}
	
	public String getProgressImg(int percent, boolean hasQuery) {
		String imgURL = utilRenderRequest.getContextPath() + "/img/empty_progress.png";
		if(percent >= 100){
			imgURL = utilRenderRequest.getContextPath()+"/img/complete_progress.png";
			if(hasQuery){
				imgURL = utilRenderRequest.getContextPath()+"/img/complete_autoqueryerror.png";
			}
			
		}else {
			imgURL = utilRenderRequest.getContextPath()+"/img/incomplete_progress.png";
			if(hasQuery){
				imgURL = utilRenderRequest.getContextPath()+"/img/incomplete_autoqueryerror.png";
			}
		}
							
		return imgURL;
	}
	
	public String getProgressByGroup() {
		String eachGroupProcess = "";
		JSONArray groupTermPackage = getGroupTerms(getCRFForm());
		//TODO: display name function makeup
		for(int count = 0; count < groupTermPackage.length(); count++) {
			int percent = groupTermPackage.getJSONObject(count).getInt("answers") * 100 / groupTermPackage.getJSONObject(count).getInt("terms");
			String termDisplayName = getDisplayName(groupTermPackage.getJSONObject(count).getString("termName"), getCRFForm());
			eachGroupProcess += termDisplayName + "> " + groupTermPackage.getJSONObject(count).getInt("answers") + "/" + groupTermPackage.getJSONObject(count).getInt("terms") + " (" + percent + "%) ";
		}
		return eachGroupProcess;
	}
	
	/*
	 * private methods
	 */
	
	private JSONArray getCRFForm() {
		JSONArray crfForm = null;
		try {
			String crfFormStr = DataTypeLocalServiceUtil.getDataTypeStructure(dataTypeId);
			JSONObject crfFormTmp = JSONFactoryUtil.createJSONObject(crfFormStr);
			crfForm = crfFormTmp.getJSONArray("terms");
		} catch (Exception e) {
			e.printStackTrace();
		}
		crfForm = sortJSONByOrder(crfForm);

		return crfForm;
	}
	
	private JSONArray sortJSONByOrder(JSONArray crfForm) {
		JSONArray sortedCrfForm = JSONFactoryUtil.createJSONArray();
		
		List<JSONObject> jsonList = new ArrayList<>();
        for (int i = 0; i < crfForm.length(); i++) {
            jsonList.add(crfForm.getJSONObject(i));
        }

        Collections.sort(jsonList, new Comparator<JSONObject>() {
            @Override
            public int compare(JSONObject a, JSONObject b) {
                return Integer.compare(a.getInt("order"), b.getInt("order"));
            }
        });
        for (JSONObject jsonObj : jsonList) {
        	sortedCrfForm.put(jsonObj);
        }
        return sortedCrfForm;
	}
	
	private JSONObject getActiveTermPackage(JSONArray crfForm){
		JSONObject activeTermPackage = JSONFactoryUtil.createJSONObject();
		for(int objIdx = 0; objIdx < crfForm.length(); objIdx++) {
			JSONObject term = crfForm.getJSONObject(objIdx);
			if(term.getString("termType").equals("List") || term.getString("termType").equals("Boolean")) {
				JSONObject slaveTermPackage = JSONFactoryUtil.createJSONObject();
				String activeTermName = "";
				List<String> slaveTermList = new ArrayList<String>();
				int activeTermLength = 0;
				if(term.has("options")) {
					JSONArray options = term.getJSONArray("options");
					for(int optIdx = 0; optIdx < options.length(); optIdx++) {
						JSONObject option = options.getJSONObject(optIdx);
						if(option.has("slaveTerms")) {
							activeTermName = term.getString("termName");
							slaveTermList.add(option.getString("value"));
							activeTermLength++;
							JSONArray slaveTermsList = option.getJSONArray("slaveTerms");
							
							//for group term compare
							String compareGroupTermName = "";
							for(int slaveIdx = 0; slaveIdx < slaveTermsList.length(); slaveIdx++) {
								String slaveName = slaveTermsList.getString(slaveIdx);
								for(int compareIdx = 0; compareIdx < crfForm.length(); compareIdx++) {
									JSONObject compareTerm = crfForm.getJSONObject(compareIdx);
									if(compareTerm.getString("termName").equals(slaveName)) {
										if(compareTerm.getString("termType").equals("Group")) {
											compareGroupTermName = compareTerm.getString("termName");
										}
									}
								}
								
								for(int countIdx = 0; countIdx < crfForm.length(); countIdx++) {
									JSONObject compareTerm = crfForm.getJSONObject(countIdx);
									if(compareTerm.has("groupTermId") && compareTerm.getJSONObject("groupTermId").getString("name").equals(compareGroupTermName)) {
										activeTermLength++;
									}
								}
							}
							slaveTermPackage.put("length", activeTermLength);
							slaveTermPackage.put("values", slaveTermList);
						}
					}
					
					if(!activeTermName.equals("")) activeTermPackage.put(activeTermName, slaveTermPackage);
				}
			}
		}
		return activeTermPackage;
	}
	
	private JSONArray getGroupTerms(JSONArray crfForm){
		JSONArray groupTermPackage = JSONFactoryUtil.createJSONArray();
		//TODO: group term list string make up
		String groupTermName = "";
		int count = 0;
		for(int crfIdx = 0; crfIdx < crfForm.length(); crfIdx++) {
			int terms = 0;
			int answers = 0;
			JSONObject groupTermData = JSONFactoryUtil.createJSONObject();
			JSONObject term = crfForm.getJSONObject(crfIdx);
			if(term.getString("termType").equals("Group") && !term.has("groupTermId")) {
				for(int i = 0; i < crfForm.length(); i++) {
					JSONObject compareTerm = crfForm.getJSONObject(i);
					if(compareTerm.has("groupTermId") && compareTerm.getJSONObject("groupTermId").getString("name").equals(term.getString("termName"))) {
						if(compareTerm.getString("termType").equals("Group")) {
							terms--;
							String subGroupId = compareTerm.getString("termName");
							for(int j = 0; j < crfForm.length(); j++) {
								JSONObject innerTerm = crfForm.getJSONObject(j);
								if(innerTerm.has("groupTermId") && innerTerm.getJSONObject("groupTermId").getString("name").equals(subGroupId)) {
									if(innerTerm.getString("termType").equals("Group")) {
										terms--;
									}else {
										terms++;
										if(answerForm.has(innerTerm.getString("termName"))) answers++;											
									}
								}
							}
						}else {
							terms++;
							if(answerForm.has(compareTerm.getString("termName"))) answers++;											
						}
					}
				}
				count++;
				groupTermData.put("order", count);
				groupTermData.put("terms", terms);
				groupTermData.put("answers", answers);
				groupTermData.put("termName", term.getString("termName"));
				groupTermPackage.put(groupTermData);
			}
		}
		groupTermPackage = sortJSONByOrder(groupTermPackage);
		return groupTermPackage;
	}
	
	private int calculateActiveTermsNum(JSONObject activeTermsPackage, int totalLength) {
		int calculatedLength = totalLength;
		Iterator<String> activeTermIter = activeTermsPackage.keys();
		Iterator<String> answerTermIter = answerForm.keys();
		List<String> activeTermNames = new ArrayList<String>();
		List<String> answerTermNames = new ArrayList<String>();
		while(activeTermIter.hasNext()) {
			String activeTermKey = activeTermIter.next();
			activeTermNames.add(activeTermKey);
		}
		
		while(answerTermIter.hasNext()) {
			String answerTermKey = answerTermIter.next();
			answerTermNames.add(answerTermKey);
		}
		for(String activeTermName : activeTermNames) {
			for(String answerTermName: answerTermNames) {
				if(activeTermName.equals(answerTermName)){
					calculatedLength -= activeTermsPackage.getJSONObject(activeTermName).getInt("length");
				}
			}
		}
		return calculatedLength;
	}
	
	private String getDisplayName(String termName, JSONArray crfForm) {
		String displayName = "";
		for(int i = 0; i < crfForm.length(); i++) {
			if(termName.equals(crfForm.getJSONObject(i).getString("termName"))) {
				displayName = crfForm.getJSONObject(i).getJSONObject("displayName").getString("en_US");
			}
		}
		return displayName;
	}
}
