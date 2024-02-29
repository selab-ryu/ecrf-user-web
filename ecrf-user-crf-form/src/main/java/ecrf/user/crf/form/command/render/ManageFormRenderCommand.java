package ecrf.user.crf.form.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;

import java.util.Enumeration;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;

@Component(
	    immediate = true,
	    property = {
    		"javax.portlet.name=" + ECRFUserPortletKeys.CRF,
	        "javax.portlet.name=" + ECRFUserPortletKeys.CRF_FORM,
	        "mvc.command.name="+ECRFUserMVCCommand.RENDER_MANAGE_FORM
	    },
	    service = MVCRenderCommand.class
	)
public class ManageFormRenderCommand implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log.info("manage form render command");
		
		for(Enumeration<String> e = renderRequest.getParameterNames(); e.hasMoreElements();) {
			String paramName =  e.nextElement();
			String paramValue = renderRequest.getParameter(paramName);
			_log.info("param name / value : " + paramName + " / " + paramValue);
		}
		
		return ECRFUserJspPaths.JSP_MANAGE_FORM;
	}

	private Log _log = LogFactoryUtil.getLog(ManageFormRenderCommand.class);
}
