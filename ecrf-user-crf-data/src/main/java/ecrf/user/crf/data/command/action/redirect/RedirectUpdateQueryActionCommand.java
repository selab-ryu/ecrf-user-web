package ecrf.user.crf.data.command.action.redirect;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.PortletURLFactory;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.LayoutLocalService;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.sx.icecap.service.DataTypeLocalService;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.service.CRFAutoqueryLocalService;
import ecrf.user.service.SubjectLocalService;

@Component
(
	property = {
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF_DATA,
		"mvc.command.name=" + ECRFUserMVCCommand.ACTION_REDIRECT_UPDATE_CRF_QUERY
	},
	service = MVCActionCommand.class
)

public class RedirectUpdateQueryActionCommand extends BaseMVCActionCommand{
	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		String pageFriendlyURL = "/crf/query";
		String portletKey = ECRFUserPortletKeys.CRF_QUERY;
		
		long crfId = ParamUtil.getLong(actionRequest, ECRFUserCRFDataAttributes.CRF_ID);
		long sdId = ParamUtil.getLong(actionRequest, ECRFUserCRFDataAttributes.STRUCTURED_DATA_ID);
		long sId = ParamUtil.getLong(actionRequest, ECRFUserCRFDataAttributes.SUBJECT_ID);
		String termName = ParamUtil.getString(actionRequest, ECRFUserCRFDataAttributes.TERM_NAME);
		String value = ParamUtil.getString(actionRequest, ECRFUserCRFDataAttributes.TERM_VALUE);
		
		_log.info("query edit action : " + sId + " / " + sdId + " / " + termName + " / " + value);

		long plid = 0L;
		try {
			plid = _layoutLocalService.getFriendlyURLLayout(themeDisplay.getScopeGroupId(), true, pageFriendlyURL).getPlid();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		PortletURL renderURL = _portletURLFactory.create(actionRequest, portletKey, plid, PortletRequest.RENDER_PHASE);
		
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, ECRFUserMVCCommand.RENDER_UPDATE_CRF_QUERY);
		
		renderURL.setParameter(ECRFUserCRFDataAttributes.CRF_ID, String.valueOf(crfId));
		renderURL.setParameter(ECRFUserCRFDataAttributes.SUBJECT_ID, String.valueOf(sId));
		renderURL.setParameter(ECRFUserCRFDataAttributes.STRUCTURED_DATA_ID, String.valueOf(sdId));
		renderURL.setParameter(ECRFUserCRFDataAttributes.TERM_NAME, termName);
		renderURL.setParameter(ECRFUserCRFDataAttributes.TERM_VALUE, value);
		
		actionResponse.sendRedirect(renderURL.toString());
	}
	
	private Log _log = LogFactoryUtil.getLog(RedirectUpdateQueryActionCommand.class);
	
	@Reference
	private PortletURLFactory _portletURLFactory;
	
	@Reference
	private LayoutLocalService _layoutLocalService;
	
	@Reference
	private SubjectLocalService _subjectLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
	
	@Reference
	private CRFAutoqueryLocalService _queryLocalService;
}
