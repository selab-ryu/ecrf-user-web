/**
 * 
 */
package ecrf.user.account.command.action;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.model.CompanyConstants;
import com.liferay.portal.kernel.model.Group;
import com.liferay.portal.kernel.model.Layout;
import com.liferay.portal.kernel.model.User;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.security.auth.session.AuthenticatedSessionManagerUtil;
import com.liferay.portal.kernel.service.GroupLocalServiceUtil;
import com.liferay.portal.kernel.service.LayoutLocalServiceUtil;
import com.liferay.portal.kernel.service.UserLocalService;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Portal;
import com.liferay.portal.kernel.util.PortalUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.exception.NoSuchResearcherException;
import ecrf.user.model.Researcher;
import ecrf.user.service.ResearcherLocalService;

/**
 * @author dev-ryu
 *
 */

@Component(
    property = { 
        "javax.portlet.name=" + ECRFUserPortletKeys.ACCOUNT, 
        "mvc.command.name="+ECRFUserMVCCommand.ACTION_AGREEMENT
    }, 
    service = MVCActionCommand.class
)
public class AgreementActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		_log.info("agreement action command");
		
		String login = ParamUtil.getString(actionRequest, "login");
		String password = ParamUtil.getString(actionRequest, "password");
				
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY); 
		long companyId = themeDisplay.getCompanyId();
	        
		Group rootGroup = GroupLocalServiceUtil.fetchFriendlyURLGroup(companyId, "/guest");	// get root group
		Layout layout = LayoutLocalServiceUtil.fetchLayoutByFriendlyURL(rootGroup.getGroupId(), false, "/site");
		
		String renderCommand = ECRFUserMVCCommand.RENDER_VIEW_SITE;
		
		PortletURL renderURL = PortletURLFactoryUtil.create(
				PortalUtil.getHttpServletRequest(actionRequest), 
				ECRFUserPortletKeys.MAIN,
				layout.getPlid(),
				PortletRequest.RENDER_PHASE);
						
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
		
		_log.info(renderURL);
		
		User user = null;
		
		// check user exist
		try {
			user = _userLocalService.getUserByEmailAddress(companyId, login);
		} catch (Exception e) {	
			e.printStackTrace();
			actionResponse.sendRedirect(renderURL.toString());
		}
		
		// TODO: update agreement status
		// get researcher
		Researcher researcher = null;
		try {
			researcher = _researcherLocalService.getResearcherByUserId(user.getUserId());
			_researcherLocalService.updateAgreemnt(researcher.getResearcherId(), true);
		} catch(NoSuchResearcherException noResearcher) {
			noResearcher.printStackTrace();
		}
		
		// proceed login & redirect to Main Site
		if(Validator.isNotNull(user)) {
			HttpServletRequest httpServletRequest = _portal.getOriginalServletRequest(_portal.getHttpServletRequest(actionRequest));
			HttpServletResponse httpServletResponse = _portal.getHttpServletResponse(actionResponse);        
			
	        AuthenticatedSessionManagerUtil.login(httpServletRequest, httpServletResponse, login, password, false, CompanyConstants.AUTH_TYPE_EA);

	        // set redirect, not agreement render page / main site page
	        actionResponse.sendRedirect(renderURL.toString());
		}
	}
	
	private Log _log = LogFactoryUtil.getLog(AgreementActionCommand.class);
		
	@Reference
	private UserLocalService _userLocalService;

	@Reference
	private ResearcherLocalService _researcherLocalService;
	
	@Reference
	private Portal _portal;
}
