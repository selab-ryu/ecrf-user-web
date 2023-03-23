package ecrf.user.project.portlet;

import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;

import java.io.IOException;

import javax.portlet.Portlet;
import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserConstants;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.service.ProjectLocalService;

/**
 * @author Ryu
 */
@Component(
	immediate = true,
	property = {
		"javax.portlet.version=3.0",	// for using MutableRenderParameters
		"com.liferay.portlet.display-category=category.ecrf-user",
		"com.liferay.portlet.header-portlet-css=/css/main.css",
		"com.liferay.portlet.instanceable=false",
		"javax.portlet.display-name=Project",
		"javax.portlet.init-param.template-path=/",
		"javax.portlet.init-param.view-template=/html/project/view-project.jsp",
		"javax.portlet.name=" + ECRFUserPortletKeys.PROJECT,
		"javax.portlet.resource-bundle=content.Language",
		"javax.portlet.security-role-ref=power-user,user"
	},
	service = Portlet.class
)
public class ProjectPortlet extends MVCPortlet {	
	@Override
	public void render(RenderRequest renderRequest, RenderResponse renderResponse)
			throws IOException, PortletException {
		renderRequest.setAttribute(ECRFUserConstants.PROJECT_LOCAL_SERVICE, _projectLocalService);
		super.render(renderRequest, renderResponse);
	}

	@Reference
	private ProjectLocalService _projectLocalService;
}