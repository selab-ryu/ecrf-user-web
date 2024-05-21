package ecrf.user.approve.portlet;

import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;

import javax.portlet.Portlet;

import org.osgi.service.component.annotations.Component;

import ecrf.user.constants.ECRFUserPortletKeys;

@Component(
    immediate = true,
    property = {
            "com.liferay.portlet.display-category=category.hidden",
            "com.liferay.portlet.scopeable=true",
            "com.liferay.portlet.header-portlet-css=/css/main.css",
            "javax.portlet.display-name=Approve",
            "javax.portlet.expiration-cache=0",
            "javax.portlet.init-param.portlet-title-based-navigation=true",
            "javax.portlet.init-param.template-path=/html/approve/",
            "javax.portlet.init-param.view-template=/html/approve/view-membership.jsp",
            "javax.portlet.name=" + ECRFUserPortletKeys.APPROVE_ADMIN,
            "javax.portlet.resource-bundle=content.Language",
            "javax.portlet.security-role-ref=administrator",
            "javax.portlet.supports.mime-type=text/html",
            "com.liferay.portlet.add-default-resource=true"
    },
    service = Portlet.class
)
public class AproveAdminPortlet extends MVCPortlet {

}
