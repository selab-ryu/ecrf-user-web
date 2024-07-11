package ecrf.user.crf.command.render;

import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;
import com.sx.icecap.model.DataType;
import com.sx.icecap.service.DataTypeLocalService;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserCRFAttributes;
import ecrf.user.model.CRF;
import ecrf.user.service.CRFLocalService;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF,
	        "mvc.command.name="+ECRFUserMVCCommand.RENDER_IMPORT_DATAS
	    },
	    service = MVCRenderCommand.class
	)

public class ImportDatasRenderCommand implements MVCRenderCommand{

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		long crfId = ParamUtil.getLong(renderRequest, ECRFUserCRFAttributes.CRF_ID, 0);
		long dataTypeId = 0L;
		
		
		CRF crf = null;
		if(crfId > 0) {
			try {
				crf = _crfLocalService.getCRF(crfId);
				dataTypeId = crf.getDatatypeId();
				
				renderRequest.setAttribute(ECRFUserCRFAttributes.CRF, crf);
			} catch (Exception e) {
				throw new PortletException("Cannot find crf : " + crfId);
			}
		}
		
		DataType dataType = null;
		if(dataTypeId > 0) {
			try {
				dataType = _dataTypeLocalService.getDataType(dataTypeId);
				
				renderRequest.setAttribute(ECRFUserCRFAttributes.DATATYPE_ID, dataTypeId);
				renderRequest.setAttribute(ECRFUserCRFAttributes.DATATYPE, dataType);
			} catch (Exception e) {
				throw new PortletException("Cannot find datatype : " + dataTypeId);
			}
		}
		
		return ECRFUserJspPaths.JSP_IMPORT_DATAS;
	}
	
	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
}
