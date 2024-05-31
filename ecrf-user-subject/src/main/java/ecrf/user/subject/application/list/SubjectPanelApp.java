/**
 * 
 */
package ecrf.user.subject.application.list;

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
		"panel.app.order:Integer=390",
		"panel.category.key=" + ECRFUserPanelCategoryKeys.SITE_ECRF_PANEL
	},
	service = PanelApp.class
)
public class SubjectPanelApp extends BasePanelApp {

	@Override
	public String getPortletId() {
		return ECRFUserPortletKeys.SUBJECT;
	}
	
	@Override
	@Reference(
		target = "(javax.portlet.name=" + ECRFUserPortletKeys.SUBJECT + ")",
		unbind = "-"
	)
	public void setPortlet(Portlet portlet) {
		super.setPortlet(portlet);
	}

}
