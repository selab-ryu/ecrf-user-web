package ecrf.user.researcher.internal.asset;

import com.liferay.asset.kernel.model.BaseJSPAssetRenderer;
import com.liferay.petra.string.StringUtil;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.exception.SystemException;
import com.liferay.portal.kernel.model.LayoutConstants;
import com.liferay.portal.kernel.portlet.LiferayPortletRequest;
import com.liferay.portal.kernel.portlet.LiferayPortletResponse;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.security.permission.ActionKeys;
import com.liferay.portal.kernel.security.permission.PermissionChecker;
import com.liferay.portal.kernel.security.permission.resource.ModelResourcePermission;
import com.liferay.portal.kernel.util.Constants;
import com.liferay.portal.kernel.util.HtmlUtil;
import com.liferay.portal.kernel.util.PortalUtil;
import com.liferay.portal.kernel.util.WebKeys;

import java.util.Locale;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.portlet.PortletRequest;
import javax.portlet.PortletResponse;
import javax.portlet.PortletURL;
import javax.portlet.WindowState;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserResearcherAttributes;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.model.Researcher;

public class ResearcherAssetRenderer extends BaseJSPAssetRenderer<Researcher> {

	private Researcher _researcher;
	private final ModelResourcePermission<Researcher> _researcherModelResourcePermission;
	private Logger logger = Logger.getLogger(this.getClass().getName());
	
	public ResearcherAssetRenderer(Researcher researcher, ModelResourcePermission<Researcher> modelResourcePermission) {
		_researcher = researcher;
		_researcherModelResourcePermission = modelResourcePermission;
	}
	
	@Override
	public boolean hasEditPermission(PermissionChecker permissionChecker) throws PortalException {
		try {
			return _researcherModelResourcePermission.contains(permissionChecker, _researcher, ActionKeys.UPDATE);
		} catch(Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public boolean hasViewPermission(PermissionChecker permissionChecker) throws PortalException {
		try {
			return _researcherModelResourcePermission.contains(permissionChecker, _researcher, ActionKeys.VIEW);
		} catch(Exception e) {
			e.printStackTrace();
		}
		return true;
	}

	@Override
	public Researcher getAssetObject() {
		return _researcher;
	}

	@Override
	public long getGroupId() {
		return _researcher.getGroupId();
	}

	@Override
	public long getUserId() {
		return _researcher.getUserId();
	}

	@Override
	public String getUserName() {
		return _researcher.getUserName();
	}

	@Override
	public String getUuid() {
		return _researcher.getUuid();
	}

	@Override
	public String getClassName() {
		return Researcher.class.getName();
	}

	@Override
	public long getClassPK() {
		return _researcher.getResearcherId();
	}

	@Override
	public String getSummary(PortletRequest portletRequest, PortletResponse portletResponse) {
		return "Name: " + _researcher.getName();
	}

	@Override
	public String getTitle(Locale locale) {
		return _researcher.getName();
	}

	@Override
	public boolean include(HttpServletRequest request, HttpServletResponse response,
			String template) throws Exception {
		request.setAttribute(ECRFUserResearcherAttributes.RESEARCHER, _researcher);
		request.setAttribute("HtmlUtil", HtmlUtil.getHtml());
		request.setAttribute("StringUtil", new StringUtil());
		return super.include(request, response, template);
	}

	@Override
	public String getJspPath(HttpServletRequest request, String template) {
		if(template.equals(TEMPLATE_FULL_CONTENT)) {
			request.setAttribute(ECRFUserResearcherAttributes.RESEARCHER, _researcher);
			return "/html/asset/" + template + ".jsp";
		} else {
			return null;
		}
	}

	@Override
	public PortletURL getURLEdit(LiferayPortletRequest liferayPortletRequest,
			LiferayPortletResponse liferayPortletResponse) throws Exception {
		
		PortletURL portletURL = liferayPortletResponse.createLiferayPortletURL(
		    getControlPanelPlid(liferayPortletRequest), ECRFUserPortletKeys.RESEARCHER,
		    PortletRequest.RENDER_PHASE);
		portletURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, ECRFUserMVCCommand.RENDER_UPDATE_RESEARCHER);
		portletURL.setParameter(ECRFUserResearcherAttributes.RESEARCHER_ID, String.valueOf(_researcher.getResearcherId()));
		portletURL.setParameter("showback", Boolean.FALSE.toString());

		return portletURL;
	}

	@Override
	public String getURLViewInContext(LiferayPortletRequest liferayPortletRequest,
			LiferayPortletResponse liferayPortletResponse, String noSuchEntryRedirect) throws Exception {
		try {
			long plid = PortalUtil.getPlidFromPortletId(_researcher.getGroupId(), ECRFUserPortletKeys.RESEARCHER);
			
			PortletURL portletURL;
			if(plid == LayoutConstants.DEFAULT_PLID) {
				portletURL = liferayPortletResponse.createLiferayPortletURL(getControlPanelPlid(liferayPortletRequest),
						ECRFUserPortletKeys.RESEARCHER, PortletRequest.RENDER_PHASE);
			} else {
				portletURL = PortletURLFactoryUtil.create(liferayPortletRequest,
						ECRFUserPortletKeys.RESEARCHER, plid, PortletRequest.RENDER_PHASE);
			}
			
			portletURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, ECRFUserMVCCommand.RENDER_VIEW_RESEARCHER);
			portletURL.setParameter(ECRFUserResearcherAttributes.RESEARCHER_ID, String.valueOf(_researcher.getResearcherId()));
			
			String currentUrl = PortalUtil.getCurrentURL(liferayPortletRequest);
			portletURL.setParameter(WebKeys.REDIRECT, currentUrl);
			
			return portletURL.toString(); 
		} catch(PortalException e) {
			logger.log(Level.SEVERE, e.getMessage());
		} catch(SystemException e) {
			logger.log(Level.SEVERE, e.getMessage());
		}
		return noSuchEntryRedirect;
	}
	
	@Override
	public String getURLView(LiferayPortletResponse liferayPortletResponse, WindowState windowState) throws Exception {
		return super.getURLView(liferayPortletResponse, windowState);
	}	
}
