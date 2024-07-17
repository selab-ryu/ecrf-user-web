package ecrf.user.crf.command.action.query;

import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.PortletURLFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCActionCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCActionCommand;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceContextFactory;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;
import com.sx.icecap.model.StructuredData;
import com.sx.icecap.service.DataTypeLocalService;

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
import ecrf.user.constants.attribute.ECRFUserCRFAttributes;
import ecrf.user.constants.attribute.ECRFUserCRFDataAttributes;
import ecrf.user.model.CRFAutoquery;
import ecrf.user.model.LinkCRF;
import ecrf.user.service.CRFAutoqueryLocalService;
import ecrf.user.service.CRFLocalService;
import ecrf.user.service.LinkCRFLocalService;

@Component
(
	property = {
		"javax.portlet.name=" + ECRFUserPortletKeys.CRF,
		"mvc.command.name=" + ECRFUserMVCCommand.ACTION_ALL_CRF_QUERY
	},
	service = MVCActionCommand.class
)
public class BrutalForceQueryActionCommand extends BaseMVCActionCommand {

	@Override
	protected void doProcessAction(ActionRequest actionRequest, ActionResponse actionResponse) throws Exception {
		_log.info("add all query start");
		
		ServiceContext queryServiceContext = ServiceContextFactory.getInstance(CRFAutoquery.class.getName(), actionRequest);

		ThemeDisplay themeDisplay = (ThemeDisplay)actionRequest.getAttribute(WebKeys.THEME_DISPLAY);
		
		long crfId = ParamUtil.getLong(actionRequest, ECRFUserCRFAttributes.CRF_ID, 0);
		long dataTypeId = _crfLocalService.getDataTypeId(crfId);
		
		List<StructuredData> sdList = _dataTypeLocalService.getStructuredDatas(dataTypeId);
		
		JSONObject crfForm = _dataTypeLocalService.getDataTypeStructureJSONObject(dataTypeId);
		JSONArray crfFormArr = JSONFactoryUtil.createJSONArray(crfForm.getString("terms"));
		
		for(int i = 0; i < sdList.size(); i++) {
			long sdId = sdList.get(i).getStructuredDataId();
			LinkCRF link = null;
			link = _linkLocalService.getLinkCRFByStructuredDataId(sdId);
			if(Validator.isNotNull(link)) {
				JSONObject answerForm = JSONFactoryUtil.createJSONObject(sdList.get(i).getStructuredData());
				if(Validator.isNotNull(answerForm) && !answerForm.equals("")) {
					_queryLocalService.checkQuery(sdList.get(i).getStructuredDataId(), crfFormArr, answerForm, link.getSubjectId(), link.getCrfId(), queryServiceContext);
				}	
			}
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
	
	private Log _log = LogFactoryUtil.getLog(BrutalForceQueryActionCommand.class);

	@Reference
	private CRFLocalService _crfLocalService;
	
	@Reference
	private DataTypeLocalService _dataTypeLocalService;
	
	@Reference
	private CRFAutoqueryLocalService _queryLocalService;
	
	@Reference
	private LinkCRFLocalService _linkLocalService;
}
