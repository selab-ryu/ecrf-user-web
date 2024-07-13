package ecrf.user.crf.command.action.data;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;

import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.WebKeys;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.PortletRequest;
import javax.portlet.PortletURL;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

import ecrf.user.constants.ECRFUserMVCCommand;
import ecrf.user.constants.ECRFUserPortletKeys;
import ecrf.user.crf.command.render.data.dialog.DialogGraphRenderCommand;
import ecrf.user.model.CRFSearchLog;
import ecrf.user.service.CRFSearchLogLocalService;

@Component
(
	property = {
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF,
		"mvc.command.name=" + ECRFUserMVCCommand.ACTION_REDIRECT_EXCEL_DOWNLOAD,
	},
	service = MVCActionCommand.class
)
public class RedirectExcelDownloadActionCommand extends BaseMVCActionCommand{
	
	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {

		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);

		String excelPackage = actionRequest.getParameter("excelParam");
		String crfId = actionRequest.getParameter("crfId");

		ServiceContext searchServiceContext = ServiceContextFactory.getInstance(CRFSearchLog.class.getName(), actionRequest);
		//CRFSearchLog searchLog = _searchLocalService.addSearchLog(excelPackage, searchServiceContext);
		
		String renderCommand = ECRFUserMVCCommand.RENDER_CRF_DATA_EXCEL_DOWNLOAD;
		PortletURL renderURL = PortletURLFactoryUtil.create(actionRequest, themeDisplay.getPortletDisplay().getId(), themeDisplay.getPlid(), PortletRequest.RENDER_PHASE);
		//_log.info(String.valueOf(excelPackage));
		renderURL.setParameter("mvcRenderCommandName", renderCommand);
		//renderURL.setParameter("searchLogId", String.valueOf(searchLog.getSearchLogId()));
		renderURL.setParameter("crfId", String.valueOf(crfId));
		renderURL.setParameter("excelPackage", String.valueOf(excelPackage));
		
		actionResponse.sendRedirect(renderURL.toString());	
	}
	@Reference
	private CRFSearchLogLocalService _searchLocalService;
	private Log _log = LogFactoryUtil.getLog(DialogGraphRenderCommand.class);
}
