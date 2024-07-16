package ecrf.user.crf.command.render.data.other;

import com.liferay.portal.kernel.json.JSONArray;
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

import java.text.SimpleDateFormat;
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
		
		//String[] searchSdIds = (String[])renderRequest.getAttribute(ECRFUserCRFDataAttributes.STRUCTURED_DATA_LIST);
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
		long dataTypeId = _crfLocalService.getDataTypeId(crfId);
		
		//String searchLogId = ParamUtil.getString(renderRequest, "searchLogId");
		String searchLog = ParamUtil.getString(renderRequest, "searchLog");
		String[] options = null;
		String[] searchSdIds = null;
		if(!searchLog.isEmpty()) {
			_log.info("excelPackage : " + searchLog);
			
			try {
				JSONObject obj_searchLog = JSONFactoryUtil.createJSONObject(searchLog);
				String real_searchLog = String.valueOf(obj_searchLog.get("searchLog"));
				JSONObject before_option = JSONFactoryUtil.createJSONObject(real_searchLog);
				String option = String.valueOf(before_option.get("query")).replace("(", "").replace(")", "");
				
				options = option.split("\\s+OR\\s+|\\s+AND\\s+");
				
				String searchSdId = String.valueOf(before_option.get("hits")).replace("[", "").replace("]", "").replace("\"", "").replace(",", " ");
				
				searchSdIds = searchSdId.split(" ");
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
		
		List<Subject> allSub = _subjectLocalService.getAllSubject();
		JSONArray subJsons = JSONFactoryUtil.createJSONArray();
		JSONArray ansJsons = JSONFactoryUtil.createJSONArray();
		
		for(int i = 0; i < allSub.size(); i++) {
			List<LinkCRF> tmpLinkList = null;
	        try {
	        	tmpLinkList = _linkCRFLocalService.getLinkCRFBySubjectId(allSub.get(i).getSubjectId());
	        	if(tmpLinkList.size() > 0) {
	        		LinkCRF tmpLink = tmpLinkList.get(0);
		            if(crfId != tmpLink.getCrfId()) {
		               continue;
		            }
	         	}
	         } catch (Exception e) {
	            e.printStackTrace();
	         }
			
			if(!searchLog.isEmpty()) {
				Boolean flag = false;
				for(String sdId : searchSdIds) {
					LinkCRF tmplink = null;
					try {
						tmplink = _linkCRFLocalService.getLinkCRFByStructuredDataId(Long.parseLong(sdId));
						if(allSub.get(i).getSubjectId() == tmplink.getSubjectId()) {
							flag = true;
							break;
						}
						//_log.info("link : " + link.getSubjectId());
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
				if(flag == false) {
					continue;
				}
			}
			//_log.info("allSub : " + allSub);
			JSONObject subJson = JSONFactoryUtil.createJSONObject();
			Subject subTemp = allSub.get(i);
			subJson.put("ID", subTemp.getSerialId());
			subJson.put("Name", subTemp.getName());
			subJson.put("Age", (Math.abs(124 - subTemp.getBirth().getYear())));
			subJson.put("Sex", subTemp.getGender());
			subJsons.put(subJson);
			
			if(_linkCRFLocalService.countLinkBySubjectId(subTemp.getSubjectId()) > 0) {
				List<LinkCRF> linkList = _linkCRFLocalService.getLinkCRFByG_S_C(themeDisplay.getScopeGroupId(), subTemp.getSubjectId(), crfId);
				LinkCRF link = linkList.get(0);				
				String ansTemp = _dataTypeLocalService.getStructuredData(link.getStructuredDataId());
				JSONObject ansObj =  null;
				try {
					 ansObj = JSONFactoryUtil.createJSONObject(ansTemp);
					 ansObj.put("ID", subTemp.getSerialId());
				} catch (Exception e) {
					e.printStackTrace();
				}
				//ansJsons.put(subTemp.getSerialId());
				ansJsons.put(ansObj);
			}
		}
		renderRequest.setAttribute("subjectJson", subJsons.toJSONString());
		renderRequest.setAttribute("answerJson", ansJsons.toJSONString());
		renderRequest.setAttribute("json", json);
		if(!searchLog.isEmpty()) {
			renderRequest.setAttribute("options", String.join(",", options));
		}
		else {
			renderRequest.setAttribute("options", "noSearch");
		}
		
		
		return ECRFUserJspPaths.JSP_CRF_DATA_EXCEL_DOWNLOAD;
		/*_log.info("Render Excel Download");
		
		//String[] searchSdIds = (String[])renderRequest.getAttribute(ECRFUserCRFDataAttributes.STRUCTURED_DATA_LIST);
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
		long dataTypeId = _crfLocalService.getDataTypeId(crfId);
		
		String searchLogId = ParamUtil.getString(renderRequest, "searchLogId");
		String excelPackage = ParamUtil.getString(renderRequest, "excelPackage");
		
		_log.info("sibal1: " + searchLogId);
		_log.info("sibal2: " + excelPackage);
		
		String json = "";
		try {
			json = _dataTypeLocalService.getDataTypeStructure(dataTypeId);
		} catch (Exception e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		
		List<Subject> allSub = _subjectLocalService.getAllSubject();
		JSONArray subJsons = JSONFactoryUtil.createJSONArray();
		JSONArray ansJsons = JSONFactoryUtil.createJSONArray();
		
		JSONObject before_option = null;
		try {
			before_option = JSONFactoryUtil.createJSONObject(excelPackage);
		} catch (Exception e2) {
			// TODO Auto-generated catch block
			e2.printStackTrace();
		}
		System.out.println(before_option);
		String option = String.valueOf(before_option.get("query")).replace("(", "").replace(")", "");
		
		String[] options = option.split("\\s+OR\\s+|\\s+AND\\s+");
		
		String searchSdId = String.valueOf(before_option.get("hits")).replace("[", "").replace("]", "").replace("\"", "").replace(",", " ");
		String[] searchSdIds = searchSdId.split(" ");
		
		for(String sdId : searchSdIds) {
			LinkCRF link = null;
			try {
				link = _linkCRFLocalService.getLinkCRFBySdId(Long.parseLong(sdId));
			} catch (Exception e) {
				e.printStackTrace();
			}

			
			for(Subject subInfo : allSub) {
				if(link.getSubjectId() == subInfo.getSubjectId()) {
					JSONObject subJson = JSONFactoryUtil.createJSONObject();
					subJson.put("ID", subInfo.getSerialId());
					subJson.put("Sex", subInfo.getGender());
					subJson.put("Age", (Math.abs(124 - subInfo.getBirth().getYear())));
					subJson.put("Name", subInfo.getName());
					subJsons.put(subJson);
					//_log.info("subJson: " + subJson.toJSONString());
					
					JSONObject ansObj = null;
					try {
						ansObj = JSONFactoryUtil.createJSONObject(_dataTypeLocalService.getStructuredData(Long.parseLong(sdId)));
						ansObj.put("ID", subInfo.getSerialId());
						ansJsons.put(ansObj);
					} catch (Exception e2) {
						// TODO Auto-generated catch block
						e2.printStackTrace();
					}
				}
			}
		}		
		
		renderRequest.setAttribute("subjectJson", subJsons.toJSONString());
		renderRequest.setAttribute("answerJson", ansJsons.toJSONString());
		renderRequest.setAttribute("options", String.join(",", options));
		renderRequest.setAttribute("searchSdIds", String.join(",", searchSdIds));
		
		renderRequest.setAttribute("json", json);
		
		return ECRFUserJspPaths.JSP_CRF_DATA_EXCEL_DOWNLOAD;*/
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
}
