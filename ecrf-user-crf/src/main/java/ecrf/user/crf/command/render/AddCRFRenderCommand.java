package ecrf.user.crf.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.util.ParamUtil;
import com.sx.icecap.model.DataType;
import com.sx.icecap.service.DataTypeLocalService;

import java.util.Enumeration;

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
        "mvc.command.name="+ECRFUserMVCCommand.RENDER_ADD_CRF
    },
    service = MVCRenderCommand.class
)
public class AddCRFRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {

//		for(Enumeration<String> e = renderRequest.getParameterNames(); e.hasMoreElements();) {
//			String paramName =  e.nextElement();
//			String paramValue = renderRequest.getParameter(paramName);
//			_log.info("param name / value : " + paramName + " / " + paramValue);
//		}
		
		return ECRFUserJspPaths.JSP_UPDATE_CRF;
	}
	
	private Log _log = LogFactoryUtil.getLog(AddCRFRenderCommand.class);;
	
}
