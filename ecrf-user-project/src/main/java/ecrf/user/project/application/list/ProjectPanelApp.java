package ecrf.user.project.application.list;

import com.liferay.application.list.BasePanelApp;
import com.liferay.application.list.PanelApp;
import com.liferay.portal.kernel.model.Portlet;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.panel.category.constants.ECRFUserPanelCategoryKeys;

@Component(
	immediate = true,
	property = {
		"panel.app.order:Integer=300",
		"panel.category.key=" + ECRFUserPanelCategoryKeys.SITE_ECRF_PANEL
	},
	service = PanelApp.class
)
public class ProjectPanelApp extends BasePanelApp {

	@Override
	public String getPortletId() {
		return ECRFUserPortletKeys.PROJECT;
	}
	
	@Override
	@Reference(
		target = "(javax.portlet.name=" + ECRFUserPortletKeys.PROJECT + ")",
		unbind = "-"
	)
	public void setPortlet(Portlet portlet) {
		super.setPortlet(portlet);
	}

}
