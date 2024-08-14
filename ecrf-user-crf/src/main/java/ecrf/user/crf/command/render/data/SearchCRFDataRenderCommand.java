package ecrf.user.crf.command.render.data;

import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;
import com.sx.icecap.constant.IcecapWebKeys;
import com.sx.icecap.model.DataType;
import com.sx.icecap.service.DataTypeLocalService;
import com.sx.icecap.service.StructuredDataLocalService;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.service.CRFLocalService;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF,
	        "mvc.command.name=" + ECRFUserMVCCommand.RENDER_SEARCH_CRF_DATA,
	    },
	    service = MVCRenderCommand.class
	)
public class SearchCRFDataRenderCommand implements MVCRenderCommand{
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException{
		_log.info("Search CRF Render");
		
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
		long dataTypeId = _crfLocalService.getDataTypeId(crfId);
		
		if(crfId == 0) {
			return ECRFUserJspPaths.JSP_LIST_CRF_DATA;
		}
		
		DataType dataType = null;
		JSONObject dataStructure = null;
		try {
			dataType = _dataTypeLocalService.getDataType(dataTypeId);
			dataStructure = _dataTypeLocalService.getDataTypeStructureJSONObject(dataTypeId);
			
			renderRequest.setAttribute(ECRFUserCRFDataAttributes.DATATYPE_ID, dataTypeId);
			renderRequest.setAttribute(ECRFUserCRFDataAttributes.DATATYPE, dataType);
			renderRequest.setAttribute(ECRFUserCRFDataAttributes.DATA_STRUCTURE, dataStructure);
			
		} catch (Exception e) {
			throw new PortletException("Cannot find data type: " + dataTypeId);
		}
		_log.info("0. end");
		return ECRFUserJspPaths.JSP_SEARCH_CRF_DATA;
	}
	
	private Log _log = LogFactoryUtil.getLog(SearchCRFDataRenderCommand.class);
	
	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	DataTypeLocalService _dataTypeLocalService;
	
	@Reference
	StructuredDataLocalService _structuredDataLocalService;
}
