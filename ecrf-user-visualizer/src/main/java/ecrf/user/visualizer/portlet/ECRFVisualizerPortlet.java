package ecrf.user.visualizer.portlet;

import ecrf.user.visualizer.constants.ECRFVisualizerPortletKeys;

import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;

import javax.portlet.Portlet;

import org.osgi.service.component.annotations.Component;

/**
 * @author dev-ryu
 */
@Component(
	immediate = true,
	property = {
		"javax.portlet.version=3.0",	// for using MutableRenderParameters
		"com.liferay.portlet.display-category=category.ecrf-user",
		"com.liferay.portlet.header-portlet-css=/css/main.css",
		"com.liferay.portlet.instanceable=false",
		"javax.portlet.display-name=ECRF-Visualizer",
		"javax.portlet.init-param.template-path=/",
		"javax.portlet.init-param.view-template=/view.jsp",
		"javax.portlet.name=" + ECRFVisualizerPortletKeys.ECRFVISUALIZER,
		"javax.portlet.resource-bundle=content.Language",
		"javax.portlet.security-role-ref=power-user,user"
	},
	service = Portlet.class
)
public class ECRFVisualizerPortlet extends MVCPortlet {
}