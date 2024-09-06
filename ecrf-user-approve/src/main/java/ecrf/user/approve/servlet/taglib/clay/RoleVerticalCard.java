package ecrf.user.approve.servlet.taglib.clay;

import com.liferay.frontend.taglib.clay.servlet.taglib.soy.BaseBaseClayCard;
import com.liferay.frontend.taglib.clay.servlet.taglib.soy.VerticalCard;
import com.liferay.portal.kernel.dao.search.RowChecker;
import com.liferay.portal.kernel.language.LanguageUtil;
import com.liferay.portal.kernel.model.Role;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.HtmlUtil;
import com.liferay.portal.kernel.util.PortalUtil;
import com.liferay.portal.kernel.util.WebKeys;

import javax.portlet.RenderRequest;
import javax.servlet.http.HttpServletRequest;

public class RoleVerticalCard extends BaseBaseClayCard implements VerticalCard {

	public RoleVerticalCard(
		Role role, RenderRequest renderRequest, RowChecker rowChecker) {

		super(role, rowChecker);

		_role = role;

		_httpServletRequest = PortalUtil.getHttpServletRequest(renderRequest);
	}

	@Override
	public String getIcon() {
		return "users";
	}

	@Override
	public String getSubtitle() {
		return LanguageUtil.get(_httpServletRequest, _role.getTypeLabel());
	}

	@Override
	public String getTitle() {
		ThemeDisplay themeDisplay =
			(ThemeDisplay)_httpServletRequest.getAttribute(
				WebKeys.THEME_DISPLAY);

		return HtmlUtil.escape(_role.getTitle(themeDisplay.getLocale()));
	}

	private final HttpServletRequest _httpServletRequest;
	private final Role _role;

}
