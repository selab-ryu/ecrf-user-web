package ecrf.user.approve.application.list;

import com.liferay.application.list.BasePanelApp;
import com.liferay.application.list.PanelApp;
import com.liferay.portal.kernel.model.Portlet;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.panel.category.constants.ECRFUserPanelCategoryKeys;

/**
 * @author SELab-Ryu
 */
@Component(
	immediate = true,
	property = {
		"panel.app.order:Integer=300",
		"panel.category.key=" + ECRFUserPanelCategoryKeys.SITE_ECRF_PANEL
	},
	service = PanelApp.class
)
public class ApprovePanelApp extends BasePanelApp {

	@Override
	public String getPortletId() {
		return ECRFUserPortletKeys.APPROVE_ADMIN;
	}

	@Override
	@Reference(
		target = "(javax.portlet.name=" + ECRFUserPortletKeys.APPROVE_ADMIN + ")",
		unbind = "-"
	)
	public void setPortlet(Portlet portlet) {
		super.setPortlet(portlet);
	}

}