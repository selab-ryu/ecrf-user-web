/**
 * 
 */
package ecrf.user.account.command.action;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.model.Group;
import com.liferay.portal.kernel.model.Layout;
import com.liferay.portal.kernel.model.Role;
import com.liferay.portal.kernel.model.User;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.security.pwd.PasswordEncryptorUtil;
import com.liferay.portal.kernel.service.GroupLocalServiceUtil;
import com.liferay.portal.kernel.service.LayoutLocalServiceUtil;
import com.liferay.portal.kernel.service.RoleLocalServiceUtil;
import com.liferay.portal.kernel.service.UserLocalService;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.PortalUtil;
import com.liferay.portal.kernel.util.PortletKeys;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;

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
        "javax.portlet.name=" + PortletKeys.LOGIN, 
        "mvc.command.name="+ECRFUserMVCCommand.ACTION_LOGIN,
        "service.ranking:Integer=100" 
    }, 
    service = MVCActionCommand.class
)
public class CheckAgreementActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		_log.info("check override action command");
		
		String login = ParamUtil.getString(actionRequest, "login");
		String password = actionRequest.getParameter("password");
		
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY); 
		long companyId = themeDisplay.getCompanyId();
		
		User user = null;
		
		// check user exist
		try {
			user = _userLocalService.getUserByEmailAddress(companyId, login);
		} catch (Exception e) {	// none, process login
			mvcActionCommand.processAction(actionRequest, actionResponse);
			return;
		}
		
		// check password validation
		boolean isValidLogin = false;
		
		// null check
		if(Validator.isNull(user)) {
			mvcActionCommand.processAction(actionRequest, actionResponse);
			return;
		}
		
		String userPassword = user.getPassword();

		if (!user.isPasswordEncrypted()) { userPassword = PasswordEncryptorUtil.encrypt(userPassword); }
		String encPassword = PasswordEncryptorUtil.encrypt(password, userPassword);
				
		//_log.info("check password : " + password + " / " + encPassword + " / " + user.getPassword());

		if (userPassword.equals(password) || userPassword.equals(encPassword)) { isValidLogin = true; }

		// failed, process login
		if(!isValidLogin) {
			mvcActionCommand.processAction(actionRequest, actionResponse);
			return;
		} else {
			// check admin?
			Role adminRole = RoleLocalServiceUtil.getRole(companyId, "Administrator");
			boolean hasAdminRole = _userLocalService.hasRoleUser(adminRole.getRoleId(), user.getUserId());
			_log.info("is admin : " + hasAdminRole);
			
			// if admin, pass agreement
			if(hasAdminRole) {
				mvcActionCommand.processAction(actionRequest, actionResponse);
				return;
			} else {
				// get researcher
				Researcher researcher = null;
				try {
					researcher = _researcherLocalService.getResearcherByUserId(user.getUserId());
				} catch(NoSuchResearcherException noResearcher) {
					noResearcher.printStackTrace();
				}
				
				// check researcher's agreement	
				boolean isAgree = _researcherLocalService.checkAgreement(researcher.getResearcherId());
				
				if(isAgree) {	// process login
					mvcActionCommand.processAction(actionRequest, actionResponse);
					return;
				} else {	// proceed to agreement page
					Group rootGroup = GroupLocalServiceUtil.fetchFriendlyURLGroup(companyId, "/guest");
					Layout layout = LayoutLocalServiceUtil.fetchLayoutByFriendlyURL(rootGroup.getGroupId(), false, "/agreement");
					
					String renderCommand = ECRFUserMVCCommand.RENDER_VIEW_AGREEMENT;
					
					PortletURL renderURL = PortletURLFactoryUtil.create(
							PortalUtil.getHttpServletRequest(actionRequest), 
							ECRFUserPortletKeys.ACCOUNT,
							layout.getPlid(),
							PortletRequest.RENDER_PHASE);
					
					renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
					renderURL.setParameter("login", login);
					renderURL.setParameter("password", password);
					
					_log.info(renderURL);
					
					actionResponse.sendRedirect(renderURL.toString());
				}
			}
			
		}
		
	}
	
	private Log _log = LogFactoryUtil.getLog(CheckAgreementActionCommand.class);
	
	@Reference
	(target= "(component.name=com.liferay.login.web.internal.portlet.action.LoginMVCActionCommand)")
	protected MVCActionCommand mvcActionCommand;
	
	@Reference
	private UserLocalService _userLocalService;
	
	@Reference
	private ResearcherLocalService _researcherLocalService;

}
