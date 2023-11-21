package ecrf.user.crf.portlet;

import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;

import javax.portlet.Portlet;

import org.osgi.service.component.annotations.Component;

import ecrf.user.constants.ECRFUserPortletKeys;

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
		"javax.portlet.display-name=CRFWeb",
		"javax.portlet.init-param.template-path=/",
		"javax.portlet.init-param.view-template=/html/crf/list-crf.jsp",
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF,
		"javax.portlet.resource-bundle=content.Language",
		"javax.portlet.security-role-ref=power-user,user"
	},
	service = Portlet.class
)
public class CRFWebPortlet extends MVCPortlet {
}