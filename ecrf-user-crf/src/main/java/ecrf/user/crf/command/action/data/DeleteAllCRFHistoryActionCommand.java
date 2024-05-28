package ecrf.user.crf.command.action.data;

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
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.model.CRFHistory;
import ecrf.user.service.CRFHistoryLocalService;

@Component
(
	property = {
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF_DATA,
		"mvc.command.name=" + ECRFUserMVCCommand.ACTION_DELETE_ALL_CRF_HISTORY
	},
	service = MVCActionCommand.class
)

public class DeleteAllCRFHistoryActionCommand extends BaseMVCActionCommand{
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		_log.info("All CRF History delete Action Start");
		
		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		long crfId = ParamUtil.getLong(actionRequest, ECRFUserCRFDataAttributes.CRF_ID, 0);
		long subjectId = ParamUtil.getLong(actionRequest, ECRFUserCRFDataAttributes.SUBJECT_ID, 0);
		
		List<CRFHistory> allHis = _crfHistoryLocalService.getCRFHistoryByC_S(crfId, subjectId);
		
		for(int i = 0; i < allHis.size(); i++) {
			long historyId = allHis.get(i).getHistoryId();
			_log.info(historyId);
			_crfHistoryLocalService.deleteCRFHistory(historyId);
		}
		
		String renderCommand = ECRFUserMVCCommand.RENDER_LIST_CRF_DATA;
		PortletURL renderURL = PortletURLFactoryUtil.create(
				actionRequest, 
				themeDisplay.getPortletDisplay().getId(), 
				themeDisplay.getPlid(), 
				PortletRequest.RENDER_PHASE);
		renderURL.setParameter("mvcRenderCommandName", renderCommand);
		actionResponse.sendRedirect(renderURL.toString());
		_log.info("CRF History delete Action End");
	}
	
	private Log _log = LogFactoryUtil.getLog(DeleteAllCRFHistoryActionCommand.class);
	
	@Reference
	private CRFHistoryLocalService _crfHistoryLocalService;
}
