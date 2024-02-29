package ecrf.user.crf.data.command.render.other;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Validator;
import com.sx.icecap.service.DataTypeLocalService;

import java.util.Date;
import java.util.Iterator;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserAttributes;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.model.CRF;
import ecrf.user.model.CRFHistory;
import ecrf.user.model.Subject;
import ecrf.user.service.CRFHistoryLocalService;
import ecrf.user.service.CRFLocalService;
import ecrf.user.service.SubjectLocalService;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF_DATA,
	        "mvc.command.name=" + ECRFUserMVCCommand.RENDER_VIEW_CRF_DATA_HISTORY,
	    },
	    service = MVCRenderCommand.class
	)
public class ViewHistoryRenderCommand implements MVCRenderCommand {
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException{
		
		long historyId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.HISTORY_ID);
		long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID);
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.CRF_ID);
		long dataTypeId = 0;
				
		Subject subject = null;
		CRFHistory history = null;
		CRF crf = null;
		String crfFormStr = "";
		JSONObject crfForm = null;
		
		try {
			subject = _subjectLocalService.getSubject(subjectId);
			history = _historyLocalService.getCRFHistory(historyId);
			crf = _crfLocalService.getCRF(crfId);
			dataTypeId = crf.getDatatypeId();
			
			if(dataTypeId > 0) {
				crfFormStr = _dataTypeLocalService.getDataTypeStructure(dataTypeId);
			}
			
			if(Validator.isNotNull(crfFormStr)) {
				crfForm = JSONFactoryUtil.createJSONObject(crfFormStr);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}		
		
		JSONArray crfFormArr = crfForm.getJSONArray("terms");
		
		String current = "";
		String previous = "";
		Date createDate = null;
		
		JSONObject currentJson = null;
		JSONObject previousJson = null;
		String[][] termList = null;

		if(Validator.isNotNull(history)) {
			current = history.getCurrentJSON();
			previous = history.getPreviousJSON();
			createDate = history.getCreateDate();
		
			try {
				currentJson = JSONFactoryUtil.createJSONObject(current);
				previousJson = JSONFactoryUtil.createJSONObject(previous);
			} catch (Exception e) {
				e.printStackTrace();
			}
			
			int previousLength = 0;
			if(Validator.isNotNull(previous)) {
				previousLength = previousJson.length();
			}
			
			if(currentJson.length() > previousLength) {
				termList = new String[currentJson.length()][4];
			}else {
				termList = new String[previousJson.length()][4];
			}
			
			Iterator<String> currentKeys = currentJson.keys();
			Iterator<String> previousKeys = previousJson.keys();
			
			int count = 0;
			while(currentKeys.hasNext()) {
				String currentKey = currentKeys.next();
				if(!previousJson.has(currentKey)) {
					//add
					String displayName = getDisplayName(crfFormArr, currentKey);
					termList[count][0] = displayName;
					termList[count][1] = "";
					termList[count][2] = getOptionValue(crfFormArr, currentKey, currentJson.getString(currentKey));
					termList[count][3] = "add";
//					_log.info(count + ": " + currentJson.getString(currentKey));
//					_log.info(count + ": " + termList[count][0] + " / " + termList[count][1] + " / " + termList[count][2] + " / " + termList[count][3]);
					count++;
				}else {
					while(previousKeys.hasNext()) {
						String previousKey = previousKeys.next();
						if(previousKey.equals(currentKey)) {
							//edit and delete
							if(!previousJson.getString(previousKey).equals(currentJson.getString(currentKey))) {
								String displayName = getDisplayName(crfFormArr, currentKey);
								termList[count][0] = displayName;
								termList[count][1] = getOptionValue(crfFormArr, previousKey, previousJson.getString(previousKey));
								termList[count][2] = getOptionValue(crfFormArr, currentKey, currentJson.getString(currentKey));
								if(termList[count][2].equals("") || termList[count][2].equals("[]")) {
									termList[count][3] = "delete";
								}else {
									termList[count][3] = "edit";
								}
								_log.info(count + ": " + termList[count][0] + " / " + termList[count][1] + " / " + termList[count][2] + " / " + termList[count][3]);
								count++;
							}
							break;
						}
					}
				}
			}
			
			renderRequest.setAttribute(ECRFUserCRFDataAttributes.TERM_LIST, termList);
			renderRequest.setAttribute(ECRFUserCRFDataAttributes.SUBJECT, subject);
			renderRequest.setAttribute(ECRFUserAttributes.CREATE_DATE, createDate);
		}

		return ECRFUserJspPaths.JSP_CRF_DATA_VIEW_HISTORY;
	}
	
	private String getDisplayName(JSONArray crfFormArr, String key) {
		String displayName = "";
		for(int k = 0; k < crfFormArr.length(); k++) {
			if(crfFormArr.getJSONObject(k).getString("termName").equals(key)) {
				displayName = crfFormArr.getJSONObject(k).getJSONObject("displayName").getString("en_US");
			}
		}
		return displayName;
	}
	
	private String getOptionValue(JSONArray crfFormArr, String key, String value) {
		for(int k = 0; k < crfFormArr.length(); k++) {
			if(crfFormArr.getJSONObject(k).getString("termName").equals(key)) {
				if(crfFormArr.getJSONObject(k).getString("termType").equals("List")) {
					try {
						JSONArray jsonArr = JSONFactoryUtil.createJSONArray(value);
//						_log.info(jsonArr.get(0));
						value = jsonArr.getString(0);
					} catch (Exception e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					JSONArray optionArr = crfFormArr.getJSONObject(k).getJSONArray("options");
					for(int j = 0; j < optionArr.length(); j++) {
						if(optionArr.getJSONObject(j).getString("value").equals(value)) {
							value = optionArr.getJSONObject(j).getJSONObject("label").getString("en_US");
						}
					}
				}
			}
		}
		return value;
	}
	
	private Log _log = LogFactoryUtil.getLog(ViewHistoryRenderCommand.class);
	
	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	private CRFHistoryLocalService _historyLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;

}
