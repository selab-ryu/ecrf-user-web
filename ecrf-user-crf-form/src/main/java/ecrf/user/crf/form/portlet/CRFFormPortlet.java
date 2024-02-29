package ecrf.user.crf.form.portlet;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;

import javax.portlet.Portlet;

import org.osgi.service.component.annotations.Component;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserPortletKeys;

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
		"javax.portlet.display-name=CRF_Form",
		"javax.portlet.init-param.template-path=/",
		"javax.portlet.init-param.view-template="+ECRFUserJspPaths.JSP_MANAGE_FORM,
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF_FORM,
		"javax.portlet.resource-bundle=content.Language",
		"javax.portlet.security-role-ref=power-user,user"
	},
	service = Portlet.class
)
public class CRFFormPortlet extends MVCPortlet {
	
	private Log _log = LogFactoryUtil.getLog(CRFFormPortlet.class);
}