package ecrf.user.researcher.command.action;

import com.liferay.petra.string.StringPool;
import com.liferay.portal.kernel.exception.NoSuchRoleException;
import com.liferay.portal.kernel.exception.NoSuchUserException;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.model.Company;
import com.liferay.portal.kernel.model.MembershipRequest;
import com.liferay.portal.kernel.model.Role;
import com.liferay.portal.kernel.model.User;
import com.liferay.portal.kernel.model.UserGroupRole;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.security.auth.PrincipalException;
import com.liferay.portal.kernel.service.MembershipRequestLocalService;
import com.liferay.portal.kernel.service.RoleLocalService;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.service.UserGroupRoleLocalService;
import com.liferay.portal.kernel.service.UserGroupRoleLocalServiceUtil;
import com.liferay.portal.kernel.service.UserLocalService;
import com.liferay.portal.kernel.service.persistence.UserGroupRolePK;
import com.liferay.portal.kernel.servlet.SessionErrors;
import com.liferay.portal.kernel.servlet.SessionMessages;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.Constants;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Portal;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserUtil;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.constants.attribute.ECRFUserResearcherAttributes;
import ecrf.user.constants.type.ResearcherPosition;
import ecrf.user.exception.NoSuchResearcherException;
import ecrf.user.model.Researcher;
import ecrf.user.service.ResearcherLocalService;

@Component
(
		property = {
				"javax.portlet.name="+ECRFUserPortletKeys.RESEARCHER,
				"mvc.command.name="+ECRFUserMVCCommand.ACTION_ADD_RESEARCHER,
				"mvc.command.name="+ECRFUserMVCCommand.ACTION_UPDATE_RESEARCHER,
		},
		service = MVCActionCommand.class
)
public class UpdateResearcherActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception { 
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		String cmd = ParamUtil.getString(actionRequest, Constants.CMD);
		
		_log.info("add researcher");
		
		boolean errorOccured = false;
		
		try {
		
			if(cmd.equals(Constants.ADD)) {
				addResearcherWithUser(actionRequest, actionResponse);
			} else if(cmd.equals(Constants.UPDATE)) {
				updateResearcherWithUser(actionRequest, actionResponse);
			}
		} catch (Exception exception) {
			
			_log.info(exception.getClass().toString() + " / " + exception.getMessage());
			errorOccured = true;
			
			if (exception instanceof NoSuchUserException ||
				exception instanceof NoSuchResearcherException ||
				exception instanceof PrincipalException) {
				// real error
				SessionErrors.add(actionRequest, exception.getClass());	
			} else if (Validator.isNotNull(exception.getMessage()) ) {
				// user miss something
				
				SessionErrors.add(actionRequest, exception.getClass());
			} else {
				exception.printStackTrace();
				throw exception;
			}
			
			String mvcPath = ECRFUserJspPaths.JSP_UPDATE_RESEARCHER;
			actionResponse.setRenderParameter("mvcPath", mvcPath);
		}
		
