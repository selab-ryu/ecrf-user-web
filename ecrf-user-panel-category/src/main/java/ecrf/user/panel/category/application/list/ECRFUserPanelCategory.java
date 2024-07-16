package ecrf.user.panel.category.application.list;

import com.liferay.application.list.BasePanelCategory;
import com.liferay.application.list.PanelCategory;
import com.liferay.application.list.constants.PanelCategoryKeys;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.language.LanguageUtil;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.model.Group;
import com.liferay.portal.kernel.security.permission.PermissionChecker;
import com.liferay.portal.kernel.util.ResourceBundleUtil;

import java.util.Locale;
import java.util.ResourceBundle;

import org.osgi.service.component.annotations.Component;

import ecrf.user.panel.category.constants.ECRFUserPanelCategoryKeys;

/**
 * @author SELab-Ryu
 */
@Component(
	immediate = true,
	property = {
		"panel.category.key=" + PanelCategoryKeys.SITE_ADMINISTRATION,
		"panel.category.order:Integer=100"
	},
	service = PanelCategory.class
)
public class ECRFUserPanelCategory extends BasePanelCategory {

	@Override
	public String getKey() {
		return ECRFUserPanelCategoryKeys.SITE_ECRF_PANEL;
	}

	@Override
	public String getLabel(Locale locale) {
		ResourceBundle resourceBundle = ResourceBundleUtil.getBundle(
			"content.Language", locale, getClass());

		return LanguageUtil.get(resourceBundle, "site-panel.ecrf-user");
	}

	@Override
	public boolean isShow(PermissionChecker permissionChecker, Group group) throws PortalException {
		if(group.isRoot()) return false;
		return super.isShow(permissionChecker, group);
	}
	
	private Log _log = LogFactoryUtil.getLog(ECRFUserPanelCategory.class);
}