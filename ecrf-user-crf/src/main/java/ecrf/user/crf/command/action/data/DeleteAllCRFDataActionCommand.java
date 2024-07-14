package ecrf.user.crf.command.action.data;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.sx.icecap.service.DataTypeLocalService;

import java.util.List;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserJspPaths;
import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.constants.ECRFUserWebKeys;
import ecrf.user.constants.attribute.ECRFUserAttributes;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.model.CRFAutoquery;
import ecrf.user.model.CRFHistory;
import ecrf.user.model.LinkCRF;
import ecrf.user.service.CRFAutoqueryLocalService;
import ecrf.user.service.CRFHistoryLocalService;
import ecrf.user.service.LinkCRFLocalService;
import ecrf.user.service.SubjectLocalService;

@Component
(
	property = {
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF,
		"mvc.command.name=" + ECRFUserMVCCommand.ACTION_DELETE_ALL_CRF_DATA
	},
	service = MVCActionCommand.class
)
public class DeleteAllCRFDataActionCommand extends BaseMVCActionCommand {
	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		_log.info("Delete All CRF");
		
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
        long crfId = ParamUtil.getLong(actionRequest, ECRFUserCRFDataAttributes.CRF_ID, 0); 
		
        try {
			List<LinkCRF> allLink = _linkCRFLocalService.getLinkCRFByG_C(themeDisplay.getScopeGroupId(), crfId);
			for(int j = 0; j < allLink.size(); j++) {
				LinkCRF linkCRF = allLink.get(j);
				long linkId = linkCRF.getLinkId();
				
				_linkCRFLocalService.deleteLinkCRF(linkId);
			}
        } catch (PortalException e) {
			e.printStackTrace();
		}
        
		String renderCommand = ECRFUserMVCCommand.RENDER_LIST_CRF_DATA;
		PortletURL renderURL = PortletURLFactoryUtil.create(
				actionRequest, 
				themeDisplay.getPortletDisplay().getId(), 
				themeDisplay.getPlid(), 
				PortletRequest.RENDER_PHASE);
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
		renderURL.setParameter(ECRFUserCRFDataAttributes.CRF_ID, String.valueOf(crfId));
		
		actionResponse.sendRedirect(renderURL.toString());
	}
	
	private Log _log = LogFactoryUtil.getLog(DeleteAllCRFDataActionCommand.class);
	
	@Reference
	private LinkCRFLocalService _linkCRFLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
}
