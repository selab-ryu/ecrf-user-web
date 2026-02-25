package ecrf.user.crf.command.render.data.dialog;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.PortalUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.sx.icecap.service.DataTypeLocalService;

import java.util.List;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.model.CRFHistory;
import ecrf.user.service.CRFHistoryLocalService;
import ecrf.user.service.CRFLocalService;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF,
	        "mvc.command.name="+ ECRFUserMVCCommand.RENDER_DIALOG_AUDIT,
	    },
	    service = MVCRenderCommand.class
	)

public class DialogAuditTrailRenderCommand implements MVCRenderCommand {
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException{
		_log.info("Render Dialog Audit");
		
		String termName = ParamUtil.getString(renderRequest, ECRFUserCRFDataAttributes.TERM_NAME);
		long subjectId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
		long sdId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.STRUCTURED_DATA_ID, 0);
		String displayName = ParamUtil.getString(renderRequest, ECRFUserCRFDataAttributes.DISPLAY_NAME);
		
		ThemeDisplay themeDisplay = (ThemeDisplay)renderRequest.getAttribute(WebKeys.THEME_DISPLAY);
		long groupId = ParamUtil.getLong(renderRequest, "groupId", 0);
		
		List<CRFHistory> crfHistoryList = _crfHistoryLocalService.getCRFHistoryByG_C_S_SD(groupId, crfId, subjectId, sdId);
    
		_log.info("groupId : " + groupId +"displayName : " + displayName + " subId : " + subjectId + " crfId : " + crfId + " sdId : "+ sdId);

		_log.info("history list size : " + crfHistoryList.size());
		
		
		JSONArray formArr = null;
		long dataTypeId = 0;
				
		if(crfId > 0) {
			try {
				dataTypeId = _crfLocalService.getDataTypeId(crfId);
				String crfFormStr = _dataTypeLocalService.getDataTypeStructure(dataTypeId);
				JSONObject jsonObject = JSONFactoryUtil.createJSONObject(crfFormStr);
				formArr = jsonObject.getJSONArray("terms");
			} catch (Exception e) {
				throw new PortletException("Cannot find subject : " + subjectId);
			}
		}
				
		JSONObject currentHistory = null;
		JSONObject previousHistory = null;
		String actionType = "";
		JSONArray specificTermArr = JSONFactoryUtil.createJSONArray();
		
		for(int i = 0; i < crfHistoryList.size(); i++) {
			JSONObject specificTerm = JSONFactoryUtil.createJSONObject();
			long userId = crfHistoryList.get(i).getUserId();
			String currentHistoryStr = crfHistoryList.get(i).getCurrentJSON();
			String previousHistoryStr = crfHistoryList.get(i).getPreviousJSON();
			try {
				currentHistory = JSONFactoryUtil.createJSONObject(currentHistoryStr);
				previousHistory = JSONFactoryUtil.createJSONObject(previousHistoryStr);
			} catch (Exception e) {
				e.printStackTrace();
			}
			
			JSONObject curTerm = searchArrObj(formArr, "termName", termName);
			String termType = curTerm.getString("termType");
			
			if(currentHistory.has(termName) && !previousHistory.has(termName)) {
				actionType = "add";
				specificTerm.put("displayName", displayName);
				specificTerm.put("modifiedDate", crfHistoryList.get(i).getCreateDate());
				specificTerm.put("curValue", currentHistory.getString(termName));
				if(termType.equals("List")) {
					String val = getOptionValue(currentHistory.getString(termName));
					// TODO: get list option's label
				}
				String userEmail = PortalUtil.getUserEmailAddress(userId);
				specificTerm.put("userName", crfHistoryList.get(i).getUserName());
				specificTerm.put("userId", userEmail);
				specificTerm.put("preValue", "");
				specificTerm.put("preLabel", "");
				specificTerm.put("actionType", actionType);
				specificTermArr.put(specificTerm);
			}else if(currentHistory.has(termName) && previousHistory.has(termName)) {
				if(!currentHistory.getString(termName).equals(previousHistory.getString(termName))) {
					actionType = "edit";
					specificTerm.put("displayName", displayName);
					specificTerm.put("modifiedDate", crfHistoryList.get(i).getCreateDate());
					specificTerm.put("preValue", previousHistory.getString(termName));
					specificTerm.put("curValue", currentHistory.getString(termName));
					String userEmail = PortalUtil.getUserEmailAddress(userId);
					specificTerm.put("userName", crfHistoryList.get(i).getUserName());
					specificTerm.put("userId", userEmail);
					specificTerm.put("actionType", actionType);
					specificTermArr.put(specificTerm);
				}
			}
		}		
				
		renderRequest.setAttribute("JsonArr", specificTermArr);
		
		return ECRFUserJspPaths.JSP_DIALOG_CRF_DATA_AUDIT;
	} 
	
	// pre-process list options value
	private String getOptionValue(String value) {
		// remove [, ], \"
		value = value.replaceAll("\"", "");
		value = value.replaceAll("\\[", "");
		value = value.replaceAll("\\]", "");
		value.trim();
		
		return value;
	}
	
	// get option's label
	private String getOptionLabel(JSONObject term, String value) {
		return "";
	}
	
	private JSONObject searchArrObj(JSONArray arr, String key, String value) {		
		for (int i = 0; i < arr.length(); i++) {
            JSONObject jsonObject = arr.getJSONObject(i);
            if (jsonObject.has(key) && jsonObject.getString(key).equals(value)) {
                return jsonObject;
            }
        }
		return null;
	}
	
	private Log _log = LogFactoryUtil.getLog(DialogAuditTrailRenderCommand.class);
	
	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private CRFHistoryLocalService _crfHistoryLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
}
