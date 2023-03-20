package ecrf.user.researcher.internal.asset;

import com.liferay.asset.kernel.model.AssetRenderer;
import com.liferay.asset.kernel.model.AssetRendererFactory;
import com.liferay.asset.kernel.model.BaseAssetRendererFactory;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.portlet.LiferayPortletRequest;
import com.liferay.portal.kernel.portlet.LiferayPortletResponse;
import com.liferay.portal.kernel.security.permission.PermissionChecker;
import com.liferay.portal.kernel.security.permission.resource.ModelResourcePermission;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.WebKeys;

import java.util.logging.Level;
import java.util.logging.Logger;

import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;
import javax.servlet.ServletContext;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.model.Researcher;
import ecrf.user.researcher.internal.security.permission.resource.ResearcherPermission;
import ecrf.user.service.ResearcherLocalService;

@Component(
	immediate = true,
	property = {"javax.portlet.name=" + ECRFUserPortletKeys.RESEARCHER},
	service = AssetRendererFactory.class
)
public class ResearcherAssetRendererFactory extends BaseAssetRendererFactory<Researcher> {
	private ServletContext _servletContext;
	private ResearcherLocalService _researcherLocalService;
	private static final boolean _LINKABLE = true;
	public static final String CLASS_NAME = Researcher.class.getName();
	public static final String TYPE = "researcher";
	private Logger logger = Logger.getLogger(this.getClass().getName());
	private ModelResourcePermission<Researcher> _researcherModelResourcePermission;
	
	public ResearcherAssetRendererFactory() {
		super.setClassName(CLASS_NAME);
		super.setLinkable(_LINKABLE);
		super.setPortletId(ECRFUserPortletKeys.RESEARCHER);
		super.setSearchable(true);
		super.setSelectable(true);
	}	
	
	@Override
	public AssetRenderer<Researcher> getAssetRenderer(long classPK, int type) throws PortalException {
		Researcher researcher = _researcherLocalService.getResearcher(classPK);
		ResearcherAssetRenderer researcherAssetRenderer = new ResearcherAssetRenderer(researcher, _researcherModelResourcePermission);
		researcherAssetRenderer.setAssetRendererType(type);
		researcherAssetRenderer.setServletContext(_servletContext);
		return researcherAssetRenderer;
	}
	
	@Override
	public String getClassName() {
		return CLASS_NAME;
	}
	
	@Override
	public String getType() {
		return TYPE;
	}
	
	@Override
	public boolean hasPermission(PermissionChecker permissionChecker, long classPK, String actionId) throws Exception {
		Researcher researcher = _researcherLocalService.getResearcher(classPK);
		long groupId = researcher.getGroupId();
		return ResearcherPermission.contains(permissionChecker, groupId, actionId);
	}
	
	@Override
	public PortletURL getURLAdd(LiferayPortletRequest liferayPortletRequest,LiferayPortletResponse liferayPortletResponse, long classTypeId) {
		PortletURL portletURL = null;
		
		try {
			ThemeDisplay themeDisplay = (ThemeDisplay) liferayPortletRequest.getAttribute(WebKeys.THEME_DISPLAY);
			portletURL = liferayPortletResponse.createLiferayPortletURL(getControlPanelPlid(themeDisplay),
					ECRFUserPortletKeys.RESEARCHER, PortletRequest.RENDER_PHASE);
			portletURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, ECRFUserMVCCommand.RENDER_ADD_RESEARCHER);
			portletURL.setParameter("showback", Boolean.FALSE.toString());
		} catch (PortalException e) {
			logger.log(Level.SEVERE, e.getMessage());
		}
		
		return portletURL;
	}
	
	
	
	@Override
	public boolean isLinkable() {
	    return _LINKABLE;
	}

	@Override
	public String getIconCssClass() {
	  return "pencil";
	}
	
	@Reference(
		target = "(osgi.web.symbolicname=ecrf.user.researcher)",
		unbind = "-"
	)
	public void setServletContext(ServletContext servletContext) {
		_servletContext = servletContext;
	}
	
	@Reference(unbind = "-")
	protected void setResearcherLocalService(ResearcherLocalService researcherLocalService) {
		_researcherLocalService = researcherLocalService;
	}
}
