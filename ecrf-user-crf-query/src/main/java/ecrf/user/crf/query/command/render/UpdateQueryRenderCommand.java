package ecrf.user.crf.query.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Validator;
import com.sx.icecap.model.StructuredData;
import com.sx.icecap.service.DataTypeLocalService;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.model.CRFAutoquery;
import ecrf.user.model.Subject;
import ecrf.user.service.CRFAutoqueryLocalService;
import ecrf.user.service.SubjectLocalService;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF_QUERY,
	        "mvc.command.name="+ ECRFUserMVCCommand.RENDER_UPDATE_CRF
	    },
	    service = MVCRenderCommand.class
	)
public class UpdateQueryRenderCommand  implements MVCRenderCommand{
	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException{
		_log.info("Render Query Edit");
		String sdId = ParamUtil.getString(renderRequest, "sdId");
		String sId = ParamUtil.getString(renderRequest, "sId");
		String termName = ParamUtil.getString(renderRequest, "termName");
		String value = ParamUtil.getString(renderRequest, "value");
		_log.info("query edit render : " + sId + " / " + sdId + " / " + termName + " / " + value);
		
		Subject subject = null;
		long subjectId = 0;
		if(Validator.isNotNull(sId)) {
			subjectId = Long.valueOf(sId);
			if(subjectId > 0) {
				try {
					subject = _subjectLocalService.getSubject(subjectId);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
		
		StructuredData sd = null;
		long structuredDataId = 0;
		if(Validator.isNotNull(sdId)) {
			structuredDataId = Long.valueOf(sdId);
			if(structuredDataId > 0) {
				sd = _dataTypeLocalService.getStructuredData(structuredDataId);
			}
		}
		
		CRFAutoquery query = null;
		if(Validator.isNotNull(subject) && Validator.isNotNull(sd) && Validator.isNotNull(value)) {
			try {
				query = _queryLocalService.getQueryBySdIdSIdValue(structuredDataId, subjectId, termName, value);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		renderRequest.setAttribute("sdId", sdId);
		renderRequest.setAttribute("sId", sId);
		renderRequest.setAttribute("value", value);
		renderRequest.setAttribute("sd", sd);
		renderRequest.setAttribute("subject", subject);
		renderRequest.setAttribute("query", query);
		renderRequest.setAttribute("dataTypeLocalServie", _dataTypeLocalService);
		
		return ECRFUserJspPaths.JSP_UPDATE_QUERY;
	}
	
	private Log _log = LogFactoryUtil.getLog(UpdateQueryRenderCommand.class);
	
	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
	
	@Reference
	private CRFAutoqueryLocalService _queryLocalService;
	
}