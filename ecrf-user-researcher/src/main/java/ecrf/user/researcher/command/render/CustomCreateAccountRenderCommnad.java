package ecrf.user.researcher.command.render;

import com.liferay.petra.string.StringPool;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.LiferayRenderRequest;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderConstants;
import com.liferay.portal.kernel.servlet.DynamicServletRequest;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.PortalUtil;
import com.liferay.portal.kernel.util.PortletKeys;
import com.liferay.portal.kernel.util.WebKeys;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;

@Component(
	property = {
		"javax.portlet.name="+PortletKeys.LOGIN,
		"mvc.command.name="+ECRFUserMVCCommand.RENDER_LOGIN_CREATE_ACCOUNT,
		"service.ranking:Integer=100" 
	},
	service = MVCRenderCommand.class
)
public class CustomCreateAccountRenderCommnad implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log.info("Rendering update-researcher.jsp");
		
		// add parameter at render request
		LiferayRenderRequest liferayRenderRequest = (LiferayRenderRequest)renderRequest;
		DynamicServletRequest dynamicRequest =(DynamicServletRequest)liferayRenderRequest.getHttpServletRequest();
		dynamicRequest.setParameter("isAdmin", String.valueOf(false));
		dynamicRequest.setParameter("fromLiferay", String.valueOf(true));
		
		String redirect = ParamUtil.getString(renderRequest, WebKeys.REDIRECT);
		_log.info("redirect : " + redirect);
		
		String from = ParamUtil.getString(renderRequest, "from", "login");
		_log.info("from : " + from);
		
		RequestDispatcher requestDispatcher = servletContext.getRequestDispatcher(ECRFUserJspPaths.JSP_VIEW_PRIVACY_AGREEMENT);
		
		if(from.equals("privacy")) {
			_log.info("from privacy page");
			requestDispatcher = servletContext.getRequestDispatcher(ECRFUserJspPaths.JSP_UPDATE_RESEARCHER);
		} else {
			_log.info("from login module");
		}
		
		// for deploy
		requestDispatcher = servletContext.getRequestDispatcher(ECRFUserJspPaths.JSP_UPDATE_RESEARCHER);
		
		try {
			HttpServletRequest httpServletRequest = PortalUtil.getHttpServletRequest(renderRequest);
			HttpServletResponse httpServletResponse = PortalUtil.getHttpServletResponse(renderResponse);
			
			requestDispatcher.include(httpServletRequest, httpServletResponse);
		} catch (Exception e) {
			throw new PortletException("Unable to include update-researcher.jsp");
		}
		
		return MVCRenderConstants.MVC_PATH_VALUE_SKIP_DISPATCH;
	}
	
	private Log _log = LogFactoryUtil.getLog(CustomCreateAccountRenderCommnad.class);
	
	@Reference( target="(osgi.web.symbolicname=ecrf.user.researcher)" )
	protected ServletContext servletContext;

}
