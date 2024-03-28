package ecrf.user.crf.data.viewer.portlet;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;

import java.io.IOException;

import javax.portlet.Portlet;
import javax.portlet.PortletException;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;

import org.osgi.service.component.annotations.Component;

import ecrf.user.constants.ECRFUserPortletKeys;

@Component(
	immediate = true,
	property = {
		"javax.portlet.version=3.0",
		"com.liferay.portlet.display-category=category.ecrf-user",
		"com.liferay.portlet.header-portlet-css=/css/main.css",
		"com.liferay.portlet.instanceable=false",
		"javax.portlet.display-name=CRF_Data_Viewer",
		"javax.portlet.init-param.template-path=/",
		"javax.portlet.init-param.view-template=/html/crf-data-viewer/view.jsp",
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF_DATA_VIEWER,
		"javax.portlet.resource-bundle=content.Language",
		"javax.portlet.security-role-ref=power-user,user"
	},
	service = Portlet.class
)
public class CRFDataViewerPortlet extends MVCPortlet {
	@Override
	public void render(RenderRequest renderRequest, RenderResponse renderResponse)
			throws IOException, PortletException {
		_log.info("crf data viewer portlet render");
		super.render(renderRequest, renderResponse);
	}
	
	private Log _log = LogFactoryUtil.getLog(CRFDataViewerPortlet.class);
}