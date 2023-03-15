package ecrf.user.researcher.command.action;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.model.Company;
import com.liferay.portal.kernel.model.MembershipRequest;
import com.liferay.portal.kernel.model.User;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.MembershipRequestLocalService;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.service.UserLocalService;
import com.liferay.portal.kernel.servlet.SessionErrors;
import com.liferay.portal.kernel.servlet.SessionMessages;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.Constants;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Portal;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;

import java.util.Calendar;
import java.util.logging.Logger;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserResearcherAttributes;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.model.Researcher;
import ecrf.user.service.ResearcherLocalService;

@Component
(
		property = {
				"javax.portlet.name="+ECRFUserPortletKeys.RESEARCHER,
				"mvc.command.name="+ECRFUserMVCCommand.ACTION_ADD_RESEARCHER
		},
		service = MVCActionCommand.class
)
public class AddResearcherActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		_logger = Logger.getLogger(this.getClass().getName());
		
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		String cmd = ParamUtil.getString(actionRequest, Constants.CMD);
		
		if(cmd.equals(Constants.ADD)) {
			addResearcherWithUser(actionRequest, actionResponse);
		} else if(cmd.equals(Constants.UPDATE)) {
			updateResearcherWithUser(actionRequest, actionResponse);
		}
		
		String renderCommand = ECRFUserMVCCommand.RENDER_LIST_RESEARCHER;
		PortletURL renderURL = PortletURLFactoryUtil.create(
				actionRequest, 
				themeDisplay.getPortletDisplay().getId(), 
				themeDisplay.getPlid(), 
				PortletRequest.RENDER_PHASE);
		
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
		_logger.info("Render URL : " + renderURL.toString());
		actionResponse.sendRedirect(renderURL.toString());
		
		_logger.info("End");
	}
	
	public void addResearcherWithUser(ActionRequest actionRequest, ActionResponse actionResponse) throws PortalException {
		_logger.info("Add Researcher With User Start");
		
		HttpServletRequest httpServletRequest = _portal.getHttpServletRequest(actionRequest);
		HttpSession session = httpServletRequest.getSession();

		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		ServiceContext researcherServiceContext = ServiceContextFactory.getInstance(Researcher.class.getName(), actionRequest);
		ServiceContext userServiceContext = ServiceContextFactory.getInstance(User.class.getName(), actionRequest);
		Company company = themeDisplay.getCompany();
		
		_logger.info("get data from request parameter");
		String email = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.EMAIL);
		String password1 = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.PASSWORD1);
		String password2 = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.PASSWORD2);
		String screenName = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.SCREEN_NAME);
		String firstName = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.FIRST_NAME);
		String lastName = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.LAST_NAME);
		
		long facebookId = ParamUtil.getLong(actionRequest, "facebookId");
		String openId = ParamUtil.getString(actionRequest, "openId");
		String languageId = ParamUtil.getString(actionRequest, "languageId");
		boolean male = ParamUtil.getBoolean(actionRequest, "male", true);
		String jobTitle = ParamUtil.getString(actionRequest, "jobTitle");
		long prefixId = ParamUtil.getInteger(actionRequest, "prefixId");
		long suffixId = ParamUtil.getInteger(actionRequest, "suffixId");
		
		int birthYear = ParamUtil.getInteger(actionRequest, ECRFUserResearcherAttributes.BIRTH_YEAR, 1970);
		int birthMonth = ParamUtil.getInteger(actionRequest, ECRFUserResearcherAttributes.BIRTH_MONTH, Calendar.JANUARY);
		int birthDay = ParamUtil.getInteger(actionRequest, ECRFUserResearcherAttributes.BIRTH_DAY, 1);
		String phone = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.PHONE);
		String institution = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.INSTITUTION);
		String officeContact = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.OFFICE_CONTACT);
		String position = ParamUtil.getString(actionRequest, ECRFUserResearcherAttributes.POSITION);
		
		_logger.info("add Researcher with User");
		Researcher researcher = null;
		try {
		researcher = _researcherLocalService.addResarcherWithUser(
				company.getCompanyId(), facebookId, openId, languageId,
				male, jobTitle, prefixId, suffixId,
				email, password1, password2, screenName, firstName, lastName,
				birthYear, birthMonth, birthDay, phone, 
				institution, officeContact, position, 0,
				userServiceContext, researcherServiceContext);
			SessionMessages.add(actionRequest, "researcherWithUserAdded");
		} catch(PortalException e) {
			System.out.println(e);
			SessionErrors.add(actionRequest, e.getClass().getName());
			
		}
		User user = null;
		
		if(Validator.isNotNull(researcher)) {
			user = _userLocalService.getUser(researcher.getResearcherUserId());
		}
		if(Validator.isNotNull(user)) {
			_logger.info("add user to membership");
			SessionMessages.add(httpServletRequest, "userAdded", user.getEmailAddress());
			ServiceContext membershipServiceContext = ServiceContextFactory.getInstance(MembershipRequest.class.getName(), actionRequest);
			_membershipRequestLocalService.addMembershipRequest(user.getUserId(), themeDisplay.getScopeGroupId(), "Add Researcher to Site Membership", membershipServiceContext);
		} else {
			_logger.info("user is null");
		}
		
		_logger.info("Add Researcher With User End");
	}
	
	public void updateResearcherWithUser(ActionRequest actionRequest, ActionResponse actionResponse) {
		
	}
	
	public void sendRedirect() {
		
	}
	
	private Logger _logger;
	
	@Reference
	private Portal _portal;
	
	@Reference
	private UserLocalService _userLocalService;
	
	@Reference
	private ResearcherLocalService _researcherLocalService;
	
	@Reference
	private MembershipRequestLocalService _membershipRequestLocalService;
}
