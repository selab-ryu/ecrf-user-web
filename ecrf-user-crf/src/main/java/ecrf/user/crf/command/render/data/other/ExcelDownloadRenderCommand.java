package ecrf.user.crf.command.render.data.other;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONException;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;
import com.sx.icecap.model.StructuredData;
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
		//_log.info("Download: " + searchLogId.isEmpty());
		if(!searchLogId.isEmpty()) {
			try {
				searchLog = _crfSearchLogLocalService.getCRFSearchLog(Long.parseLong(searchLogId)).getSearchLog();
			}catch (Exception e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
		

		String[] options = null;
		List<String> searchSdIds = null;
		
		if(!searchLogId.isEmpty()) {
			try {

				JSONObject before_option = JSONFactoryUtil.createJSONObject(searchLog);
				String option = String.valueOf(before_option.get("query")).replace("(", "").replace(")", "");
				
				options = option.split("\\s+OR\\s+|\\s+AND\\s+");
				
				String searchSdId = String.valueOf(before_option.get("hits")).replace("[", "").replace("]", "").replace("\"", "").replace(",", " ");
				
				searchSdIds = Arrays.asList(searchSdId.split(" "));
			} catch (Exception e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
		
		String json = "";
		try {
			json = _dataTypeLocalService.getDataTypeStructure(dataTypeId);
		} catch (Exception e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		
		ThemeDisplay themeDisplay = (ThemeDisplay)renderRequest.getAttribute(WebKeys.THEME_DISPLAY);
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    		
		List<LinkCRF> allLinkCRFList = _linkCRFLocalService.getLinkCRFByG_C(themeDisplay.getScopeGroupId(), crfId);
		JSONArray subJsons = JSONFactoryUtil.createJSONArray();
		JSONArray ansJsons = JSONFactoryUtil.createJSONArray();
		
		for(LinkCRF i : allLinkCRFList) {
			Subject subject = null;
			Boolean flag = true;
			
			if(!searchLogId.isEmpty() && !(searchSdIds.contains(String.valueOf(i.getStructuredDataId())))) {
				flag = false;
			}
      
			if(flag) {
				try {
					subject = _subjectLocalService.getSubject(i.getSubjectId());
					
					JSONObject subJson = JSONFactoryUtil.createJSONObject();
					subJson.put("ID", subject.getSerialId());
					subJson.put("Name", subject.getName());
					subJson.put("Age", (Math.abs(124 - subject.getBirth().getYear())));
					subJson.put("Sex", subject.getGender());
					subJson.put("LinkId", i.getStructuredDataId());
					subJsons.put(subJson);
					
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
			    } catch(PortalException e) {
            e.printStackTrace();
        }
			}
		}

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

    JSONArray fin_subJsons = JSONFactoryUtil.createJSONArray();
		JSONArray fin_ansJsons = JSONFactoryUtil.createJSONArray();

		for(int i = 0; i < subJsons.length(); i++) {
			JSONObject fin_subJson = JSONFactoryUtil.createJSONObject();
			
			fin_subJson.put("ID", jsonValues.get(i).get("ID"));
			fin_subJson.put("Name", jsonValues.get(i).get("Name"));
			fin_subJson.put("Age", jsonValues.get(i).get("Age"));
			fin_subJson.put("Sex", jsonValues.get(i).get("Sex"));
			fin_subJsons.put(fin_subJson);
			
			JSONObject fin_ansObj =  JSONFactoryUtil.createJSONObject();
			
			for(int j = 0; j < ansJsons.length(); j++) {
				if(jsonValues.get(i).get("LinkId").equals(ansJsons.getJSONObject(j).get("LinkId"))) {
					ansJsons.getJSONObject(j).remove("LinkId");
					fin_ansObj = ansJsons.getJSONObject(j);
					break;
				}
			}
			
			fin_ansJsons.put(fin_ansObj);
		}
    
		for(int i = 0; i < fin_subJsons.length(); i++) {
			_log.info("fin_subJsons: " + fin_subJsons.getJSONObject(i));
		}
        
		for(int i = 0; i < fin_ansJsons.length(); i++) {
			_log.info("fin_ansJsons: " + fin_ansJsons.getJSONObject(i));
		}
        
		renderRequest.setAttribute("subjectJson", fin_subJsons.toJSONString());
		renderRequest.setAttribute("answerJson", fin_ansJsons.toJSONString());
		renderRequest.setAttribute("json", json);
        
		if(!searchLogId.isEmpty()) {
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
