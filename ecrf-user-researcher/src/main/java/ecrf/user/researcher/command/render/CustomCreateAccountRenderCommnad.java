package ecrf.user.researcher.command.render;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCRenderConstants;
import com.liferay.portal.kernel.util.PortalUtil;
import com.liferay.portal.kernel.util.PortletKeys;

import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

@Component(
	property = {
		"javax.portlet.name="+PortletKeys.LOGIN,
		"mvc.command.name="+"/login/create_account",
		"service.ranking:Integer=100" 
	},
	service = MVCRenderCommand.class
)
public class CustomCreateAccountRenderCommnad implements MVCRenderCommand {

	@Override
	public String render(RenderRequest renderRequest, RenderResponse renderResponse) throws PortletException {
		_log = LogFactoryUtil.getLog(this.getClass().getName());
		_log.info("Rendering update-researcher.jsp");
		
		RequestDispatcher requestDispatcher = servletContext.getRequestDispatcher("/html/researcher/update-researcher.jsp");
		
		try {
			HttpServletRequest httpServletRequest = PortalUtil.getHttpServletRequest(renderRequest);
			HttpServletResponse httpServletResponse = PortalUtil.getHttpServletResponse(renderResponse);
			
			requestDispatcher.include(httpServletRequest, httpServletResponse);
		} catch (Exception e) {
			throw new PortletException("Unable to include update-researcher.jsp");
		}
		
		return MVCRenderConstants.MVC_PATH_VALUE_SKIP_DISPATCH;
	}
	
	private Log _log;
	
	@Reference( target="(osgi.web.symbolicname=ecrf.user.researcher)" )
	protected ServletContext servletContext;

}
