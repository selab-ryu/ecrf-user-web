package ecrf.user.crf.command.action.query;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;

import java.util.List;

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
import ecrf.user.model.CRFAutoquery;
import ecrf.user.service.CRFAutoqueryLocalService;

@Component
(
	property = {
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF,
		"mvc.command.name=" + ECRFUserMVCCommand.ACTION_DELETE_ALL_CRF_QUERY
	},
	service = MVCActionCommand.class
)
public class DeleteAllQueryActionCommand extends BaseMVCActionCommand{
	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		_log.info("delete all query");
		
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		long crfId = ParamUtil.getLong(actionRequest, ECRFUserCRFDataAttributes.CRF_ID);
		
		List<CRFAutoquery> allQueries = _queryLocalService.getQueryByGroupCRF(themeDisplay.getScopeGroupId(), crfId);
		for(int i = 0; i < allQueries.size(); i++) {
			_queryLocalService.deleteCRFAutoquery(allQueries.get(i).getAutoQueryId());
		}
		
		String renderCommand = ECRFUserMVCCommand.RENDER_LIST_CRF_QUERY;
		PortletURL renderURL = PortletURLFactoryUtil.create(
				actionRequest, 
				themeDisplay.getPortletDisplay().getId(), 
				themeDisplay.getPlid(), 
				PortletRequest.RENDER_PHASE);
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
		renderURL.setParameter(ECRFUserCRFDataAttributes.CRF_ID, String.valueOf(crfId));
		actionResponse.sendRedirect(renderURL.toString());
	}
	
	private Log _log = LogFactoryUtil.getLog(DeleteAllQueryActionCommand.class);
	
	@Reference
	private CRFAutoqueryLocalService _queryLocalService;
}
