package ecrf.user.crf.portlet;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;
import com.liferay.portal.kernel.util.ParamUtil;

import java.io.IOException;
import java.util.Iterator;

import javax.portlet.MimeResponse.Copy;
import javax.portlet.MutableRenderParameters;
import javax.portlet.Portlet;
import javax.portlet.PortletException;
import javax.portlet.PortletURL;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserConstants;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.service.CRFLocalService;

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
		"javax.portlet.display-name=CRF",
		"javax.portlet.init-param.template-path=/",
		"javax.portlet.init-param.view-template=/html/crf/list-crf.jsp",
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF,
		"javax.portlet.resource-bundle=content.Language",
		"javax.portlet.security-role-ref=power-user,user"
	},
	service = Portlet.class
)
public class CRFWebPortlet extends MVCPortlet {
	
	@Override
	public void render(RenderRequest renderRequest, RenderResponse renderResponse)
			throws IOException, PortletException {
		
		renderRequest.setAttribute(ECRFUserConstants.CRF_LOCAL_SERVICE, _crfLocalService);
		
		_log.info("portlet render method");
		
		// check portletURL parameters -> require portlet version 3.0
		PortletURL portletURL = renderResponse.createRenderURL(Copy.ALL);
		MutableRenderParameters params = portletURL.getRenderParameters();
		Iterator<String> names = params.getNames().iterator();
		while(names.hasNext()) {
			String key = names.next();
			_log.info(String.format("key : %s, value : %s", key, params.getValue(key)));	
		}
						
		super.render(renderRequest, renderResponse);
	}
	
	private Log _log = LogFactoryUtil.getLog(CRFWebPortlet.class);
	
	@Reference
	private CRFLocalService _crfLocalService;
}