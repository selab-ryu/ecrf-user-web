package ecrf.user.crf.query.portlet;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserPortletKeys;

import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;

import javax.portlet.Portlet;

import org.osgi.service.component.annotations.Component;

/**
 * @author SELab-Ryu
 */
@Component(
	immediate = true,
	property = {
		"javax.portlet.version=3.0",
		"com.liferay.portlet.display-category=category.ecrf-user",
		"com.liferay.portlet.header-portlet-css=/css/main.css",
		"com.liferay.portlet.instanceable=false",
		"javax.portlet.display-name=CRF-Query",
		"javax.portlet.init-param.template-path=/",
		"javax.portlet.init-param.view-template="+ECRFUserJspPaths.JSP_LIST_QUERY,
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF_QUERY,
		"javax.portlet.resource-bundle=content.Language",
		"javax.portlet.security-role-ref=power-user,user"
	},
	service = Portlet.class
)
public class CRFQueryPortlet extends MVCPortlet {
}