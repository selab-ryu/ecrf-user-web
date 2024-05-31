package ecrf.user.crf.data.command.render.other;

import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;
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
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF_DATA,
	        "mvc.command.name=" + ECRFUserMVCCommand.RENDER_CRF_DATA_EXCEL_DOWNLOAD,
	    },
	    service = MVCRenderCommand.class
	)

public class ExcelDownloadRenderCommand implements MVCRenderCommand{
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException{
		_log.info("Render Excel Download");
		
		String[] searchSdIds = (String[])renderRequest.getAttribute(ECRFUserCRFDataAttributes.STRUCTURED_DATA_LIST);
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
		long dataTypeId = _crfLocalService.getDataTypeId(crfId);
		
		String searchLogId = ParamUtil.getString(renderRequest, "searchLogId");
		
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
		for(int i = 0; i < allSub.size(); i++) {
			JSONObject subJson = JSONFactoryUtil.createJSONObject();
			Subject subTemp = allSub.get(i);
			subJson.put("ID", subTemp.getSerialId());
			subJson.put("Name", subTemp.getName());
			subJson.put("Age", (Math.abs(124 - subTemp.getBirth().getYear())));
			subJson.put("Sex", subTemp.getGender());
			subJsons.put(subJson);
			LinkCRF link = null;
			if(_linkCRFLocalService.countLinkBySubjectId(subTemp.getSubjectId()) > 0) {
				try {
					link = _linkCRFLocalService.getLinkCRFBySId(subTemp.getSubjectId());
				} catch (Exception e) {
					e.printStackTrace();
				}
        
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
		renderRequest.setAttribute("searchLogId", searchLogId);
		
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
}
