package ecrf.user.crf.command.render.data.other;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.sx.icecap.service.DataTypeLocalService;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
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
import ecrf.user.model.LinkCRF;
import ecrf.user.model.Subject;
import ecrf.user.service.CRFLocalService;
import ecrf.user.service.CRFSearchLogLocalService;
import ecrf.user.service.CRFSubjectLocalService;
import ecrf.user.service.LinkCRFLocalService;
import ecrf.user.service.SubjectLocalService;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF,
	        "mvc.command.name=" + ECRFUserMVCCommand.RENDER_CRF_DATA_EXCEL_DOWNLOAD,
	    },
	    service = MVCRenderCommand.class
	)

public class ExcelDownloadRenderCommand implements MVCRenderCommand{
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException{
		_log.info("Render Excel Download");
		
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
		long dataTypeId = _crfLocalService.getDataTypeId(crfId);
		
		String searchLogId = ParamUtil.getString(renderRequest, "searchLogId");
		String searchLog = null;
		
		// If Search Data (when there is an option set)
		boolean isSearch = false;
		
		if(!(searchLogId.isEmpty())) {
			isSearch = true;
		}
		// End
		
		// Variables to capture preprocessed options in integrated searches
		String[] options = null;
		List<String> searchSdIds = null;
		
		if(isSearch) {
			_log.info("If Search Data, Get the Options User Set");
			try {
				searchLog = _crfSearchLogLocalService.getCRFSearchLog(Long.parseLong(searchLogId)).getSearchLog();
				
				_log.info("0.1. Hand Out Option Items");
				JSONObject before_option = JSONFactoryUtil.createJSONObject(searchLog);
				
				// Task of handing out options
				String option = String.valueOf(before_option.get("query"));
				option = option.replace("(", "");
				option = option.replace(")", "");
				
				options = option.split("\\s+OR\\s+|\\s+AND\\s+");
				// End
				
				// Distribute the sdId of the patient who meets the conditions
				String searchSdId = String.valueOf(before_option.get("hits"));
				searchSdId = searchSdId.replace("[", "");
				searchSdId = searchSdId.replace("]", "");
				searchSdId = searchSdId.replace("\"", "");
				
				searchSdIds = Arrays.asList(searchSdId.split(","));
				// End
				_log.info("0.1. End");
			}catch (Exception e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
		// End

		String json = "";
		try {
			_log.info("0.2. Get JSON For CRF");
			json = _dataTypeLocalService.getDataTypeStructure(dataTypeId);
			_log.info("0.2. End");
		} catch (Exception e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		
		
		ThemeDisplay themeDisplay = (ThemeDisplay)renderRequest.getAttribute(WebKeys.THEME_DISPLAY);
		//SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    	
		// Get LinkCRF for CRF
		List<LinkCRF> allLinkCRFList = _linkCRFLocalService.getLinkCRFByG_C(themeDisplay.getScopeGroupId(), crfId);
		JSONArray subJsons = JSONFactoryUtil.createJSONArray();
		JSONArray ansJsons = JSONFactoryUtil.createJSONArray();
		
		_log.info("0.3. Get Patient Information, Answer Data and Put it in");
		for(LinkCRF i : allLinkCRFList) {
			Subject subject = null;

			// 1. searchLogId is not empty (select option) 2. not a patient who meets the conditions
			if(isSearch && !(searchSdIds.contains(String.valueOf(i.getStructuredDataId())))) {
				continue;
			}
			else {
				try {
					// Get patient information and put it in
					subject = _subjectLocalService.getSubject(i.getSubjectId());
					JSONObject subJson = JSONFactoryUtil.createJSONObject();
					subJson.put("ID", subject.getSerialId());
					subJson.put("Name", subject.getName());
					subJson.put("Age", (Math.abs(124 - subject.getBirth().getYear())));
					subJson.put("Sex", subject.getGender());
					subJson.put("LinkId", i.getStructuredDataId());
					subJsons.put(subJson);
					// End
					
					// Get patient Answer and put it in
					String str_sd = _dataTypeLocalService.getStructuredData(i.getStructuredDataId());
					JSONObject ansObj =  JSONFactoryUtil.createJSONObject();
          
					try {
						ansObj = JSONFactoryUtil.createJSONObject(str_sd);
						ansObj.put("ID", subject.getSerialId());
						ansObj.put("LinkId", i.getStructuredDataId());
					} catch (Exception e) {
						e.printStackTrace();
					}
          
					ansJsons.put(ansObj);
					// End
			    } catch(PortalException e) {
		            e.printStackTrace();
		        }
			}
		}
		_log.info("0.3. End");
		
		// Sort it in order of name
		List<JSONObject> jsonValues = new ArrayList<JSONObject>();
	    for (int i = 0; i < subJsons.length(); i++) {
	        jsonValues.add(subJsons.getJSONObject(i));
	    }
    
	    Collections.sort( jsonValues, new Comparator<JSONObject>() {
	    	@Override
	        public int compare(JSONObject a, JSONObject b) {
	    		String valA = a.getString("Name");
	            String valB = b.getString("Name");
	
	            return valA.compareTo(valB);
	        }
	    });
	    // End

	    // Put the data that I put in after sorting it out
	    JSONArray fin_subJsons = JSONFactoryUtil.createJSONArray();
		JSONArray fin_ansJsons = JSONFactoryUtil.createJSONArray();
		
		_log.info("0.4. put the data");	
		for(int i = 0; i < subJsons.length(); i++) {
			JSONObject fin_subJson = JSONFactoryUtil.createJSONObject();
			
			fin_subJson.put("ID", jsonValues.get(i).get("ID"));
			fin_subJson.put("Name", jsonValues.get(i).get("Name"));
			fin_subJson.put("Age", jsonValues.get(i).get("Age"));
			fin_subJson.put("Sex", jsonValues.get(i).get("Sex"));
			fin_subJsons.put(fin_subJson);
			
			JSONObject fin_ansObj =  JSONFactoryUtil.createJSONObject();
			
			// Remove key value to fit patient information
			for(int j = 0; j < ansJsons.length(); j++) {
				if(jsonValues.get(i).get("LinkId").equals(ansJsons.getJSONObject(j).get("LinkId"))) {
					ansJsons.getJSONObject(j).remove("LinkId");
					fin_ansObj = ansJsons.getJSONObject(j);
					break;
				}
			}
			
			fin_ansJsons.put(fin_ansObj);
			// End
		}
		// End
		_log.info("0.4. End");
		
		renderRequest.setAttribute("subjectJson", fin_subJsons.toJSONString());
		renderRequest.setAttribute("answerJson", fin_ansJsons.toJSONString());
		renderRequest.setAttribute("json", json);
        
		if(isSearch) {
			renderRequest.setAttribute("options", String.join(",", options));
		}
		else {
			renderRequest.setAttribute("options", "noSearch");
		}

		return ECRFUserJspPaths.JSP_CRF_DATA_EXCEL_DOWNLOAD;
	}
	
	private Log _log = LogFactoryUtil.getLog(ExcelDownloadRenderCommand.class);
	
	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
	
	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	LinkCRFLocalService _linkCRFLocalService;
	
	@Reference
	private CRFSubjectLocalService _crfSubjectLocalService;
	
	@Reference
	private CRFSearchLogLocalService _crfSearchLogLocalService;
}
