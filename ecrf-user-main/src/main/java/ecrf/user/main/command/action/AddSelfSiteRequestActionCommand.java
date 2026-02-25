package ecrf.user.main.command.action;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.model.MembershipRequestConstants;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.MembershipRequestLocalService;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.servlet.SessionErrors;
import com.liferay.portal.kernel.servlet.SessionMessages;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.attribute.ECRFUserMainAttributes;
import ecrf.user.service.SelfSiteRequestLocalService;

@Component
(
	property = {
			"javax.portlet.name="+ECRFUserPortletKeys.MAIN,
			"mvc.command.name="+ECRFUserMVCCommand.ACTION_ADD_SELF_SITE_REQUEST
	},
	service = MVCActionCommand.class
)
public class AddSelfSiteRequestActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		_log.info("add self site request action");
		
		ServiceContext serviceContext = ServiceContextFactory.getInstance(actionRequest);
		
		long siteGroupId = ParamUtil.getLong(actionRequest, ECRFUserMainAttributes.SITE_GROUP_ID, 0);
		_log.info("site group id : " + siteGroupId);
		
		long userId = ParamUtil.getLong(actionRequest, WebKeys.USER_ID);
		
		String email = ParamUtil.getString(actionRequest, ECRFUserMainAttributes.EMAIL);
		String lastName = ParamUtil.getString(actionRequest, ECRFUserMainAttributes.LAST_NAME);
		String firstName = ParamUtil.getString(actionRequest, ECRFUserMainAttributes.FIRST_NAME);
		String phone = ParamUtil.getString(actionRequest, ECRFUserMainAttributes.PHONE);
		String projectTitle = ParamUtil.getString(actionRequest, ECRFUserMainAttributes.TITLE);
		String projectDescription = ParamUtil.getString(actionRequest, ECRFUserMainAttributes.DESCRIPTION);
		
		try {
			_selfSiteRequestLocalService.addRequest(email, lastName, firstName, phone, projectTitle, projectDescription, serviceContext);
			
			hideDefaultSuccessMessage(actionRequest);
		} catch (Exception e) {
			_log.error("add self site request failed");
			e.printStackTrace();
		}
		
		_log.info("send redirect");
		sendRedirect(actionRequest, actionResponse);
	}
	
	private Log _log = LogFactoryUtil.getLog(AddSelfSiteRequestActionCommand.class);
	
	@Reference
	private SelfSiteRequestLocalService _selfSiteRequestLocalService;
}