		// redirect to list
		if(!errorOccured) {
			String renderCommand = ECRFUserMVCCommand.RENDER_LIST_RESEARCHER;
			
			PortletURL renderURL = PortletURLFactoryUtil.create(
					actionRequest, 
					themeDisplay.getPortletDisplay().getId(), 
					themeDisplay.getPlid(), 
					PortletRequest.RENDER_PHASE);
			
			renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
			actionResponse.sendRedirect(renderURL.toString());
		}
	}
	
	public void addResearcherWithUser(ActionRequest actionRequest, ActionResponse actionResponse) throws PortalException {		
		HttpServletRequest httpServletRequest = _portal.getHttpServletRequest(actionRequest);
		HttpSession session = httpServletRequest.getSession();

		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		ServiceContext researcherServiceContext = ServiceContextFactory.getInstance(Researcher.class.getName(), actionRequest);
		ServiceContext userServiceContext = ServiceContextFactory.getInstance(User.class.getName(), actionRequest);
		Company company = themeDisplay.getCompany();
		
		_log.info("get data from request parameter");
		String email = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.EMAIL);
		String password1 = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.PASSWORD1);
		String password2 = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.PASSWORD2);
		
		String screenName = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.SCREEN_NAME);
		String firstName = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.FIRST_NAME);
		String lastName = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.LAST_NAME);
		
		long facebookId = ParamUtil.getLong(actionRequest, "facebookId");
		String openId = ParamUtil.getString(actionRequest, "openId");
		String languageId = ParamUtil.getString(actionRequest, "languageId");
		String jobTitle = ParamUtil.getString(actionRequest, "jobTitle");
		long prefixId = ParamUtil.getInteger(actionRequest, "prefixId");
		long suffixId = ParamUtil.getInteger(actionRequest, "suffixId");
		
		_log.info("null check : " + facebookId + " / " + openId + " / " + languageId + " / " + jobTitle + " / " + prefixId + " / " + suffixId);
		
		int gender = ParamUtil.getInteger(actionRequest, ECRFUserResearcherAttributes.GENDER, 0);
		boolean male = false;
		if(gender == 0) { male = true; }
		
		DateFormat df = new SimpleDateFormat("yyyy/MM/dd");
		Calendar cal = Calendar.getInstance();
		Date birth = ParamUtil.getDate(actionRequest, ECRFUserResearcherAttributes.BIRTH, df);
				
		cal.setTime(birth);
		int birthYear = cal.get(Calendar.YEAR);
		int birthMonth = cal.get(Calendar.MONTH);
		int birthDay = cal.get(Calendar.DATE);
		
		String phone = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.PHONE);
		String institution = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.INSTITUTION);
		String officeContact = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.OFFICE_CONTACT);
		
		String position = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.POSITION);
		position = "researcher";
		
		Researcher researcher = null;
		
		researcher = _researcherLocalService.addResarcherWithUser(
				company.getCompanyId(),
				facebookId, openId, languageId,
				male, jobTitle, prefixId, suffixId,
				email, password1, password2, screenName, firstName, lastName,
				birthYear, birthMonth, birthDay, gender, 
				phone, institution, officeContact, position, 0,
				userServiceContext, researcherServiceContext);
		SessionMessages.add(actionRequest, "researcherWithUserAdded");
		
		User researcherUser = null;
		
		if(Validator.isNotNull(researcher)) {
			researcherUser = _userLocalService.getUser(researcher.getResearcherUserId());
		} else {
			_log.info("researcher is null");
		}
		
		// NOTICE: when create researcher by researcher module, do not process agreement process
		
		if(Validator.isNotNull(researcherUser)) {
			_log.info("user is added / " + researcherUser.getEmailAddress());
			ServiceContext membershipServiceContext = ServiceContextFactory.getInstance(MembershipRequest.class.getName(), actionRequest);
			
			_membershipRequestLocalService.addMembershipRequest(researcherUser.getUserId(), themeDisplay.getScopeGroupId(), "Add Researcher to Site Membership", membershipServiceContext);
			
//			if(researcher.getPosition().equals(ResearcherPosition.PI.getLower())) {
//				Role role = null;
//				
//				try {
//					role = _roleLocalService.getRole(company.getCompanyId(), "Site PI");
//					_log.info(role.toXmlString());
//					
//					UserGroupRole userGroupRole = UserGroupRoleLocalServiceUtil.createUserGroupRole(new UserGroupRolePK());
//					userGroupRole.setUserId(researcherUser.getUserId());
//					userGroupRole.setGroupId(themeDisplay.getScopeGroupId());
//					userGroupRole.setRoleId(role.getRoleId());
//					
//					if(!_userGroupRoleLocalService.hasUserGroupRole(userGroupRole.getUserId(), userGroupRole.getGroupId(), userGroupRole.getRoleId())) {
//						_userGroupRoleLocalService.addUserGroupRole(userGroupRole);
//					}
//				} catch (Exception e) {
//					if(e instanceof NoSuchRoleException) {
//						 // create new role and add UserGroupRole
//					}
//					_log.error(e.getMessage());
//				}
//			}
		} else {
			_log.error("user is null");
		}
	}
	
	public void updateResearcherWithUser(ActionRequest actionRequest, ActionResponse actionResponse) throws PortalException {
		HttpServletRequest httpServletRequest = _portal.getHttpServletRequest(actionRequest);
		HttpSession session = httpServletRequest.getSession();

		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		ServiceContext researcherServiceContext = ServiceContextFactory.getInstance(Researcher.class.getName(), actionRequest);
		ServiceContext userServiceContext = ServiceContextFactory.getInstance(User.class.getName(), actionRequest);
		Company company = themeDisplay.getCompany();
		
		_log.info("get data from request parameter");
		long researcherId = ParamUtil.getLong(actionRequest, ECRFUserResearcherAttributes.RESEARCHER_ID);
		
		String email = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.EMAIL);
		String password1 = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.PASSWORD1, StringPool.BLANK);
		String password2 = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.PASSWORD2);
		boolean notChange = ParamUtil.getBoolean(actionRequest, ECRFUserResearcherAttributes.NOT_CHANGE, false);
		
		String screenName = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.SCREEN_NAME);
		String firstName = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.FIRST_NAME);
		String lastName = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.LAST_NAME);
		
		int gender = ParamUtil.getInteger(actionRequest, ECRFUserResearcherAttributes.GENDER, 0);
		boolean male = false;
		if(gender == 0) { male = true; }
		
		DateFormat df = new SimpleDateFormat("yyyy/MM/dd");
		Calendar cal = Calendar.getInstance();
		Date birth = ParamUtil.getDate(actionRequest, ECRFUserResearcherAttributes.BIRTH, df);
				
		cal.setTime(birth);
		int birthYear = cal.get(Calendar.YEAR);
		int birthMonth = cal.get(Calendar.MONTH);
		int birthDay = cal.get(Calendar.DATE);
		
		String phone = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.PHONE);
		String institution = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.INSTITUTION);
		String officeContact = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.OFFICE_CONTACT);
		
		String position = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.POSITION);
		position = "researcher";
		
		Researcher researcher = _researcherLocalService.getResearcher(researcherId);
		User researcherUser = null;
		
		if(Validator.isNotNull(researcher)) {
			researcherUser = _userLocalService.getUser(researcher.getResearcherUserId());
		} else {
			_log.info("researcher is null");
		}
		
		if(notChange) password1 = researcherUser.getPasswordUnencrypted();
		
		researcher = _researcherLocalService.updateResearcherWithUser(
				researcherId,
				male, password1,
				screenName, firstName, lastName,
				birthYear, birthMonth, birthDay, gender, 
				phone, institution, officeContact, position,
				userServiceContext, researcherServiceContext);
				
		SessionMessages.add(actionRequest, "researcherWithUserUpdated");
		
		if(Validator.isNotNull(researcherUser)) {
			_log.info("user is updated / " + researcherUser.getEmailAddress());
						
			if(researcher.getPosition().equals(ResearcherPosition.PI.getLower())) {
				Role role = null;
				
				try {
					role = _roleLocalService.getRole(company.getCompanyId(), "Site PI");
					_log.info(role.toXmlString());
					
					UserGroupRole userGroupRole = UserGroupRoleLocalServiceUtil.createUserGroupRole(new UserGroupRolePK());
					userGroupRole.setUserId(researcherUser.getUserId());
					userGroupRole.setGroupId(themeDisplay.getScopeGroupId());
					userGroupRole.setRoleId(role.getRoleId());
					
					if(!_userGroupRoleLocalService.hasUserGroupRole(userGroupRole.getUserId(), userGroupRole.getGroupId(), userGroupRole.getRoleId())) {
						_userGroupRoleLocalService.addUserGroupRole(userGroupRole);
					}
				} catch (Exception e) {
					if(e instanceof NoSuchRoleException) {
						 // create new role and add UserGroupRole
					}
					_log.error(e.getMessage());
				}
			}
		} else {
			_log.error("user is null");
		}
	}
	
	@Reference
	private Portal _portal;
	
	@Reference
	private RoleLocalService _roleLocalService;
	
	@Reference
	private UserGroupRoleLocalService _userGroupRoleLocalService;
	
	@Reference
	private UserLocalService _userLocalService;
	
	@Reference
	private ResearcherLocalService _researcherLocalService;
	
	@Reference
	private MembershipRequestLocalService _membershipRequestLocalService;
	
	private Log _log = LogFactoryUtil.getLog(UpdateResearcherActionCommand.class);
}
