package ecrf.user.crf.command.action.data;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.sx.icecap.service.DataTypeLocalService;

import java.text.SimpleDateFormat;

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
import ecrf.user.constants.attribute.ECRFUserCRFAttributes;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.model.LinkCRF;
import ecrf.user.service.CRFLocalService;
import ecrf.user.service.LinkCRFLocalService;

@Component
(
	property = {
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF_DATA,
		"mvc.command.name=" + ECRFUserMVCCommand.ACTION_DELETE_CRF_DATA,
	},
	service = MVCActionCommand.class
)

public class DeleteCRFDataActionCommand extends BaseMVCActionCommand{
	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
        SimpleDateFormat dateWithTimeFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm");
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd");
        ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
        
        long crfId = 0;
        long dataTypeId = 0;
        long sdId = 0;
        
        long linkCRFId = ParamUtil.getLong(actionRequest, ECRFUserCRFDataAttributes.LINK_CRF_ID, 0);
        _log.info("link crf id : " + linkCRFId);
        
        LinkCRF linkCRF = null;
        
        if(linkCRFId > 0) {
        	linkCRF = _linkCRFLocalService.getLinkCRF(linkCRFId);
        	
        	sdId = linkCRF.getStructuredDataId();
        	crfId = linkCRF.getCrfId();
//        	dataTypeId = _crfLocalSerivice.getDataTypeId(crfId);
        	
        	try {
                
            	_dataTypeLocalService.removeStructuredData(sdId, 0);
            	_linkCRFLocalService.deleteLinkCRF(linkCRFId);
            	// need to delete related query ?
            } catch (Exception e) {
            	e.printStackTrace();
            }
        }
        
		String renderCommand = ECRFUserMVCCommand.RENDER_LIST_CRF_DATA;
		String listPath = ECRFUserJspPaths.JSP_LIST_CRF_DATA_UPDATE;
		PortletURL renderURL = PortletURLFactoryUtil.create(
				actionRequest, 
				themeDisplay.getPortletDisplay().getId(), 
				themeDisplay.getPlid(), 
				PortletRequest.RENDER_PHASE);
		renderURL.setParameter(ECRFUserWebKeys.MVC_RENDER_COMMAND_NAME, renderCommand);
		renderURL.setParameter(ECRFUserCRFAttributes.CRF_ID, String.valueOf(crfId));
		renderURL.setParameter(ECRFUserWebKeys.LIST_PATH, listPath);

		actionResponse.sendRedirect(renderURL.toString());
	}
	
	private Log _log = LogFactoryUtil.getLog(DeleteCRFDataActionCommand.class);
	
	@Reference
	private CRFLocalService _crfLocalSerivice;
	
	@Reference
	private LinkCRFLocalService _linkCRFLocalService;

	@Reference
	private DataTypeLocalService _dataTypeLocalService;
}
