/**
 * 
 */
package ecrf.user.researcher.application.list;

import com.liferay.application.list.BasePanelApp;
import com.liferay.application.list.PanelApp;
import com.liferay.portal.kernel.model.Portlet;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.panel.category.constants.ECRFUserPanelCategoryKeys;

/**
 * @author SELab-Ryu
 *
 */

@Component(
	immediate = true,
	property = {
		"panel.app.order:Integer=380",
		"panel.category.key=" + ECRFUserPanelCategoryKeys.SITE_ECRF_PANEL
	},
	service = PanelApp.class
)
public class ResearcherPanelApp extends BasePanelApp {

	@Override
	public String getPortletId() {
		return ECRFUserPortletKeys.RESEARCHER;
	}
	
	@Override
	@Reference(
		target = "(javax.portlet.name=" + ECRFUserPortletKeys.RESEARCHER + ")",
		unbind = "-"
	)
	public void setPortlet(Portlet portlet) {
		super.setPortlet(portlet);
	}

}
