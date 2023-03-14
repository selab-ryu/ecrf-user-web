package ecrf.user.researcher.portlet;

import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;

import java.io.IOException;

import javax.portlet.Portlet;
import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import selab.ecrf.user.constants.ECRFUserConstants;
import selab.ecrf.user.constants.ECRFUserPortletKeys;
import selab.ecrf.user.service.ResearcherLocalService;

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
		"javax.portlet.display-name=Researcher",
		"javax.portlet.init-param.template-path=/",
		"javax.portlet.init-param.view-template=/html/researcher/updateResearcher.jsp",
		"javax.portlet.name=" + ECRFUserPortletKeys.RESEARCHER,
		"javax.portlet.resource-bundle=content.Language",
		"javax.portlet.security-role-ref=power-user,user"
	},
	service = Portlet.class
)
public class ResearcherPortlet extends MVCPortlet {
	@Override
	public void render(RenderRequest renderRequest, RenderResponse renderResponse)
			throws IOException, PortletException {
		_logger = LoggerFactory.getLogger(this.getClass().getName());
		_logger.info("Start");
		
		renderRequest.setAttribute(ECRFUserConstants.RESEARCHER_LOCAL_SERVICE, _researcherLocalService);
		
		_logger.info("End");
		super.render(renderRequest, renderResponse);
	}

	private Logger _logger;
	
	@Reference
	private ResearcherLocalService _researcherLocalService;
}